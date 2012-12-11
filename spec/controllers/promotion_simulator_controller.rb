require 'spec_helper'
class PromotionSimulatorControllerSpec

  describe ".compute_promotional_sales" do
    context "for a weekly date range" do
      it "should return simulated sales revenue for only that week" do
        sale = FactoryGirl.create(:product_weekly_sales_forecast)
        sales = [sale,sale,sale,sale,sale,sale]
        date_of_forecast = Date.new(2013,1,14)
        start_date = Date.new(2013,1,21)
        end_date = Date.new(2013,1,28)
        promotion_data = {"promotion_type" => "P", "promotion_percentage" => 10 }
        simulated_sales = Spree::Admin::PromotionSimulatorController.compute_promotional_sales(sales,date_of_forecast,start_date,end_date,promotion_data)

        simulated_sales.should_not be_empty
        simulated_sales[2].revenue.should eql 1460.0
      end
    end

    context "for a date range" do
      it "should return simulated sales revenue" do
        sale = FactoryGirl.create(:product_weekly_sales_forecast)
        sales = [sale,sale,sale,sale,sale,sale]
        date_of_forecast = Date.new(2013,1,14)
        start_date = Date.new(2013,1,25)
        end_date = Date.new(2013,2,02)
        promotion_data = {"promotion_type" => "P", "promotion_percentage" => 10 }
        simulated_sales = Spree::Admin::PromotionSimulatorController.compute_promotional_sales(sales,date_of_forecast,start_date,end_date,promotion_data)
        simulated_sales.should_not be_empty
        simulated_sales[1].revenue.should eql 1198.77
        simulated_sales[2].revenue.should eql 1397.55
      end
    end
    
  end
end
