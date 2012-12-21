module Spree
  module Admin
    class SimulatedSales
      attr_accessor :revenue, :sales_units, :margin, :inventory_position 
      def initialize(revenue,sales_units,margin,inventory_position)
        @revenue = revenue
        @sales_units = sales_units 
        @margin = margin
        @inventory_position = inventory_position
      end

      def self.simulated_sales(sales_forecast, date_of_forecast, start_date, end_date, promotion_data,inventory_positions)
         if(promotion_data[1].nil? || promotion_data[1][:promotion_type].nil?)
          promotion_type =  "P"
          promotion_percentage = 0
         else
           promotion_type = promotion_data[1][:promotion_type]
           promotion_percentage =  promotion_data[1][:promotion_percentage].to_f
        end
        days_from_forecast_to_start_date = (start_date - date_of_forecast)
        days_from_forecast_to_end_date = (end_date - date_of_forecast )

        start_week_number = (days_from_forecast_to_start_date/NUMBER_OF_DAYS_IN_WEEK).to_i
        ending_week_number = (days_from_forecast_to_end_date/NUMBER_OF_DAYS_IN_WEEK).to_i

        simulated_promotional_sales = []
        sales_forecast.each_with_index do |sale, index|
          if((start_week_number .. ending_week_number).include? index )
            daily_sale_revenue = sale.revenue/NUMBER_OF_DAYS_IN_WEEK  
            cost_per_unit = sale.cost/sale.sales_units

            daily_sale_units = sale.sales_units/NUMBER_OF_DAYS_IN_WEEK.round
            daily_promotional_sale_units = daily_sale_units * (1+ (0.003125 * ((promotion_percentage) ** 2)))

            promotion_revenue = daily_revenue_with_promotion(daily_sale_revenue,promotion_percentage,daily_sale_units, daily_promotional_sale_units)
            number_of_promotional_days = compute_promotional_days(start_week_number,start_date,date_of_forecast,ending_week_number,end_date,index)

            simulated_promotional_revenue = revenue_for_this_week(number_of_promotional_days,promotion_revenue, daily_sale_revenue) 
            simulated_promotional_sales_units = number_of_promotional_days * daily_promotional_sale_units + (NUMBER_OF_DAYS_IN_WEEK-number_of_promotional_days) *daily_sale_units
            simulated_promotional_margin = margin_for_this_week(promotion_revenue,number_of_promotional_days,daily_sale_revenue,cost_per_unit,daily_promotional_sale_units,daily_sale_units)

          else
            simulated_promotional_revenue = sale.revenue
            simulated_promotional_sales_units = sale.sales_units
            simulated_promotional_margin = sale.revenue - sale.cost
          end
          inventory_position = inventory_positions[index] - simulated_promotional_revenue + sale.revenue
          sim_sales = SimulatedSales.new(simulated_promotional_revenue,simulated_promotional_sales_units, simulated_promotional_margin,inventory_position)

          simulated_promotional_sales << sim_sales
        end
        simulated_promotional_sales
      end

      def self.compute_promotional_days (start_week_number,start_date,date_of_forecast,ending_week_number,end_date,index)
        if(index == start_week_number)
          number_of_promotional_days =  NUMBER_OF_DAYS_IN_WEEK - ((start_date - date_of_forecast)%NUMBER_OF_DAYS_IN_WEEK)
        elsif(index == ending_week_number)
          number_of_promotional_days =((end_date - date_of_forecast)+1)%NUMBER_OF_DAYS_IN_WEEK
        else
          number_of_promotional_days = NUMBER_OF_DAYS_IN_WEEK
        end
        number_of_promotional_days
      end

      def self.daily_revenue_with_promotion(daily_sales_revenue, promotion_percentage, daily_sale_units, daily_promotional_sale_units)
        daily_sales_revenue*daily_promotional_sale_units*(1-promotion_percentage/100.to_f)/daily_sale_units
      end

      def self.revenue_for_this_week(number_of_promotional_days,promotion_revenue,daily_sale_revenue)
        weekly_promotion_revenue = number_of_promotional_days * promotion_revenue
        weekly_revenue = (NUMBER_OF_DAYS_IN_WEEK - number_of_promotional_days) * daily_sale_revenue
        (weekly_revenue + weekly_promotion_revenue).round(2)
      end

      def self.margin_for_this_week(promotion_revenue,number_of_promotional_days,daily_sale_revenue,cost_per_unit,daily_promotional_sale_units,daily_sale_units)
        promotional_margin = (promotion_revenue - (cost_per_unit * daily_promotional_sale_units))*number_of_promotional_days
        normal_margin = (daily_sale_revenue - (cost_per_unit*daily_sale_units)) * (NUMBER_OF_DAYS_IN_WEEK - number_of_promotional_days)

        margin = promotional_margin + normal_margin
      end

    end
  end
end
