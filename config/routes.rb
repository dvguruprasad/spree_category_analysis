Spree::Core::Engine.routes.draw do
  get "admin/promotion_simulator/:product_id", :to => "admin/promotion_simulator#index"
end
