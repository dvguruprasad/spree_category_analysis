Spree::Core::Engine.routes.draw do
  get "admin/promotion_simulator/:product_id", :to => "admin/promotion_simulator#index"
  get "admin/assortment_map/:taxon_id", :to => "admin/assortment_map#index"
end
