module Spree
    module Admin
        class SimulationReport
            def initialize(product_id,date_of_forecast, cumulative_simulated_revenue, weekly_simulated_revenue)
                @product_id = product_id
                @date_of_forecast = date_of_forecast
                @cumulative_simulated_revenue = cumulative_simulated_revenue
                @weekly_simulated_revenue = weekly_simulated_revenue
            end
        end
    end
end


