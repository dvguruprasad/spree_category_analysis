Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "admin/assortment_map/", :to => "admin/assortment_map#index"
  get "admin/assortment_map/:taxon_id/:week", :constraints => { :taxon_id => /\d+/ ,:week => /[-]?\d+/},:to => "admin/assortment_map#show"
end
