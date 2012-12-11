module Spree
    module Admin
        class PromotionSimulatorController < Spree::Admin::BaseController
          respond_to :json, :html
          def index
                product_id = params[:product_id]
                product = Product.find(product_id) 
                date_of_forecast =  Date.new(2013, 1, 14)
                number_of_weeks = 6
                
                start_of_year = date_of_forecast.beginning_of_year.to_json
                start_day = date_of_forecast.yday
                end_day = (date_of_forecast+number_of_weeks.weeks).yday
                
                sales = WeeklySales.sales_including_forecasts(product, date_of_forecast,number_of_weeks)
                sum_target_revenue = sales.sum(&:target_revenue)

                weekly_target_revenue = sales.map{|s| s.target_revenue.round(2)}
                
                sum_revenue = 0.0
                sales_revenue = sales.map{|s| s.revenue.round(2)}
                cumulative_sale = sales.map do |sale|
                    sum_revenue += sale.revenue.round(2)
                end

                sales_margin = sales.map{|s| (s.revenue - s.cost).round(2)}

                sum_margin = 0.0
                cumulative_sales_margin = sales_margin.map do |sale|
                  sum_margin += sale.round(2)
                end

                inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map{|p| p.closing_position}

                last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)
                sum_revenue = 0.0
                sales_last_year = last_year_sales.map do |sale|
                  sum_revenue += sale.revenue.round(2)
                end
                #simulated_sales = compute_promotional_sales(sales,date_of_forecast) if(params[:promotion_data])
                simulated_sales = sales.map{|s|s.revenue*1.25}
                report = GraphReport.new(product_id,start_of_year,start_day,end_day,sum_target_revenue,weekly_target_revenue,sales_revenue,cumulative_sale,sales_margin,cumulative_sales_margin,inventory_positions,sales_last_year,simulated_sales)

                @jsonrep = report.to_json
                respond_with(@jsonrep)
            end

          def compute_promotional_sales(sales_forecast,date_of_forecast)
            start_date = params[:promotion_data][:start_date]            
            end_date = params[:promotion_data][:end_date]
            promotion_type = params[:promotion_data][:promotion_type]
            promotion_percentage = params[:promotion_data][:promotion_percentage]
            p sales_forecast
            #i = date_of_forecast - start_date.to_i
            #closer_week_to_start_date = x+7*(i/6).days
            #days_left = start_date - closer_week_to_start_date
            #apply_promotions(sales_forecast, days_left)
            #sales_forecast.map{|s|s.total_revenue*1.25}

          end
        end
    end
end

