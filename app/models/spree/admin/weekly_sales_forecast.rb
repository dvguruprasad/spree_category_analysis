module Spree
    module Admin
        class WeeklySalesForecast < ActiveRecord::Base
            self.table_name = "spree_weekly_sales_forecasts"
        end
    end
end
