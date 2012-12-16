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

        @jsonrep = create_forecast_chart_data(product,weekly_sales, date_of_forecast,number_of_weeks,).to_json
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
        stats_report = StatsToDisplay.generate()
        ForecastReport.new(product.id, sum_target_revenue, weekly_target_revenue, weekly_revenue,
                           cumulative_weekly_revenue, weekly_margin, cumulative_weekly_margin, inventory_positions,
                           cumulative_last_year_weekly_revenue,date_of_forecast,stats_report)
      end

      def create_simulate_chart_data(product, weekly_sales, date_of_forecast, start_date, end_date, number_of_weeks,promotion_data)
        simulated_sales= SimulatedSales.simulated_sales(weekly_sales, date_of_forecast, start_date, end_date, promotion_data)
        weekly_simulated_revenue = simulated_sales.map{|s| s.revenue}
        cumulative_simulated_revenue = cumulative_revenue(simulated_sales)
        weekly_simulated_margin = SimulatedSales.simulated_sales(weekly_sales, date_of_forecast, start_date, end_date, promotion_data).map{|s| s.margin}
        stats_report = StatsToDisplay.generate_with_promotion()
        SimulationReport.new(product.id, date_of_forecast, cumulative_simulated_revenue,weekly_simulated_revenue,stats_report)
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
