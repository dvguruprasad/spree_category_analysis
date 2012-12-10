FactoryGirl.define do
  factory :inventory_position, :class => Spree::Admin::ProductWeeklyInventoryPosition do |i|
      i.product_id 1111
      i.week_start_date Date.new(2012,1,7)
      i.closing_position 100
  end

  factory :inventory_replenishment, :class => Spree::Admin::InventoryReplenishment do |i|
      i.product_id 1111
      i.replenishment_date Date.new(2012,1,7)
      i.quantity 100
  end
end
