module Spree
  module Admin
    class SimulationReport
      def initialize(product_id,date_of_forecast, cumulative_simulated_revenue, weekly_simulated_revenue,weekly_simulated_margin, cumulative_simulated_margin,stats_report, simulated_inventory_positions)
        @product_id = product_id
        @date_of_forecast = date_of_forecast
        @cumulative_simulated_revenue = cumulative_simulated_revenue
        @weekly_simulated_revenue = weekly_simulated_revenue
        @weekly_simulated_margin = weekly_simulated_margin
        @cumulative_simulated_margin = cumulative_simulated_margin
        @simulated_inventory_positions = simulated_inventory_positions
        @stats_report = stats_report
      end
    end
  end
end


