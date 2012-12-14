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
        promotion_data = {:promotion_type => "P", :promotion_percentage => 10 }
        simulated_sales = Spree::Admin::PromotionSimulatorController.compute_promotional_sales(sales,date_of_forecast,start_date,end_date,promotion_data)

        simulated_sales.should_not be_empty
        simulated_sales[1].revenue.should eql 1440.0
        simulated_sales[2].revenue.should eql 1062.86
        simulated_sales[3].revenue.should eql 1000.00
      end
    end

    context "for a date range with a promotion of less than 20 percentage" do
      it "should return simulated sales revenue" do
        sale = FactoryGirl.create(:product_weekly_sales_forecast)
        sales = [sale,sale,sale,sale,sale,sale]
        date_of_forecast = Date.new(2013,1,14)
        start_date = Date.new(2013,1,25)
        end_date = Date.new(2013,2,02)
        promotion_data = {:promotion_type => "P", :promotion_percentage => 10 }
        simulated_sales = Spree::Admin::PromotionSimulatorController.compute_promotional_sales(sales,date_of_forecast,start_date,end_date,promotion_data)
        simulated_sales.should_not be_empty
        simulated_sales[1].revenue.should eql 1188.57
        simulated_sales[2].revenue.should eql 1377.14
      end
    end

    context "for a date range with a promotion of more than 20 percentage" do
      it "should return simulated sales revenue" do
        sale = FactoryGirl.create(:product_weekly_sales_forecast)
        sales = [sale,sale,sale,sale,sale,sale]
        date_of_forecast = Date.new(2013,1,14)
        start_date = Date.new(2013,1,25)
        end_date = Date.new(2013,2,02)
        promotion_data = {:promotion_type => "P", :promotion_percentage => 30 }
        simulated_sales = Spree::Admin::PromotionSimulatorController.compute_promotional_sales(sales,date_of_forecast,start_date,end_date,promotion_data)
        simulated_sales.should_not be_empty
        simulated_sales[1].revenue.should eql 1812.05
        simulated_sales[2].revenue.should eql 2624.1
      end
    end
  end


   describe ".compute_promotional_margin" do
    context "for simulated weekly sale" do
      it "should return simulated margin revenue for the given week" do
        sale = FactoryGirl.create(:product_weekly_sales_forecast)
        sales = [sale,sale,sale,sale,sale,sale]
        simulated_sales = [sale.revenue*1.5, sale.revenue*1.5, sale.revenue*1.5, sale.revenue*1.5, sale.revenue*1.5,sale.revenue*1.5]
        simulated_margin = Spree::Admin::PromotionSimulatorController.compute_promotional_margin(sales, simulated_sales) 
        simulated_margin[1].should eql -500.0
        simulated_margin[2].should eql -500.0
        simulated_margin[3].should eql -500.0
      end
    end
   end
end
