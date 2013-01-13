module Spree
    module Admin
        class  AssortmentReport
            attr_accessor :id, :value,:label,:color,:total_target, :profit, :revenue_change, :profit_change, :total_units, :permalink, :revenue_difference,:percent_revenue_difference
            def initialize(id, revenue,label,color, target, profit, revenue_change, revenue_difference, profit_change,units,permalink)
                @id = id
                @value = revenue.round(2)
                @label = label
                @color = color
                @total_target = target.round(2)
                @profit = profit.round(2)
                @revenue_change = revenue_change.round(2)
                @revenue_difference = revenue_difference.round(2)
                @percent_revenue_difference = ((@revenue_difference/@total_target) * 100).round(2)
                @profit_change = profit_change.round(2)
                @total_units = units.round(2)
                @permalink = permalink

            end
        end
    end
end
