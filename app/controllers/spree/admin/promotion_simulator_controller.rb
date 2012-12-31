module Spree
  module Admin
    NUMBER_OF_DAYS_IN_WEEK = 7
      REPORTING_WINDOW = 6 #TODO USEFUL if there is flexibility in choosing the reporting window
    class PromotionSimulatorController < Spree::Admin::BaseController
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
          date_of_forecast = param_date
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
        prom_data = params[:promotion_data]
        prom_data = [{}] if params[:promotion_data].nil?
        product_id = params[:product_id]
        product = Product.find_by_id(product_id)
        date_of_forecast = Date.parse(params[:forecast_date])
        return "{}" if product.nil?
        weekly_sales = WeeklySales.sales_including_forecasts(product_id, date_of_forecast, REPORTING_WINDOW)
        replenishments = params[:replenishment].collect{|x| x.to_i}
        
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales,replenishments).map { |p| p.closing_position }


        prom_data.each do|promotion_data|
          @simulation_response = percentage_promotion(product, product_id, promotion_data, date_of_forecast,inventory_positions,weekly_sales)
          simulated_inventory_positions = @simulation_response.simulated_inventory_positions
          inventory_positions.each_with_index do |inventory_position,index|
          inventory_position = simulated_inventory_positions[index]
          end

          simulated_sales = @simulation_response.weekly_simulated_revenue
          simulated_units = @simulation_response.sales_units

          weekly_sales.each_with_index do |sale,index|
            sale.revenue = simulated_sales[index]
            sale.sales_units = simulated_units[index]
          end
        end
        @jsonres = @simulation_response.to_json
        respond_with(@jsonres)
      end

      def percentage_promotion(product, product_id, promotion_data, date_of_forecast,inventory_positions,weekly_sales)
        if(promotion_data[1].nil? || promotion_data[1][:start_date].nil?)
          start_date =   Date.today
        else
          start_date =   Date.parse(promotion_data[1][:start_date])
        end
        if(promotion_data[1].nil? || promotion_data[1][:end_date].nil?)
          end_date =   Date.today
        else
          end_date =   Date.parse(promotion_data[1][:end_date])
        end
        create_simulation_chart_data(product, weekly_sales, date_of_forecast, start_date, end_date, promotion_data,inventory_positions)
      end



      private
      def report_forecasted_sales(product, date_of_forecast)
        back_date = date_of_forecast.beginning_of_week - REPORTING_WINDOW * NUMBER_OF_DAYS_IN_WEEK
        forward_date = date_of_forecast.beginning_of_week + REPORTING_WINDOW * NUMBER_OF_DAYS_IN_WEEK
        @back = "#{product.id}/#{back_date.day}/#{back_date.month}/#{back_date.year}"
        @forward = "#{product.id}/#{forward_date.day}/#{forward_date.month}/#{forward_date.year}"
        weekly_sales = WeeklySales.sales_including_forecasts(product.id, date_of_forecast, REPORTING_WINDOW)
        @replenishments = InventoryReplenishment.replenishments_for_period(product.id,date_of_forecast,REPORTING_WINDOW)
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
        replenishments = InventoryReplenishment.replenishments_for_period(product.id,date_of_forecast, REPORTING_WINDOW)
        replenishments = weekly_sales.count.times.collect{0} if replenishments.empty?
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales, replenishments).map { |p| p.closing_position }
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
        replenishments = InventoryReplenishment.replenishments_for_period(product.id,from_date, REPORTING_WINDOW)
        replenishments = weekly_sales.count.times.collect{0}
        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(weekly_sales, replenishments).map { |p| p.closing_position }
        last_year_sales = WeeklySales.sales_last_year(product, from_date, REPORTING_WINDOW)
        cumulative_last_year_revenue = cumulative_revenue(last_year_sales)
        weekly_last_year_revenue = revenue_numbers(last_year_sales)
        stats_report = PeriodicStats.generate(weekly_sales)
        PastReport.new(product.id, sum_target_revenue, weekly_target_revenue, weekly_revenue, cumulative_weekly_revenue, weekly_margin, cumulative_weekly_margin, inventory_positions, cumulative_last_year_revenue, weekly_last_year_revenue, from_date, stats_report)
      end

      def create_simulation_chart_data(product, weekly_sales, date_of_forecast, start_date, end_date, promotion_data_for_percentage,inventory_positions)
        simulated_sales= SimulatedSales.simulated_sales(weekly_sales, date_of_forecast, start_date, end_date, promotion_data_for_percentage, inventory_positions)

        weekly_simulated_sales_units = simulated_sales.map { |s| s.sales_units }
        weekly_simulated_revenue = simulated_sales.map { |s| s.revenue }
        cumulative_simulated_revenue = cumulative_revenue(simulated_sales)
        weekly_simulated_margin = simulated_sales.map { |s| s.margin }
        cumulative_simulated_margin = cumulative_margin(weekly_simulated_margin)
        simulated_inventory_positions= simulated_sales.map { |s| s.inventory_position }
        stock_out_date = stock_out_date(simulated_inventory_positions, date_of_forecast)
        stats_report = PeriodicStats.generate_with_promotion(weekly_sales, simulated_sales, stock_out_date)
        SimulationReport.new(product.id, date_of_forecast, cumulative_simulated_revenue, weekly_simulated_revenue, weekly_simulated_margin, cumulative_simulated_margin, stats_report, simulated_inventory_positions, weekly_simulated_sales_units)
      end

      def stock_out_date(simulated_inventory_positions, date_of_forecast)
        simulated_inventory_positions.each_with_index do |simulated_inventory_position, index|
          if simulated_inventory_position < 0
            for i in 1..7
            incremental_inventories =  simulated_inventory_positions[index - 1] - ((simulated_inventory_positions[index - 1]-simulated_inventory_position)/7)*i
              if incremental_inventories < 0
                return date_of_forecast+index*7+i
              end
            end
          end
        end
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
