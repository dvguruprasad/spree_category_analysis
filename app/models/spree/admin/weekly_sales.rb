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
        end
    end
end
