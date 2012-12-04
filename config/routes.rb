Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "admin/assortment_map/:taxon_id", :to => "admin/assortment_map#index"
end
