module Spree
  module Admin
    NUMBER_OF_DAYS_IN_WEEK = 7
    class PromotionSimulatorController < Spree::Admin::BaseController
      REPORTING_WINDOW = 6 #TODO USEFUL if there is flexibility in choosing the reporting window
      respond_to :json, :html
      before_filter :validate_get, :only => [:index, :simulate]

      def validate_get
        validated = params[:day].to_i <= 31 and params[:month].to_i <= 12
        render_404 unless validated #TODO change this to render_400 template
      end

      def index
        product_id = params[:product_id]
        product = Product.find_by_id(product_id)
        return "{}" if product.nil?
        @mode = "simulation"
        if params.has_key?(:year)
          param_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
          if param_date.past?
            @jsonrep = report_past_sales(product, param_date)
            @mode = "report"
          else
            @jsonrep = report_forecasted_sales(product, param_date)
          end
        else
          date_of_forecast = Date.today().beginning_of_week
          @jsonrep = report_forecasted_sales(product, date_of_forecast)
        end
        respond_with(@jsonrep)
      end

      def simulate
        return "{}" if params[:promo_data].nil?
        product_id = params[:product_id]
        product = Product.find_by_id(product_id)
        date_of_forecast = Date.parse(params[:forecast_date])
        return "{}" if product.nil?


        params[:promo_data].each do|promo_data|


        @jsonrep = percentage_promotion(product, product_id, promo_data[1], date_of_forecast).to_json
        end


        respond_with(@jsonrep)
      end

      def percentage_promotion(product, product_id, promo_data, date_of_forecast)

        start_date = Date.parse(promo_data[:start_date])
        end_date = Date.parse(promo_data[:end_date])


        weekly_sales = WeeklySales.sales_including_forecasts(product_id, date_of_forecast, REPORTING_WINDOW)
        create_simulation_chart_data(product, weekly_sales, date_of_forecast, start_date, end_date, promo_data)
      end



      private
      def report_forecasted_sales(product, date_of_forecast)
        back_date = date_of_forecast.beginning_of_week - REPORTING_WINDOW * NUMBER_OF_DAYS_IN_WEEK
        forward_date = date_of_forecast.beginning_of_week + REPORTING_WINDOW * NUMBER_OF_DAYS_IN_WEEK
        @back = "#{product.id}/#{back_date.day}/#{back_date.month}/#{back_date.year}"
        @forward = "#{product.id}/#{forward_date.day}/#{forward_date.month}/#{forward_date.year}"
        weekly_sales = WeeklySales.sales_including_forecasts(product.id, date_of_forecast, REPORTING_WINDOW)
        create_forecast_chart_data(product, weekly_sales, date_of_forecast).to_json
      end

      def report_past_sales(product, from_date)
        back_date = from_date.beginning_of_week - REPORTING_WINDOW * NUMBER_OF_DAYS_IN_WEEK
        forward_date = from_date.beginning_of_week + REPORTING_WINDOW * NUMBER_OF_DAYS_IN_WEEK
        @back = "#{product.id}/#{back_date.day}/#{back_date.month}/#{back_date.year}"
        @forward = "#{product.id}/#{forward_date.day}/#{forward_date.month}/#{forward_date.year}"
        weekly_sales = WeeklySales.sales_including_forecasts(product.id, from_date, REPORTING_WINDOW)
        create_reporting_chart_data(product, weekly_sales, from_date).to_json
      end

      def create_forecast_chart_data(product, weekly_sales, date_of_forecast)
        sum_target_revenue = WeeklySales.aggregate_for_child(weekly_sales)["total_target_revenue"]
        weekly_target_revenue = weekly_sales.map { |s| s.target_revenue.round(2) }
        weekly_revenue = revenue_numbers(weekly_sales)
        cumulative_weekly_revenue = cumulative_revenue(weekly_sales)
        weekly_margin = weekly_margins(weekly_sales)
        cumulative_weekly_margin = cumulative_margin(weekly_margin)
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales).map { |p| p.closing_position }
        last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, REPORTING_WINDOW)
        weekly_last_year_revenue = revenue_numbers(last_year_sales)
        cumulative_last_year_revenue = cumulative_revenue(last_year_sales)
        stats_report = PeriodicStats.generate(weekly_sales)
        ForecastReport.new(product.id, sum_target_revenue, weekly_target_revenue, weekly_revenue,
                           cumulative_weekly_revenue, weekly_margin, cumulative_weekly_margin, inventory_positions,
                           cumulative_last_year_revenue, weekly_last_year_revenue, date_of_forecast, stats_report)
      end

      def create_reporting_chart_data(product, weekly_sales, from_date)
        sum_target_revenue = WeeklySales.aggregate_for_child(weekly_sales)["total_target_revenue"]
        weekly_target_revenue = weekly_sales.map { |s| s.target_revenue.round(2) }
        weekly_revenue = revenue_numbers(weekly_sales)
        cumulative_weekly_revenue = cumulative_revenue(weekly_sales)
        weekly_margin = weekly_margins(weekly_sales)
        cumulative_weekly_margin = cumulative_margin(weekly_margin)
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales).map { |p| p.closing_position }
        last_year_sales = WeeklySales.sales_last_year(product, from_date, REPORTING_WINDOW)
        cumulative_last_year_revenue = cumulative_revenue(last_year_sales)
        weekly_last_year_revenue = revenue_numbers(last_year_sales)
        stats_report = PeriodicStats.generate(weekly_sales)
        PastReport.new(product.id, sum_target_revenue, weekly_target_revenue, weekly_revenue, cumulative_weekly_revenue, weekly_margin, cumulative_weekly_margin, inventory_positions, cumulative_last_year_revenue, weekly_last_year_revenue, from_date, stats_report)
      end

      def create_simulation_chart_data(product, weekly_sales, date_of_forecast, start_date, end_date, promotion_data_for_percentage)
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales).map { |p| p.closing_position }
        simulated_sales= SimulatedSales.simulated_sales(weekly_sales, date_of_forecast, start_date, end_date, promotion_data_for_percentage, inventory_positions)

        weekly_simulated_revenue = simulated_sales.map { |s| s.revenue }
        cumulative_simulated_revenue = cumulative_revenue(simulated_sales)
        weekly_simulated_margin = simulated_sales.map { |s| s.margin }
        cumulative_simulated_margin = cumulative_margin(weekly_simulated_margin)
        simulated_inventory_positions= simulated_sales.map { |s| s.inventory_position }

        stats_report = PeriodicStats.generate_with_promotion(weekly_sales, simulated_sales)
        SimulationReport.new(product.id, date_of_forecast, cumulative_simulated_revenue, weekly_simulated_revenue, weekly_simulated_margin, cumulative_simulated_margin, stats_report, simulated_inventory_positions)
      end

      def new_simulated_chart_data(quantity_chart, percentage_chart)

      end


      def revenue_numbers(sales)
        sales.map { |s| s.revenue.round(2) }
      end

      def weekly_margins(sales)
        sales.map { |s| (s.revenue - s.cost).round(2) }
      end

      def cumulative_revenue(sales)
        sum_revenue = 0.0
        sales.map do |sale|
          sum_revenue += sale.revenue.round(2)
        end
      end

      def cumulative_margin(weekly_margin)
        sum_margin = 0.0
        weekly_margin.map do |margin|
          sum_margin += margin.round(2)
        end
      end

    end
  end
end
