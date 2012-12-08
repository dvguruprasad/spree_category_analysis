module Spree
    module Admin
        class PromotionSimulatorController < Spree::Admin::BaseController
            def index
                product = Product.find(params[:product_id])
                date_of_forecast =  Date.new(2013, 1, 14)
                number_of_weeks = 6
                @start_of_year = date_of_forecast.beginning_of_year.to_json
                @start_day = date_of_forecast.yday
                @end_day = (date_of_forecast+number_of_weeks.weeks).yday
                sales = WeeklySales.sales_including_forecasts(product, date_of_forecast,number_of_weeks)
                @sum_target_revenue = sales.sum(&:target_revenue)

                @weekly_target_revenue = sales.map{|s| s.target_revenue.round(2)}
                
                sum_revenue = 0.0
                @sales_revenue = sales.map{|s| s.revenue.round(2)}
                @cumulative_sale = sales.map do |sale|
                    sum_revenue += sale.revenue.round(2)
                end

                @sales_margin = sales.map{|s| (s.revenue - s.cost).round(2)}

                sum_margin = 0.0
                @cumulative_sales_margin = @sales_margin.map do |sale|
                  sum_margin += sale.round(2)
                end

                @inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map{|p| p.closing_position}

                last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)
                sum_revenue = 0.0
                @sales_last_year = last_year_sales.map do |sale|
                  sum_revenue += sale.revenue.round(2)
                end
                
            end

        end
    end
end

