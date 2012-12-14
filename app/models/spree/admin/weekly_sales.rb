module Spree
    module Admin
        class WeeklySales < ActiveRecord::Base
          attr_accessible :child_id, :week_start_date, :week_end_date
            CATEGORY_TAXON_ID = 1000
            self.table_name= "spree_weekly_sales"

            def self.generate_aggregates(weekly_sales)
                return {} if weekly_sales.nil? or weekly_sales.empty?
                aggregate_by_child_id = {}
                child_ids = weekly_sales.collect{|ws| ws.child_id}.uniq
                child_ids.each do |c_id|
                    weekly_sales_for_child = weekly_sales.select{ |ws| ws.child_id == c_id }
                    aggregate_by_child_id[c_id] = self.aggregate_for_child(weekly_sales_for_child)
                end
                aggregate_by_child_id
            end

            def self.generate_category_aggregates
                week_number = Date.today.cweek * -1
                taxon = Spree::Taxon.find(CATEGORY_TAXON_ID)
                self.generate_aggregates(taxon.weekly_sales_by_time_frame(week_number))
            end

            def self.aggregate_for_child(weekly_sales_for_child)
                return {} if weekly_sales_for_child.empty?
                total_revenue = weekly_sales_for_child.inject(0) { |sum, pws| sum + pws.revenue }
                total_target_revenue = weekly_sales_for_child.inject(0) { |sum, pws| sum + pws.target_revenue }
                start_time = weekly_sales_for_child.inject do |min, pws|
                    min.week_start_date < pws.week_start_date ? min : pws
                end.week_start_date
                total_cost = weekly_sales_for_child.inject(0) { |sum, pws| sum + pws.cost }

                end_time = weekly_sales_for_child.inject do |max, pws|
                    max.week_end_date > pws.week_end_date ? max : pws
                end.week_end_date
                number_of_weeks = weekly_sales_for_child.count

                total_units = weekly_sales_for_child.inject(0){|sum,pws| sum+pws.sales_units}
                target_units = weekly_sales_for_child.inject(0){|sum,pws| sum+pws.target_sales_units}
                child_id = weekly_sales_for_child.first.child_id
                parent_id = weekly_sales_for_child.first.parent_id

                last_period_revenue = revenue_previous_period(start_time.years_ago(1), end_time.years_ago(1) ,parent_id, child_id )
                last_period_cost = cost_previous_period(start_time.years_ago(1), end_time.years_ago(1) ,parent_id, child_id )

                {"total_revenue" => total_revenue, "total_target_revenue" => total_target_revenue,"start_time" => start_time, "end_time" => end_time, 
                 "number_of_weeks" => number_of_weeks, "total_cost" => total_cost, "last_period_revenue" => last_period_revenue,
                 "last_period_cost" => last_period_cost, "total_units" => total_units, "target_units" => target_units}
            end

            def self.revenue_previous_period(from_week_date,to_week_date, parent_id,child_id)
                previous_period_weekly_sales = self.where("parent_id = ? and child_id  = ? and week_start_date >= ? and week_start_date < ?",parent_id,child_id,from_week_date,to_week_date)
                previous_period_weekly_sales.inject(0) { |sum, pws| sum + pws.revenue }
            end

            def self.cost_previous_period(from_week_date,to_week_date, parent_id,child_id)
                previous_period_weekly_sales = self.where("parent_id = ? and child_id  = ? and week_start_date >= ? and week_start_date < ?",parent_id,child_id,from_week_date,to_week_date)
                previous_period_weekly_sales.inject(0) { |sum, pws| sum + pws.cost }
            end

            def self.sales_including_forecasts(child_id,week_start_date, number_of_weeks)
                raise "week_start_date should be the beginning of a week(monday)" if week_start_date.beginning_of_week != week_start_date
                sales = WeeklySales.find(:all, :conditions => ["child_id = ? and week_start_date >= ?", child_id, week_start_date]).take(number_of_weeks)
                return sales if sales.count == number_of_weeks
                forecast_start_date = sales.empty? ? week_start_date : sales.last.week_start_date + 7
                forecasts = WeeklySalesForecast.find(:all, :conditions => ["child_id = ? and week_start_date >= ?", child_id, forecast_start_date]).take(number_of_weeks - sales.count)
                sales + forecasts
            end

            def sum_target_revenue(week_start_date, number_of_weeks)
              sales = sales_including_forecasts(week_start_date,number_of_weeks)
              sales.sum(&:target_revenue)
            end

            def self.sales_last_year(product, week_start_date, number_of_weeks)
                raise "week_start_date should be the beginning of a week(monday)" if week_start_date.beginning_of_week != week_start_date
                last_year = week_start_date.prev_year.year
                week_count = week_start_date.cweek
                week_start_date_last_year = Date.commercial(last_year, week_count, 1)

                sales = find(:all, :conditions => ["child_id = ? and week_start_date >= ?", product.id, week_start_date_last_year]).take(number_of_weeks)
                sales
            end

        end
    end
end
