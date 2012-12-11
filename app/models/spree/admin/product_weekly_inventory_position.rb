module Spree
    module Admin
        class ProductWeeklyInventoryPosition < ActiveRecord::Base
            self.table_name = "spree_product_weekly_inventory_positions"

            attr_accessible :product_id, :closing_position, :week_start_date

            def self.inventory_positions(sales)
                dates = sales.map{|sale| "'#{sale.week_start_date}'" }.join(",")
                inventory_positions = ProductWeeklyInventoryPosition.find(:all, :conditions => ["week_start_date in (#{dates})"])
                return inventory_positions if inventory_positions.count == sales.count
                number_of_sales_left = sales.count - inventory_positions.count

                closing_position = inventory_positions.empty? ? closing_position(sales.first.child_id) : inventory_positions.last.closing_position
                remaining_inventory_positions = []
                inventory_positions.count.upto(sales.count - 1) do |index|
                    inventory_position_forecast = create_inventory_position(sales[index], closing_position)
                    closing_position = inventory_position_forecast.closing_position
                    remaining_inventory_positions << inventory_position_forecast

                end
                inventory_positions + remaining_inventory_positions
            end

            private
            def self.create_inventory_position(sale, closing_position)
                computed_inventory_position = closing_position - sale.sales_units + replenishment_if_any(sale)
                ProductWeeklyInventoryPosition.new(:product_id => sale.child_id,
                                                   :closing_position => computed_inventory_position, :week_start_date => sale.week_start_date)
            end

            def self.replenishment_if_any(sale)
                replenishment = InventoryReplenishment.find_by_product_id_and_replenishment_date(sale.child_id, sale.week_start_date)
                replenishment.nil? ? 0 : replenishment.quantity
            end

            def self.closing_position(product_id)
                Spree::Admin::ProductWeeklyInventoryPosition.last(:conditions => ["product_id = ?", product_id], :order => "week_start_date").closing_position
            end
        end
    end
end
