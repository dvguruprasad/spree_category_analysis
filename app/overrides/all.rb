Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "promotion_simulator",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => '<%= tab :promotion_simulator, :route => :promotion_simulator %>')
#TODO: fix the promo over ride to point to a product list page and not a specific product
Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "assortment_map",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => '<%= tab :category_analysis, :route => :category_analysis %>')

