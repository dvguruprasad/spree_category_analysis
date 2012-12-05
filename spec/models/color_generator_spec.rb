require 'spec_helper'

class ColorGeneratorSpec
    context ".generate" do
        it "is should return WHITE(ffffff) when actual and target are the same" do
            actual = 9999
            target = 9999
            ColorGenerator.generate(actual, target)
        end
    end
end
