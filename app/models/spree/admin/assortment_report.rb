module Spree
    module Admin
        class  AssortmentReport
            def initialize(id, value,label,color)
                @id = id
                @value = value
                @label = label
                @color = color
            end
        end
    end
end
