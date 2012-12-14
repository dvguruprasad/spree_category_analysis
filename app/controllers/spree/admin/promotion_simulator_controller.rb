module Spree
  module Admin
    NUMBER_OF_DAYS_IN_WEEK = 7
    class PromotionSimulatorController < Spree::Admin::BaseController
      respond_to :json, :html
      before_filter :validate_get, :only => [:index, :simulate]

      def validate_get
        validated = params[:day].to_i <= 31 and params[:month].to_i <= 12 
        render_404 unless validated  #TODO change this to render_400 template
      end

      def index
        product_id = params[:product_id]
        product = Product.find_by_id(product_id)
        return "{}" if product.nil?
        date_of_forecast = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
        number_of_weeks = 6
        weekly_sales = WeeklySales.sales_including_forecasts(product_id, date_of_forecast, number_of_weeks)
        @jsonrep = create_forecast_chart_data(product,weekly_sales, date_of_forecast,number_of_weeks).to_json
        respond_with(@jsonrep)
      end

      def simulate
        return "{}" if params[:promotion_data].nil? or params[:product_id].nil?
        product_id = params[:product_id]
        product = Product.find_by_id(product_id)
        return "{}" if product.nil?
        start_date = Date.parse(params[:promotion_data][:start_date])
        end_date = Date.parse(params[:promotion_data][:end_date])
        date_of_forecast = Date.parse(params[:forecast_date])
        promotion_data = params[:promotion_data]
        number_of_weeks = 6
        weekly_sales = WeeklySales.sales_including_forecasts(product_id, date_of_forecast, number_of_weeks)
        @jsonrep = create_simulate_chart_data(product,weekly_sales, date_of_forecast,start_date, end_date, number_of_weeks,promotion_data).to_json
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

          daily_sales = sale.sales_units/NUMBER_OF_DAYS_IN_WEEK.round
          daily_promotional_sales = daily_sales * (1+ (6.25 ** promotion_percentage))

          promotion_revenue = daily_revenue_with_promotion(daily_sale_revenue,promotion_percentage,daily_sales, daily_promotional_sales)
          number_of_promotional_days = compute_promotional_days(start_week_number,start_date,date_of_forecast,ending_week_number,end_date,index)

          simulated_promotional_revenue = revenue_for_this_week(number_of_promotional_days,promotion_revenue, daily_sale_revenue) 
          #simulated_promotional_margin = margin_for_this_week(promotion_revenue,number_of_promotional_days,daily_sale_revenue)

        else
          sale.revenue
        end
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

      def self.daily_revenue_with_promotion(daily_sales_revenue, promotion_percentage, daily_sales, daily_promotional_sales)
        daily_sales_revenue*daily_promotional_sales*(1-promotion_percentage/100.to_f)/daily_sales
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

      private

      def create_forecast_chart_data(product,weekly_sales, date_of_forecast,number_of_weeks)
        sum_target_revenue = WeeklySales.aggregate_for_child(weekly_sales)["total_target_revenue"]
        weekly_target_revenue = weekly_sales.map { |s| s.target_revenue.round(2) }
        weekly_revenue = revenue_numbers(weekly_sales)
        cumulative_weekly_revenue = cumulative_revenue(weekly_sales)
        weekly_margin = weekly_margins(weekly_sales)
        cumulative_weekly_margin = cumulative_margin(weekly_margin)
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales).map { |p| p.closing_position }
        last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)
        cumulative_last_year_weekly_revenue = cumulative_revenue(last_year_sales)
        ForecastReport.new(product.id, sum_target_revenue, weekly_target_revenue, weekly_revenue, cumulative_weekly_revenue, weekly_margin, cumulative_weekly_margin, inventory_positions, cumulative_last_year_weekly_revenue,date_of_forecast)
      end

      def create_simulate_chart_data(product, weekly_sales, date_of_forecast, start_date, end_date, number_of_weeks,promotion_data)
        simulated_sales= PromotionSimulatorController.compute_promotional_sales(weekly_sales, date_of_forecast, start_date, end_date, promotion_data)
        weekly_simulated_revenue = simulated_sales.map{|s| s.revenue}
        cumulative_simulated_revenue = cumulative_revenue(simulated_sales)
        weekly_simulated_margin = PromotionSimulatorController.compute_promotional_sales(weekly_sales, date_of_forecast, start_date, end_date, promotion_data).map{|s| s.margin}
        SimulationReport.new(product.id, date_of_forecast, cumulative_simulated_revenue,weekly_simulated_revenue)
      end


      def cumulative_revenue(sales)
        sum_revenue = 0.0
        cumulative_sale = sales.map do |sale|
          sum_revenue += sale.revenue.round(2)
        end
      end

      def revenue_numbers(sales)
        sales.map { |s| s.revenue.round(2) }
      end

      def weekly_margins(sales)
        sales.map { |s| (s.revenue - s.cost).round(2) }
      end

      def cumulative_margin(weekly_margin)
        sum_margin = 0.0
        cumulative_margin = weekly_margin.map do |margin|
          sum_margin += margin.round(2)
        end
      end

    end
  end
end
