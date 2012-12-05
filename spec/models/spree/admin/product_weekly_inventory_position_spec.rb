require 'spec_helper'

class ProductWeeklyInventoryPositionSpec
    describe Spree::Admin::ProductWeeklyInventoryPosition do
        context ".inventory_positions" do
            context "when inventory position available for all sales" do
                it "should return them" do
                    sales = []
                    sales << FactoryGirl.create(:product_weekly_sales, :week_start_date => Date.new(2012, 1, 14))
                    sales << FactoryGirl.create(:product_weekly_sales, :week_start_date => Date.new(2012, 1, 21))
                    FactoryGirl.create(:inventory_position, :week_start_date => Date.new(2012, 1, 14), :closing_position => 40)
                    FactoryGirl.create(:inventory_position, :week_start_date => Date.new(2012, 1, 21), :closing_position => 60)
                    inventory_positions = Spree::Admin::ProductWeeklyInventoryPosition.inventory_positions(sales)
                    inventory_positions.should_not be_nil
                    inventory_positions.should have(2).positions
                    inventory_positions.first.closing_position.should eql(40)
                    inventory_positions.last.closing_position.should eql(60)
                end
            end

            context "when sales forecasts and actual sales are passed" do
                it "should return computed inventory positions" do
                    sales = []
                    sales << FactoryGirl.create(:product_weekly_sales, :week_start_date => Date.new(2012, 1, 14), :sales_units => 20)
                    sales << FactoryGirl.create(:product_weekly_sales_forecast, :week_start_date => Date.new(2012, 1, 21), :sales_units => 50)
                    sales << FactoryGirl.create(:product_weekly_sales_forecast, :week_start_date => Date.new(2012, 1, 28), :sales_units => 30)
                    FactoryGirl.create(:inventory_position, :week_start_date => Date.new(2012, 1, 14), :closing_position => 40)
                    FactoryGirl.create(:inventory_replenishment, :replenishment_date => Date.new(2012, 1, 21), :quantity => 100)
                    inventory_positions = Spree::Admin::ProductWeeklyInventoryPosition.inventory_positions(sales)
                    inventory_positions.should_not be_nil
                    inventory_positions.should have(3).positions
                    inventory_positions[0].closing_position.should eql(40)
                    inventory_positions[1].closing_position.should eql(90)
                    inventory_positions[2].closing_position.should eql(60)
                end
            end

            context "when only sales forecasts are passed" do
                it "should return computed inventory positions" do
                    sales = []
                    sales << FactoryGirl.create(:product_weekly_sales_forecast, :week_start_date => Date.new(2012, 1, 14), :sales_units => 20)
                    sales << FactoryGirl.create(:product_weekly_sales_forecast, :week_start_date => Date.new(2012, 1, 21), :sales_units => 50)
                    sales << FactoryGirl.create(:product_weekly_sales_forecast, :week_start_date => Date.new(2012, 1, 28), :sales_units => 30)
                    FactoryGirl.create(:inventory_position, :week_start_date => Date.new(2011, 12, 31), :closing_position => 40)
                    FactoryGirl.create(:inventory_replenishment, :replenishment_date => Date.new(2012, 1, 21), :quantity => 100)
                    inventory_positions = Spree::Admin::ProductWeeklyInventoryPosition.inventory_positions(sales)
                    inventory_positions.should_not be_nil
                    inventory_positions.should have(3).positions
                    inventory_positions[0].closing_position.should eql(20)
                    inventory_positions[1].closing_position.should eql(70)
                    inventory_positions[2].closing_position.should eql(40)
                end
            end
        end
    end
end
