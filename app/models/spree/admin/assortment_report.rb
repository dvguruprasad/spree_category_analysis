module Spree
    module Admin
        class  AssortmentReport
            attr_accessor :id, :revenue,:label,:color,:target, :profit, :revenue_change, :profit_change, :units, :permalink, :revenue_difference,:percent_revenue_difference
            def initialize(id, revenue,label,color, target, profit, revenue_change, revenue_difference, profit_change,units,permalink)
                @id = id
                @value = revenue
                @label = label
                @color = color
                @total_target = target
                @profit = profit
                @revenue_change = revenue_change
                @revenue_difference = revenue_difference
                @percent_revenue_difference = (@revenue_difference/@total_target).round(2)
                @profit_change = profit_change
                @total_units = units
                @permalink = permalink

            end
        end
    end
end
