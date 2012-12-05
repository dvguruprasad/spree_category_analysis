module Spree
    module Admin
        class WeeklySales < ActiveRecord::Base
            self.table_name= "spree_weekly_sales"

            def self.by_taxon_id(taxon_id)
                products_sales = WeeklySales.find_all_by_parent_id(taxon_id) 
                return {} if products_sales.nil? or products_sales.empty?
                aggregate_by_product = {}
                child_ids = WeeklySales.select(:child_id).uniq.map { |pws| pws.child_id }
                child_ids.each do |p_id|
                    weekly_sales_by_product = products_sales.select{ |ps| ps.child_id == p_id }
                    aggregate_by_product[p_id] = self.aggregate(weekly_sales_by_product) unless weekly_sales_by_product.nil? or weekly_sales_by_product.empty?
                end
                aggregate_by_product
            end

            def self.aggregate(weekly_sales)
                return {} if weekly_sales.empty?
                total_revenue = weekly_sales.inject(0) { |sum, pws| sum + pws.revenue }
                total_target_revenue = weekly_sales.inject(0) { |sum, pws| sum + pws.target_revenue }
                start_time = weekly_sales.inject do |min, pws|
                    min.week_start_date < pws.week_start_date ? min : pws
                end.week_start_date

                end_time = weekly_sales.inject do |max, pws|
                    max.week_end_date > pws.week_end_date ? max : pws
                end.week_end_date
                number_of_weeks = weekly_sales.count

                {"total_revenue" => total_revenue, "total_target_revenue" => total_target_revenue,
                 "start_time" => start_time, "end_time" => end_time, "number_of_weeks" => number_of_weeks}
            end
        end
    end
end
