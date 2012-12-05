module Spree
    module Admin
        class PromotionSimulatorController < Spree::Admin::BaseController
            def index
                product = Product.find(params[:product_id])
                date_of_forecast =  Date.new(2013, 1, 14)
                number_of_weeks = 6
                sales = ProductWeeklySales.sales_including_forecasts(product, date_of_forecast,number_of_weeks)
                sum_target_revenue = 0.0
                @cumulative_targets = sales.map do |sale|
                    sale.target_revenue + sum_target_revenue
                    sum_target_revenue += sale.target_revenue
                end

                @inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map{|p| p.closing_position * product.price.to_f}

                last_year_sales = ProductWeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)
                sum_revenue = 0.0
                @sales_last_year = last_year_sales.map do |sale|
                  sale.revenue + sum_revenue
                  sum_revenue += sale.revenue
                end
                
            end

        end
    end
end

