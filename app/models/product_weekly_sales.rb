#class ProductWeeklySales < ActiveRecord::Base
#self.table_name = "spree_product_weekly_sales"

    #def self.sales_including_forecasts(week_start_date, number_of_weeks)
        #raise "week_start_date should be the beginning of a week(monday)" if week_start_date.beginning_of_week != week_start_date
        #sales = find(:all, :conditions => ["week_start_date >= ?", week_start_date]).take(number_of_weeks)
        #return sales if sales.count == number_of_weeks
        #forecast_start_date = sales.empty? ? week_start_date : sales.last.week_start_date + 7
        #forecasts = ProductWeeklySalesForecast.find(:all, :conditions => ["week_start_date >= ?", forecast_start_date]).take(number_of_weeks - sales.count)
        #sales + forecasts
    #end
#end
