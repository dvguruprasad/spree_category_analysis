module Spree
    module Admin
        class InventoryReplenishment < ActiveRecord::Base
            self.table_name = "spree_inventory_replenishments"

            def self.replenishments_for_period(product_id,date_of_forecast, reporting_window)
                raise "forecast date should be the beginning of a week(monday)" if date_of_forecast.beginning_of_week != date_of_forecast
                forecast_end_date = date_of_forecast + reporting_window * 7
                planned_replenishments = self.where("product_id = #{product_id} and replenishment_date >= '#{date_of_forecast}' and replenishment_date < '#{forecast_end_date}'")
                quantities = Array.new(reporting_window,0)
                reporting_window.times do |i|
                    quantity = quantity_for_week(date_of_forecast + i*7,planned_replenishments)
                    quantities[i] += quantity unless quantity.nil?
                end
                quantities
            end
            def self.quantity_for_week(date, replenishments)
                index = replenishments.index do |r|
                    r.replenishment_date.beginning_of_week == date.beginning_of_week
                end
                replenishments[index].quantity unless index.nil?
            end
        end
    end
end
