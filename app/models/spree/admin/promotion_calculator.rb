module Spree
    module Admin
        class PromotionCalculator 
            def self.compute_promotional_sales(sales_forecast, date_of_forecast, promotion_start_date, promotion_end_date, promotion_percentage,inventory_positions)
              days_from_forecast_to_start_date = (promotion_start_date - date_of_forecast)
              days_from_forecast_to_end_date = (promotion_end_date - date_of_forecast )

              start_week_number = (days_from_forecast_to_start_date/NUMBER_OF_DAYS_IN_WEEK).to_i
              ending_week_number = (days_from_forecast_to_end_date/NUMBER_OF_DAYS_IN_WEEK).to_i

              simulated_promotional_sales = []
              sales_forecast.each_with_index do |sale, index|
                number_of_promotional_days = compute_promotional_days(start_week_number,promotion_start_date,date_of_forecast,ending_week_number,promotion_end_date,index)

                simulated_promotional_revenue = compute_promotional_sale_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)
                simulated_promotional_sales_units = compute_promotional_sales_units_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)
                simulated_promotional_margin = compute_promotional_margin_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)
                cost_of_simulated_sales_units = compute_promotional_product_cost(sale,index,start_week_number,ending_week_number,promotion_percentage)

                sale.revenue = simulated_promotional_revenue
                sale.sales_units = simulated_promotional_sales_units
                sale.cost = cost_of_simulated_sales_units

                simulated_promotional_sales << sale 
              end
              simulated_promotional_sales
            end

            def self.compute_promotional_sale_for_a_week(sale,index,start_week_number,end_week_number,promotion_percentage,number_of_promotional_days)
              if((start_week_number .. end_week_number).include? index )
                daily_sale_revenue = daily_revenue(sale.revenue)
                cost_per_unit = sale.cost/sale.sales_units
                promotion_revenue = daily_revenue_with_promotion(sale,promotion_percentage)
                promotional_revenue_for_this_week = revenue_for_this_week(number_of_promotional_days,promotion_revenue, daily_sale_revenue) 
              else
                promotional_revenue_for_this_week = sale.revenue
              end
              promotional_revenue_for_this_week
            end

            def self.compute_promotional_sales_units_for_a_week(sale,index,start_week_number,end_week_number,promotion_percentage,number_of_promotional_days)
              if((start_week_number .. end_week_number).include? index )
                promotional_sales_units_for_this_week = sales_units_for_this_week(sale,number_of_promotional_days,promotion_percentage)
              else
                promotional_sales_units_for_this_week = sale.sales_units
              end
              promotional_sales_units_for_this_week
            end

            def self.compute_promotional_margin_for_a_week(sale,index,start_week_number,end_week_number,promotion_percentage,number_of_promotional_days)
                if((start_week_number .. end_week_number).include? index )
                    cost_per_unit = sale.cost/sale.sales_units

                    promotion_revenue = daily_revenue_with_promotion(sale,promotion_percentage)

                    promotional_margin_for_this_week = margin_for_this_week(sale,promotion_revenue,number_of_promotional_days,cost_per_unit,promotion_percentage)
                else
                    promotional_margin_for_this_week =  sale.revenue - sale.cost
                end
                promotional_margin_for_this_week
            end

            def self.compute_promotional_product_cost(sale,index,start_week_number,end_week_number,promotion_percentage)
                if((start_week_number .. end_week_number).include? index )
                    daily_sale_units = daily_sales(sale.sales_units)
                    daily_promotional_sale_units = daily_promotional_sales(daily_sale_units,promotion_percentage)
                    cost_per_unit = sale.cost/sale.sales_units

                    product_cost = daily_promotional_sale_units * cost_per_unit
                else
                    product_cost = sale.cost
                end
                product_cost
            end

            def self.daily_revenue(revenue)
                revenue/NUMBER_OF_DAYS_IN_WEEK
            end

            def self.daily_sales(units)
                units/NUMBER_OF_DAYS_IN_WEEK.round
            end

            def self.daily_promotional_sales(daily_sales_units, promotion_percentage)
                daily_sales_units * (1+ (0.003125 * ((promotion_percentage) ** 2)))
            end

            def self.compute_promotion_percentage(promotion_data)
                if(promotion_data[1].nil? || promotion_data[1][:promotion_type].nil?)
                    promotion_type =  "P"
                    promotion_percentage = 0
                else
                    promotion_type = promotion_data[1][:promotion_type]
                    promotion_percentage =  promotion_data[1][:promotion_percentage].to_f
                end
                promotion_percentage
            end

            def self.compute_promotional_days (start_week_number,start_date,date_of_forecast,ending_week_number,end_date,index)
              if(index == start_week_number)
                number_of_promotional_days =  NUMBER_OF_DAYS_IN_WEEK - ((start_date - date_of_forecast)%NUMBER_OF_DAYS_IN_WEEK)
              elsif(index == ending_week_number)
                days = ((end_date - date_of_forecast)+1)%NUMBER_OF_DAYS_IN_WEEK
                number_of_promotional_days = days == 0 ? 7 : days 
              elsif(index > start_week_number && index < ending_week_number)
                number_of_promotional_days = NUMBER_OF_DAYS_IN_WEEK
              else
                number_of_promotional_days = 0
              end
              number_of_promotional_days
            end

            def self.daily_revenue_with_promotion(sale,promotion_percentage)
                daily_sales_revenue = daily_revenue(sale.revenue)
                daily_sale_units = daily_sales(sale.sales_units)
                daily_promotional_sale_units = daily_promotional_sales(daily_sale_units,promotion_percentage)
                daily_sales_revenue*daily_promotional_sale_units*(1-promotion_percentage/100.to_f)/daily_sale_units
            end

            def self.revenue_for_this_week(number_of_promotional_days,promotion_revenue,daily_sale_revenue)
                weekly_promotion_revenue = number_of_promotional_days * promotion_revenue
                weekly_revenue = (NUMBER_OF_DAYS_IN_WEEK - number_of_promotional_days) * daily_sale_revenue
                (weekly_revenue + weekly_promotion_revenue).round(2)
            end

            def self.sales_units_for_this_week(sale,number_of_promotional_days,promotion_percentage)
                daily_sale_units = daily_sales(sale.sales_units)
                daily_promotional_sale_units = daily_promotional_sales(daily_sale_units,promotion_percentage)
                number_of_promotional_days * daily_promotional_sale_units + (NUMBER_OF_DAYS_IN_WEEK-number_of_promotional_days) *daily_sale_units
            end

            def self.margin_for_this_week(sale,promotion_revenue,number_of_promotional_days,cost_per_unit,promotion_percentage)
                daily_sale_units = daily_sales(sale.sales_units)
                daily_sale_revenue = daily_revenue(sale.revenue)
                daily_promotional_sale_units = daily_promotional_sales(daily_sale_units,promotion_percentage)
                promotional_margin = (promotion_revenue - (cost_per_unit * daily_promotional_sale_units))*number_of_promotional_days
                normal_margin = (daily_sale_revenue - (cost_per_unit*daily_sale_units)) * (NUMBER_OF_DAYS_IN_WEEK - number_of_promotional_days)

                margin = promotional_margin + normal_margin
            end

            def self.compute_simulated_promotional_sales(sales_forecast, date_of_forecast, promotion_start_date, promotion_end_date, promotion_percentage,inventory_positions)
              days_from_forecast_to_start_date = (promotion_start_date - date_of_forecast)
              days_from_forecast_to_end_date = (promotion_end_date - date_of_forecast )

              start_week_number = (days_from_forecast_to_start_date/NUMBER_OF_DAYS_IN_WEEK).to_i
              ending_week_number = (days_from_forecast_to_end_date/NUMBER_OF_DAYS_IN_WEEK).to_i

              simulated_promotional_sales = []
              sales_forecast.each_with_index do |sale, index|
                number_of_promotional_days = compute_promotional_days(start_week_number,promotion_start_date,date_of_forecast,ending_week_number,promotion_end_date,index)

                simulated_promotional_revenue = compute_promotional_sale_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)
                simulated_promotional_sales_units = compute_promotional_sales_units_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)
                simulated_promotional_margin = compute_promotional_margin_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)
                cost_of_simulated_sales_units = compute_promotional_product_cost(sale,index,start_week_number,ending_week_number,promotion_percentage)
                inventory_position = inventory_positions[index] - simulated_promotional_revenue + sale.revenue

                sim_sales = SimulatedSales.new(simulated_promotional_revenue,simulated_promotional_sales_units,
                                               simulated_promotional_margin,inventory_position, cost_of_simulated_sales_units)

                simulated_promotional_sales << sim_sales
              end
              simulated_promotional_sales
            end

            def self.compute_inventory_positions(sales_forecast, date_of_forecast, promotion_start_date, promotion_end_date, promotion_percentage,inventory_positions)
              days_from_forecast_to_start_date = (promotion_start_date - date_of_forecast)
              days_from_forecast_to_end_date = (promotion_end_date - date_of_forecast )

              start_week_number = (days_from_forecast_to_start_date/NUMBER_OF_DAYS_IN_WEEK).to_i
              ending_week_number = (days_from_forecast_to_end_date/NUMBER_OF_DAYS_IN_WEEK).to_i

              simulated_inventory_positions = []
              sales_forecast.each_with_index do |sale, index|
                number_of_promotional_days = compute_promotional_days(start_week_number,promotion_start_date,date_of_forecast,ending_week_number,promotion_end_date,index)
                simulated_promotional_revenue = compute_promotional_sale_for_a_week(sale,index,start_week_number,ending_week_number,promotion_percentage,number_of_promotional_days)

                inventory_position = inventory_positions[index] - simulated_promotional_revenue + sale.revenue

                simulated_inventory_positions << inventory_position
              end
              simulated_inventory_positions
            end
        end
    end
end
