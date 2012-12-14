module Spree
  module Admin
    class GraphReport
      attr_accessor :product_id, :start_of_year, :start_day, :end_day,
                      :sum_target_revenue, :weekly_target_revenue, :sales_revenue, :cumulative_sale,
                      :sales_margin, :cumulative_sales_margin, :inventory_positions,:sales_last_year,
                      :weekly_simulated_sales, :cumulative_simulated_sales, :simulated_margin

      def initialize(product_id, start_of_year, start_day, end_day,
                      sum_target_revenue, weekly_target_revenue, sales_revenue, cumulative_sale,
                      sales_margin, cumulative_sales_margin, inventory_positions, sales_last_year,
                      weekly_simulated_sales, cumulative_simulated_sales, simulated_margin)
        @product_id = product_id
        @start_of_year = start_of_year
        @start_day = start_day
        @end_day = end_day
        @sum_target_revenue = sum_target_revenue
        @weekly_target_revenue = weekly_target_revenue
        @weekly_sales_revenue = sales_revenue
        @cumulative_sale = cumulative_sale
        @weekly_sales_margin =  sales_margin
        @cumulative_sales_margin = cumulative_sales_margin
        @inventory_positions = inventory_positions
        @cumulative_sales_last_year = sales_last_year
        @weekly_simulated_sales = weekly_simulated_sales
        @cumulative_simulated_sales = cumulative_simulated_sales
        @simulated_margin = simulated_margin
      end
    end
  end
end

