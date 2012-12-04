Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "/assortment_map", :to => "admin/assortment_map#index"
end
