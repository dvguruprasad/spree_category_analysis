module Spree
  module Admin
    class PromotionSimulatorController < Spree::Admin::BaseController
      respond_to :json, :html
      def index
        product_id = params[:product_id]
        product = Product.find(product_id) 
        date_of_forecast =  Date.new(2013, 1, 14)
        number_of_weeks = 6
        start_date = Date.parse(params[:promotion_data][:start_date])
        end_date = Date.parse(params[:promotion_data][:end_date])
        promotion_data = params[:promotion_data]
        promotion_percentage = params[:promotion_data][:promotion_percentage]

        start_of_year = date_of_forecast.beginning_of_year.to_json
        start_day = date_of_forecast.yday
        end_day = (date_of_forecast+number_of_weeks.weeks).yday

        sales = WeeklySales.sales_including_forecasts(product, date_of_forecast,number_of_weeks)
        sum_target_revenue = sales.sum(&:target_revenue)

        weekly_target_revenue = sales.map{|s| s.target_revenue.round(2)}

        sales_revenue =  compute_sales_revenue(sales)
        cumulative_sale = compute_cumulative_sale(sales)
        sales_margin = compute_sales_margin(sales)

        cumulative_sales_margin = cumulative_sales_margin(sales_margin)

        inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map{|p| p.closing_position}

        last_year_sales = WeeklySales.sales_last_year(product, date_of_forecast, number_of_weeks)

        sales_last_year = compute_sales_last_year(last_year_sales)

        simulated_sales = compute_promotional_sales(sales,date_of_forecast).map{|s| s.revenue} if(params[:promotion_data])
        
        simulated_margin = compute_promotional_margin(sales_margin,date_of_forecast,start_date,end_date,promotion_data) if(params[:promotion_data])
        report = GraphReport.new(product_id,start_of_year,start_day,end_day,sum_target_revenue,weekly_target_revenue,sales_revenue,cumulative_sale,sales_margin,cumulative_sales_margin,inventory_positions,sales_last_year,simulated_sales,simulated_margin)


        @jsonrep = report.to_json
        respond_with(@jsonrep)
      end

      def self.compute_promotional_sales(sales_forecast,date_of_forecast,start_date,end_date,promotion_data)
        b = 1.10305425242
        c = 2.17732421581
        promotion_type = promotion_data[:promotion_type]
        promotion_percentage = promotion_data[:promotion_percentage]
        i = (start_date -date_of_forecast).to_i
        week_number = (i/7)
        #sales_forecast[week_number].revenue = sales_forecast[week_number].revenue*(1+(b**promotion_percentage.to_i/c)).round(2)
        sales_forecast.each |sale,index| do
          week_start_date = date_of_forecast + index.weeks
          week_end_date = week_start_date + 6.days

          if(week_start_date > start_date && week_end_date < end_date)




          number_of_days = end_date - start_date

          promotion_value = 
        end
        #closer_week_to_start_date = x+7*(i/6).days
        #days_left = start_date - closer_week_to_start_date
        #apply_promotions(sales_forecast, days_left)
        #sales_forecast.map{|s|s.total_revenue*1.25}
        sales_forecast

      end

      def compute_cumulative_sale(sales)
        sum_revenue = 0.0
        cumulative_sale = sales.map do |sale|
          sum_revenue += sale.revenue.round(2)
        end
        sum_revenue
      end

      def compute_sales_revenue(sales)
        sales.map{|s| s.revenue.round(2)}
      end

      def compute_sales_margin(sales)
        sales.map{|s| (s.revenue - s.cost).round(2)}
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

