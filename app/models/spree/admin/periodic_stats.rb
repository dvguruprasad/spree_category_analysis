module Spree
    module Admin
        class PeriodicStats

            def self.generate(weekly_sales)
                total_revenue = WeeklySales.total_revenue(weekly_sales).round(2)
                target_revenue = WeeklySales.total_target_revenue(weekly_sales).round(2)
                revenue_variation = (total_revenue - target_revenue).round(2)
                gross_profit = (total_revenue - WeeklySales.total_cost(weekly_sales)).round(2)
                growth_over_previous_period = WeeklySales.growth_over_previous_period(weekly_sales, gross_profit).round(2)
                stock_out_date = 15
                promotional_revenue_change  = 0
                promotional_profit_change = 0
                simulated_revenue = 0
                simulated_profit = 0
                {:total_sales => total_revenue, :target_sales=>target_revenue, :revenue_variation=>revenue_variation, :gross_profit=>gross_profit,
                 :growth_over_previous_period=>growth_over_previous_period, :stock_out_date=>stock_out_date,
                 :promotional_revenue_change=>promotional_revenue_change,
                 :promotional_profit_change=>promotional_profit_change,:simulated_profit =>simulated_profit,
                 :simulated_revenue => simulated_revenue}
            end

            def self.generate_with_promotion(weekly_sales, simulated_sales)
                total_revenue = WeeklySales.total_revenue(weekly_sales).round(2)
                target_revenue = WeeklySales.total_target_revenue(weekly_sales).round(2)

                revenue_variation = (total_revenue - target_revenue ).round(2)
                total_cost =  WeeklySales.total_cost(weekly_sales)
                gross_profit = (total_revenue - total_cost).round(2)
                growth_over_previous_period = WeeklySales.growth_over_previous_period(weekly_sales, gross_profit).round(2)

                stock_out_date = 15
                promotional_revenue_change = revenue_change(total_revenue, simulated_sales)
                promotional_profit_change = profit_after_simulation(simulated_sales, total_cost) - gross_profit

                simulated_revenue = simulated_sales.inject(0.0){|sum,s|sum + s.revenue}.round(2)
                simulated_profit =  profit_after_simulation(simulated_sales, total_cost)

                {:total_sales => total_revenue, :target_sales=>target_revenue, :revenue_variation=>revenue_variation, :gross_profit=>gross_profit,
                 :growth_over_previous_period=>growth_over_previous_period, :stock_out_date=>stock_out_date,
                 :promotional_revenue_change=>promotional_revenue_change,
                 :promotional_profit_change=>promotional_profit_change,
                 :simulated_revenue => simulated_revenue, :simulated_profit=> simulated_profit}
            end
            def self.revenue_change(total_revenue, simulated_sales)
                total_simulated_revenue = simulated_sales.each.inject(0.0){|sum,s|sum+s.revenue}
                total_simulated_revenue - total_revenue
            end

            def self.profit_after_simulation(simulated_sales, total_cost)
                total_simulated_revenue = simulated_sales.each.inject(0){|sum,s|sum+s.revenue}
                total_simulated_revenue - total_cost
            end

        end
    end
end

