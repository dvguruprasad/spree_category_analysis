module Spree
  module Admin
    class SimulatedSales
      attr_accessor :revenue, :sales_units, :margin, :inventory_position, :cost_of_simulated_sale_units
      def initialize(revenue,sales_units,margin,inventory_position, cost_of_simulated_sale_units)
        @revenue = revenue
        @sales_units = sales_units 
        @margin = margin
        @inventory_position = inventory_position
        @cost_of_simulated_sale_units = cost_of_simulated_sale_units
      end

      def self.simulated_sales(sales_forecast, date_of_forecast, start_date, end_date, promotion_data,inventory_positions)
        PromotionCalculator.compute_promotional_sales(sales_forecast, date_of_forecast, start_date, end_date, promotion_data,inventory_positions)
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
