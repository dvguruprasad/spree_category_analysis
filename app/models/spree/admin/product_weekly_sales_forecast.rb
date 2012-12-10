module Spree
    module Admin
        class ProductWeeklySalesForecast < ActiveRecord::Base
            self.table_name = "spree_product_weekly_sales_forecasts"
        end
    end
end
