module Spree
    module Admin
        class ProductWeeklySales < ActiveRecord::Base
            self.table_name = "spree_product_weekly_sales"

            def self.sales_including_forecasts(product, week_start_date, number_of_weeks)
                raise "week_start_date should be the beginning of a week(monday)" if week_start_date.beginning_of_week != week_start_date
                sales = find(:all, :conditions => ["product_id = ? and week_start_date >= ?", product.id, week_start_date]).take(number_of_weeks)
                return sales if sales.count == number_of_weeks
                forecast_start_date = sales.empty? ? week_start_date : sales.last.week_start_date + 7
                forecasts = ProductWeeklySalesForecast.find(:all, :conditions => ["product_id = ? and week_start_date >= ?", product.id, forecast_start_date]).take(number_of_weeks - sales.count)
                sales + forecasts
            end

            def self.sales_last_year(product, week_start_date, number_of_weeks)
                raise "week_start_date should be the beginning of a week(monday)" if week_start_date.beginning_of_week != week_start_date
                last_year = week_start_date.prev_year.year
                week_count = week_start_date.cweek
                week_start_date_last_year = Date.commercial(last_year, week_count, 1)

                sales = find(:all, :conditions => ["product_id = ? and week_start_date >= ?", product.id, week_start_date_last_year]).take(number_of_weeks)
                sales
            end
            
        end
    end
end
