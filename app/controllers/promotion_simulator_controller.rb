class PromotionSimulatorController < ApplicationController
    def index
        sales = ProductWeeklySales.sales_including_forecasts(Date.new(2013, 1, 7), 6)
    end
end
