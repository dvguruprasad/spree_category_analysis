module Spree
  module Admin
    NUMBER_OF_DAYS_IN_WEEK = 7
    class PromotionSimulatorController < Spree::Admin::BaseController
      respond_to :json, :html
      b = 1.10305425242
      c = 2.17732421581

      def index
        product_id = params[:product_id]
        product = Product.find(product_id)
        date_of_forecast = Date.new(2013, 1, 14)
        number_of_weeks = 6
        if(params[:promotion_data])
          start_date = Date.parse(params[:promotion_data][:start_date])
          end_date = Date.parse(params[:promotion_data][:end_date])
          promotion_data = params[:promotion_data]
          promotion_percentage = params[:promotion_data][:promotion_percentage]
        end

        start_of_year = date_of_forecast.beginning_of_year.to_json
        start_day = date_of_forecast.yday
        end_day = (date_of_forecast+number_of_weeks.weeks).yday

        sales = WeeklySales.sales_including_forecasts(product, date_of_forecast, number_of_weeks)
        sum_target_revenue = sales.sum(&:target_revenue)

        weekly_target_revenue = sales.map { |s| s.target_revenue.round(2) }

        sales_revenue = compute_sales_revenue(sales)
        cumulative_sale = compute_cumulative_sale(sales)
        sales_margin = compute_sales_margin(sales)

        cumulative_sales_margin = cumulative_sales_margin(sales_margin)

        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map { |p| p.closing_position }

        last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)

        sales_last_year = compute_sales_last_year(last_year_sales)

        simulated_sales = compute_promotional_sales(sales, date_of_forecast).map { |s| s.revenue } if (params[:promotion_data])

        simulated_margin = compute_promotional_margin(sales_margin, date_of_forecast, start_date, end_date, promotion_data) if (params[:promotion_data])
        report = GraphReport.new(product_id, start_of_year, start_day, end_day, sum_target_revenue, weekly_target_revenue, sales_revenue, cumulative_sale, sales_margin, cumulative_sales_margin, inventory_positions, sales_last_year, simulated_sales, simulated_margin)


        @jsonrep = report.to_json
        respond_with(@jsonrep)
      end

      def self.compute_promotional_sales(sales_forecast, date_of_forecast, start_date, end_date, promotion_data)

        promotion_type = promotion_data[:promotion_type]
        promotion_percentage = promotion_data[:promotion_percentage]
        days_from_forecast_to_start_date = date_of_forecast - start_date
        days_from_forecast_to_end_date = date_of_forecast - end_date

        #i = days_from_forecast_to_end_date - days_from_forecast_to_start_date
        start_week_number = (days_from_forecast_to_start_date/NUMBER_OF_DAYS_IN_WEEK).to_i
        ending_week_number = (days_from_forecast_to_end_date/NUMBER_OF_DAYS_IN_WEEK).to_i

        sales_forecast.each_with_index do |sale, index|
          diff_bang = ending_week_number - start_week_number
          daily_sale_revenue = sale.revenue/NUMBER_OF_DAYS_IN_WEEK
          if (start_week_number+1 == index)
            sale.revenue = weekly_promotional_Sales(daily_sale_revenue, days_from_forecast_to_start_date, promotion_percentage)
          elsif (index == ending_week_number+1)
            sale.revenue = weekly_promotional_Sales(daily_sale_revenue, days_from_forecast_to_end_date, promotion_percentage)
          elsif (index - start_week_number+1 > diff_bang)
            sale.revenue = (daily_sale_revenue*(1+(b**promotion_percentage.to_i/c)).round(2))*NUMBER_OF_DAYS_IN_WEEK
          end
        end

        sales_forecast
      end

      def self.weekly_promotional_Sales(daily_sale_revenue, days_from_forecast_to_start_date, promotion_percentage)
        days_without_promotion = days_from_forecast_to_start_date - NUMBER_OF_DAYS_IN_WEEK*index
        days_with_promotion = NUMBER_OF_DAYS_IN_WEEK - days_without_promotion
        sales_without_promotion = daily_sale_revenue*days_without_promotion
        sales_with_promotion = (daily_sale_revenue*(1+(b**promotion_percentage.to_i/c)).round(2))*days_with_promotion
        sales_without_promotion+sales_with_promotion
    end


    def compute_cumulative_sale(sales)
      sum_revenue = 0.0
      cumulative_sale = sales.map do |sale|
        sum_revenue += sale.revenue.round(2)
      end
      sum_revenue
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


