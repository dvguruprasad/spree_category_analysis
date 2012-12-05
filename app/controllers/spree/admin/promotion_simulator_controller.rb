module Spree
    module Admin
        class PromotionSimulatorController < Spree::Admin::BaseController
            def index
                product = Product.find(params[:product_id])
                sales = ProductWeeklySales.sales_including_forecasts(product, Date.new(2013, 1, 14), 6)
                sum_target_revenue = 0.0
                @cumulative_targets = sales.map do |sale|
                    sale.target_revenue + sum_target_revenue
                    sum_target_revenue += sale.target_revenue
                end

                @inventory_positions = ProductWeeklyInventoryPosition.inventory_positions(sales).map{|p| p.closing_position * product.price}
            end

            private 
            def inventory_positions(product)

            end
        end
    end
end

