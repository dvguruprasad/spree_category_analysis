module Spree
    module Admin
        class AssortmentMapController < ApplicationController
            respond_to :json, :html

            def index
                #taxon_id = params[:taxon_id]
                taxon_id = 558398391

                product_weely_sales_by_taxon_id = Spree::Admin::ProductWeeklySales.by_taxon_id(taxon_id)
                @data = create_chart_data(product_weely_sales_by_taxon_id).to_json
                respond_with(@data)
            end

            def create_chart_data(products_sales_distribution)
                products_sales_distribution.map do |product_id, distribution|
                    color_value = ColorGenerator.generate(distribution["total_revenue"],distribution["total_target_revenue"])
                    label = Spree::Product.select(:name).where("id = #{product_id}").first.name
                    AssortmentReport.new(product_id,distribution["total_revenue"],label,'#' + color_value)
                end
            end


        end
    end
end
