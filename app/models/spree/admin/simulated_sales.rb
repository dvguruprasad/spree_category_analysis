module Spree
    module Admin
        class SimulatedSales
          attr_accessor :revenue, :sales_units, :margin 
          def initialize(revenue,sales_units,margin)
            @revenue = revenue
            @sales_units = sales_units 
            @margin = margin
          end

        end
    end
end
