module Spree
    module Admin
        class AssortmentMapController < Spree::Admin::BaseController
            respond_to :json, :html

            def index
                taxon_id = params[:taxon_id]
                product_weely_sales_by_taxon_id = Spree::Admin::WeeklySales.by_taxon_id(taxon_id)
                if !product_weely_sales_by_taxon_id.nil? 
                    @data = create_chart_data(product_weely_sales_by_taxon_id).to_json
                end
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
