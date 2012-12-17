Spree::Core::Engine.routes.draw do
    get "admin/assortment_map/", :to => "admin/assortment_map#index"
    get "admin/assortment_map/:taxon_id/:week", :constraints => { :taxon_id => /\d+/ ,:week => /[-]?\d+/},:to => "admin/assortment_map#show"

    get "admin/promotion_simulator/product/:product_id/:day/:month/:year", :constraints => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }, :to => "admin/promotion_simulator#index"
    get "admin/promotion_simulator/product/:product_id/", :to => "admin/promotion_simulator#index"
    get "admin/promotion_simulator/simulate/", :to => "admin/promotion_simulator#simulate"

end
