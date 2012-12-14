module Spree
  module Admin
    NUMBER_OF_DAYS_IN_WEEK = 7
    class PromotionSimulatorController < Spree::Admin::BaseController
      respond_to :json, :html

      def index
        product_id = params[:product_id]
        product = Product.find(product_id)
        date_of_forecast = Date.new(2013, 1, 14)
        number_of_weeks = 6

        if(params[:promotion_data])
          start_date = Date.parse(params[:promotion_data][:start_date])

          start_date = Date.parse(params[:promotion_data][:start_date])
          end_date = Date.parse(params[:promotion_data][:end_date])
          promotion_data = params[:promotion_data]
        end

        start_of_year = date_of_forecast.beginning_of_year.to_json
        start_day = date_of_forecast.yday
        end_day = (date_of_forecast+number_of_weeks.weeks).yday

        weekly_sales = WeeklySales.new(:child_id => product_id)

        sales = weekly_sales.sales_including_forecasts(date_of_forecast, number_of_weeks)
        sum_target_revenue = weekly_sales.sum_target_revenue(date_of_forecast,number_of_weeks) 
        weekly_target_revenue = sales.map { |s| s.target_revenue.round(2) }

        sales_revenue = compute_sales_revenue(sales)
        cumulative_sale = compute_cumulative_sale(sales)
        sales_margin = compute_sales_margin(sales)

        cumulative_sales_margin = cumulative_sales_margin(sales_margin)

        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map { |p| p.closing_position }

        last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)

        sales_last_year = compute_sales_last_year(last_year_sales)
        if (params[:promotion_data])
          simulated = PromotionSimulatorController.compute_promotional_sales(sales, date_of_forecast, start_date, end_date, promotion_data)
          weekly_simulated_sales = simulated.map{|s| s.revenue}
          cumulative_simulated_sales = compute_cumulative_sale(simulated) 
          weekly_simulated_margin = simulated.map{|s| s.margin}
        end
        report = GraphReport.new(product_id, start_of_year, start_day, end_day, sum_target_revenue, weekly_target_revenue, sales_revenue, cumulative_sale, sales_margin, cumulative_sales_margin, inventory_positions, sales_last_year, weekly_simulated_sales, cumulative_simulated_sales, weekly_simulated_margin)


        @jsonrep = report.to_json
        respond_with(@jsonrep)
      end

      def self.compute_promotional_sales(sales_forecast, date_of_forecast, start_date, end_date, promotion_data)
        promotion_type = promotion_data[:promotion_type]
        promotion_percentage = promotion_data[:promotion_percentage].to_f
        days_from_forecast_to_start_date = (start_date - date_of_forecast)
        days_from_forecast_to_end_date = (end_date - date_of_forecast )

        start_week_number = (days_from_forecast_to_start_date/NUMBER_OF_DAYS_IN_WEEK).to_i
        ending_week_number = (days_from_forecast_to_end_date/NUMBER_OF_DAYS_IN_WEEK).to_i

        simulated_promotional_sales = []
        sales_forecast.each_with_index do |sale, index|
          promotional_revenue = compute_promotional_revenue(sale,start_week_number,ending_week_number,index,start_date,date_of_forecast,promotion_percentage,end_date)
          promotional_sales_units = compute_promotional_sales_units()
          promotional_margin = compute_promotional_margin(sale.revenue, promotional_revenue)
          sim_sales = SimulatedSales.new(promotional_revenue,promotional_sales_units, promotional_margin)
          simulated_promotional_sales << sim_sales
        end
        simulated_promotional_sales
      end

      def self.compute_promotional_revenue(sale,start_week_number,ending_week_number,index,start_date,date_of_forecast,promotion_percentage,end_date)
        if((start_week_number .. ending_week_number).include? index )
          daily_sale_revenue = sale.revenue/NUMBER_OF_DAYS_IN_WEEK  
          promotion_revenue = daily_revenue_with_promotion(daily_sale_revenue,promotion_percentage)

            if(index == start_week_number)
              number_of_promotional_days =  NUMBER_OF_DAYS_IN_WEEK - ((start_date - date_of_forecast)%NUMBER_OF_DAYS_IN_WEEK)
            elsif(index == ending_week_number)
              number_of_promotional_days =((end_date - date_of_forecast)+1)%NUMBER_OF_DAYS_IN_WEEK
            else
              number_of_promotional_days = NUMBER_OF_DAYS_IN_WEEK
            end
            revenue_for_this_week(number_of_promotional_days,promotion_revenue, daily_sale_revenue) 
          else
            sale.revenue
          end
      end

      def self.compute_promotional_sales_units
        200
      end
      def self.compute_promotional_margin(revenue, promotional_revenue) 
         100
      end


      def self.revenue_for_this_week(number_of_promotional_days,promotion_revenue,daily_sale_revenue)
        weekly_promotion_revenue = number_of_promotional_days * promotion_revenue
        weekly_revenue = (NUMBER_OF_DAYS_IN_WEEK - number_of_promotional_days) * daily_sale_revenue
        (weekly_revenue + weekly_promotion_revenue).round(2)
      end

      def self.daily_revenue_with_promotion(daily_sales_revenue, promotion_percentage)
        if(promotion_percentage < 20)
          1.6**(promotion_percentage/10.to_f) * daily_sales_revenue * (1-(promotion_percentage/100.to_f)) 
        else
          1.6**(2) * ((promotion_percentage-19)**0.2) * daily_sales_revenue * (1-promotion_percentage/100.to_f) 
        end
      end

      def compute_cumulative_sale(sales)
        cum_margin = []
        sum_revenue = 0.0
        cumulative_sale = sales.map do |sale|
          sum_revenue += sale.revenue.round(2)
          cum_margin << sum_revenue
        end
        cum_margin
      end

      def compute_sales_revenue(sales)
        sales.map { |s| s.revenue.round(2) }
      end

      def compute_sales_margin(sales)
        sales.map { |s| (s.revenue - s.cost).round(2) }
      end

      def cumulative_sales_margin(sales_margin)
        sum_margin = 0.0
        cumulative_sales_margin = sales_margin.map do |sale|
          sum_margin += sale.round(2)
        end
        sum_margin
      end

      def compute_sales_last_year(last_year_sales)
        sum_revenue = 0.0
        sales_last_year = last_year_sales.map do |sale|
          sum_revenue += sale.revenue.round(2)
        end
        sum_revenue
      end
    end
  end
end




