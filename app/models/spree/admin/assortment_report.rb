module Spree
    module Admin
        class  AssortmentReport
            attr_accessor :id, :revenue,:label,:color,:target, :profit, :revenue_change, :profit_change, :units
            def initialize(id, revenue,label,color, target, profit, revenue_change,profit_change,units)
                @id = id
                @value = revenue
                @label = label
                @color = color
                @total_target = target
                @profit = profit
                @revenue_change = revenue_change
                @profit_change = profit_change
                @total_units = units

            end
        end
    end
end
