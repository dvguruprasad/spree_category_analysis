require 'spec_helper'
module Spree
    module Admin
        class WeeklySalesSpec
            describe ".generate_aggregates" do
                it "should return empty hash if weekly sales is empty" do
                    aggregate_sales = WeeklySales.generate_aggregates([])

                    aggregate_sales.should be_empty
                end

                it "should return hash of aggregate sales with child_id if weekly sales for one child exists" do
                    weekly_sales1 = create_weekly_sales_with_child_id(1111, '2011-11-11', '2011-11-17')
                    weekly_sales2 = create_weekly_sales_with_child_id(1111, '2011-11-18', '2011-11-14')
                    weekly_sales3 = create_weekly_sales_with_child_id(1111, '2011-11-25', '2011-12-1')

                    aggregate_sales = WeeklySales.generate_aggregates([weekly_sales1, weekly_sales2, weekly_sales3])

                    test_data = [3000.0, 4500.0, '2011-11-11', '2011-12-1', 3]
                    assert_sales_aggregates_by_child(1111, aggregate_sales, test_data)
                end

                it "should return hash of aggregate sales with child_ids if weekly sales of multiple child_ids exist" do
                    weekly_sales1 = create_weekly_sales_with_child_id(1111, '2011-11-11', '2011-11-17')
                    weekly_sales2 = create_weekly_sales_with_child_id(2222, '2011-11-18', '2011-11-24')
                    weekly_sales3 = create_weekly_sales_with_child_id(3333, '2011-11-25', '2011-12-1')
                    weekly_sales4 = create_weekly_sales_with_child_id(3333, '2011-12-2', '2011-12-8')

                    aggregate_sales = WeeklySales.generate_aggregates([weekly_sales1, weekly_sales2, weekly_sales3,weekly_sales4])

                    test_data1 = [1000.0, 1500.0, '2011-11-11', '2011-11-17', 1]
                    test_data2 = [1000.0, 1500.0, '2011-11-18', '2011-11-24', 1]
                    test_data3 = [2000.0, 3000.0, '2011-11-25', '2011-12-8', 2]

                    assert_sales_aggregates_by_child(1111, aggregate_sales, test_data1)
                    assert_sales_aggregates_by_child(2222, aggregate_sales, test_data2)
                    assert_sales_aggregates_by_child(3333, aggregate_sales, test_data3)
                end

                def create_weekly_sales_with_child_id(child_id, week_start_date, week_end_date)
                    FactoryGirl.create(:weekly_sales, :child_id => child_id, :week_start_date => week_start_date, :week_end_date => week_end_date)
                end

                def assert_sales_aggregates_by_child(p_id, aggregate_sales, test_data)
                    aggregate_sales.should_not be_empty
                    aggregate_sales[p_id]["total_revenue"].should eql test_data[0]
                    aggregate_sales[p_id]["total_target_revenue"].should eql test_data[1]
                    aggregate_sales[p_id]["start_time"].should eql Date.parse(test_data[2])
                    aggregate_sales[p_id]["end_time"].should eql Date.parse(test_data[3])
                    aggregate_sales[p_id]["number_of_weeks"].should eql test_data[4]
                end
            end

            describe ".aggregate_for_child" do
                it "should return empty hash if there are no weekly sales" do
                    sales_hash = WeeklySales.aggregate_for_child([])
                    sales_hash.should be_empty
                end

                it "should return hash of weekly aggregate if only one week is given" do
                    weekly_sales = FactoryGirl.create(:weekly_sales)

                    sales_hash = WeeklySales.aggregate_for_child([weekly_sales])
                    test_data = [1000.0, 1500.0, '2011-11-05', '2011-11-11', 1]

                    assert_sales_hash(sales_hash, test_data)
                end

                it "should return hash of weekly aggregate_for_childs if many weekSales are given" do
                    weekly_sales1 = create_weekly_sales('2011-11-11', '2011-11-17')
                    weekly_sales2 = create_weekly_sales('2011-11-18', '2011-11-24')
                    weekly_sales3 = create_weekly_sales('2011-11-25', '2011-12-1')

                    sales_hash = WeeklySales.aggregate_for_child([weekly_sales1, weekly_sales2, weekly_sales3])
                    test_data = [3000.0, 4500.0, '2011-11-11', '2011-12-1', 3]

                    assert_sales_hash(sales_hash, test_data)
                end

                def create_weekly_sales(week_start_date, week_end_date)
                    FactoryGirl.create(:weekly_sales, :week_start_date => week_start_date, :week_end_date => week_end_date)
                end

                def assert_sales_hash(sales_hash, test_data)
                    sales_hash.should_not be_empty
                    sales_hash["total_revenue"].should eql test_data[0]
                    sales_hash["total_target_revenue"].should eql test_data[1]
                    sales_hash["start_time"].should eql Date.parse(test_data[2])
                    sales_hash["end_time"].should eql Date.parse(test_data[3])
                    sales_hash["number_of_weeks"].should eql test_data[4]
                end
            end

        end
    end
end

