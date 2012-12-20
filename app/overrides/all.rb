Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "promotion_simulator",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => '<li><a href="/admin/promotion_simulator/product/1060500711/14/1/2013">Promotion Simulator</a></li>')
#TODO: fix the promo over ride to point to a product list page and not a specific product
Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "assortment_map",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => '<li><a href="/admin/assortment_map">Assortment Map</a></li>')

