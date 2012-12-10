module Spree
    module Admin
        class WeeklySales < ActiveRecord::Base
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

            def self.aggregate_for_child(weekly_sales_for_child)
                return {} if weekly_sales_for_child.empty?
                total_revenue = weekly_sales_for_child.inject(0) { |sum, pws| sum + pws.revenue }
                total_target_revenue = weekly_sales_for_child.inject(0) { |sum, pws| sum + pws.target_revenue }
                start_time = weekly_sales_for_child.inject do |min, pws|
                    min.week_start_date < pws.week_start_date ? min : pws
                end.week_start_date

                end_time = weekly_sales_for_child.inject do |max, pws|
                    max.week_end_date > pws.week_end_date ? max : pws
                end.week_end_date
                number_of_weeks = weekly_sales_for_child.count

                {"total_revenue" => total_revenue, "total_target_revenue" => total_target_revenue,
                 "start_time" => start_time, "end_time" => end_time, "number_of_weeks" => number_of_weeks}
            end

            def self.sales_including_forecasts(product, week_start_date, number_of_weeks)
                raise "week_start_date should be the beginning of a week(monday)" if week_start_date.beginning_of_week != week_start_date
                sales = find(:all, :conditions => ["child_id = ? and week_start_date >= ?", product.id, week_start_date]).take(number_of_weeks)
                return sales if sales.count == number_of_weeks
                forecast_start_date = sales.empty? ? week_start_date : sales.last.week_start_date + 7
                forecasts = ProductWeeklySalesForecast.find(:all, :conditions => ["product_id = ? and week_start_date >= ?", product.id, forecast_start_date]).take(number_of_weeks - sales.count)
                sales + forecasts
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
