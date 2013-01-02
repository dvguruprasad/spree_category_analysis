module Spree
    module Admin
        class ForecastReport
            def initialize(product_id, sum_target_revenue, weekly_target_revenue, weekly_revenue,
                           cumulative_weekly_revenue,weekly_margin, cumulative_weekly_margin, inventory_positions,
                           cumulative_last_year_revenue,weekly_last_year_revenue, date_of_forecast,stats_report
                           )
                @product_id = product_id
                @sum_target_revenue = sum_target_revenue
                @weekly_target_revenue = weekly_target_revenue
                @weekly_revenue = weekly_revenue
                @cumulative_weekly_revenue = cumulative_weekly_revenue
                @weekly_margin =  weekly_margin
                @cumulative_weekly_margin = cumulative_weekly_margin
                @inventory_positions = inventory_positions
                @cumulative_last_year_revenue = cumulative_last_year_revenue
                @weekly_last_year_revenue = weekly_last_year_revenue
                @date_of_forecast = date_of_forecast
                @stats_report = stats_report
            end
        end
    end
end

