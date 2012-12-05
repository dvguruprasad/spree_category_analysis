require 'spec_helper'
module Spree
  module Admin
    class WeeklySalesSpec
      describe ".aggregate" do
        it "should return empty hash if there are no weekly sales" do
          sales_hash = WeeklySales.aggregate([])
          sales_hash.should be_empty
        end

        it "should return hash of weekly aggregate if only one week is given" do
          weekly_sales = FactoryGirl.create(:weekly_sales)

          sales_hash = WeeklySales.aggregate([weekly_sales])
          test_data = [1000.0, 1500.0, '2011-11-05', '2011-11-11', 1]

          assert_sales_hash(sales_hash, test_data)
        end

        it "should return hash of weekly aggregates if many weekSales are given" do
          weekly_sales1 = create_weekly_sales('2011-11-11', '2011-11-17')
          weekly_sales2 = create_weekly_sales('2011-11-18', '2011-11-24')
          weekly_sales3 = create_weekly_sales('2011-11-25', '2011-12-1')

          sales_hash = WeeklySales.aggregate([weekly_sales1, weekly_sales2, weekly_sales3])
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
      describe ".by_taxon_id" do
        it "should return empty hash if product sales for a taxon_id is not found" do
          FactoryGirl.create(:weekly_sales, :parent_id => '193485')

          aggregate_by_product = WeeklySales.by_taxon_id(558398391)

          aggregate_by_product.should be_empty
        end

        it "should return hash of aggregate sales with product_id if product sales for one product for a taxon_id exists" do
          create_weekly_sales_with_child_id(1111, '2011-11-11', '2011-11-17')
          create_weekly_sales_with_child_id(1111, '2011-11-18', '2011-11-14')
          create_weekly_sales_with_child_id(1111, '2011-11-25', '2011-12-1')

          aggregate_by_product = WeeklySales.by_taxon_id(9999)

          test_data = [3000.0, 4500.0, '2011-11-11', '2011-12-1', 3]
          assert_product_aggregates_with_product_id(1111, aggregate_by_product, test_data)
        end

        it "should return hash of aggregate sales with product_ids if product sales of multiple products for a taxon_id exists" do
          create_weekly_sales_with_child_id(1111, '2011-11-11', '2011-11-17')
          create_weekly_sales_with_child_id(2222, '2011-11-18', '2011-11-24')
          create_weekly_sales_with_child_id(3333, '2011-11-25', '2011-12-1')
          create_weekly_sales_with_child_id(3333, '2011-12-2', '2011-12-8')

          aggregate_by_product = WeeklySales.by_taxon_id(9999)

          test_data1 = [1000.0, 1500.0, '2011-11-11', '2011-11-17', 1]
          test_data2 = [1000.0, 1500.0, '2011-11-18', '2011-11-24', 1]
          test_data3 = [2000.0, 3000.0, '2011-11-25', '2011-12-8', 2]

          assert_product_aggregates_with_product_id(1111, aggregate_by_product, test_data1)
          assert_product_aggregates_with_product_id(2222, aggregate_by_product, test_data2)
          assert_product_aggregates_with_product_id(3333, aggregate_by_product, test_data3)
        end

        def create_weekly_sales_with_child_id(child_id, week_start_date, week_end_date)
          FactoryGirl.create(:weekly_sales, :child_id => child_id, :week_start_date => week_start_date, :week_end_date => week_end_date)
        end

        def assert_product_aggregates_with_product_id(p_id, aggregate_by_product, test_data)
          aggregate_by_product.should_not be_empty
          aggregate_by_product[p_id]["total_revenue"].should eql test_data[0]
          aggregate_by_product[p_id]["total_target_revenue"].should eql test_data[1]
          aggregate_by_product[p_id]["start_time"].should eql Date.parse(test_data[2])
          aggregate_by_product[p_id]["end_time"].should eql Date.parse(test_data[3])
          aggregate_by_product[p_id]["number_of_weeks"].should eql test_data[4]
        end
      end
    end
  end
end

