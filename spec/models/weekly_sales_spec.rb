require 'spec_helper'
module Spree
    module Admin
        class WeeklySalesSpec
            describe ".aggregate" do
                it "should return empty hash if there are no weekly" do
                    sales_hash = WeeklySales.aggregate([])
                    sales_hash.should be_empty
                end

                it "should return hash of weekly aggregate if only one week is given" do
                    weekly_sales = FactoryGirl.create(:weekly_sales)
                    sales_hash = WeeklySales.aggregate([weekly_sales])

                    sales_hash.should_not be_empty
                    sales_hash["total_revenue"].should eql 1000.0
                    sales_hash["total_target_revenue"].should eql 1500.0
                    sales_hash["start_time"].should eql Date.parse('2011-11-5')
                    sales_hash["end_time"].should eql Date.parse('2011-11-11')
                    sales_hash["number_of_weeks"].should eql 1

                end

                it "should return hash of weekly aggregates if many weekSales are given" do
                    weekly_sales1 = FactoryGirl.create(:weekly_sales, :week_start_date => '2011-11-11', :week_end_date => '2011-11-17')
                    weekly_sales2 = FactoryGirl.create(:weekly_sales, :week_start_date => '2011-11-18', :week_end_date => '2011-11-24')
                    weekly_sales3 = FactoryGirl.create(:weekly_sales, :week_start_date => '2011-11-25', :week_end_date => '2011-12-1')
                    sales_hash = WeeklySales.aggregate([weekly_sales1,weekly_sales2,weekly_sales3])

                    sales_hash.should_not be_empty
                    sales_hash["total_revenue"].should eql 3000.0
                    sales_hash["total_target_revenue"].should eql 4500.0
                    sales_hash["start_time"].should eql Date.parse('2011-11-11')
                    sales_hash["end_time"].should eql Date.parse('2011-12-1')
                    sales_hash["number_of_weeks"].should eql 3

                end
            end
        end
    end
end

