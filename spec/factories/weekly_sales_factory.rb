FactoryGirl.define do
    factory :weekly_sales, :class => Spree::Admin::WeeklySales do |s|
        s.child_id 1111
        s.parent_id 9999
        s.week_start_date '2011-11-5'
        s.week_end_date '2011-11-11'
        s.sales_units 100
        s.target_sales_units 150
        s.revenue 1000.0
        s.target_revenue 1500.0
        s.cost 800.0
    end
end
