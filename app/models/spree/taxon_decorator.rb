Spree::Taxon.class_eval do
    has_many    :weekly_sales, :class_name => "Spree::Admin::WeeklySales", :foreign_key => "parent_id" 
end

