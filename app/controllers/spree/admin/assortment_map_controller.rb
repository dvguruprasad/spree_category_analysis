module Spree
    module Admin
        class AssortmentMapController < Spree::Admin::BaseController
            respond_to :json, :html

            def index
                taxon = Spree::Taxon.find(params[:taxon_id]) unless params[:taxon_id].nil?
                weekly_sales_for_taxon = taxon.weekly_sales
                weekly_aggregate_for_taxon = WeeklySales.generate_aggregates(weekly_sales_for_taxon)
                if !weekly_aggregate_for_taxon.nil?
                    @data = create_chart_data(weekly_aggregate_for_taxon).to_json
                end
                respond_with(@data)
            end

            def create_chart_data(sales_distribution)
                sales_distribution.map do |child_id, distribution|
                    color_value = ColorGenerator.generate(distribution["total_revenue"],distribution["total_target_revenue"])
                    label = create_label_for_child(child_id)
                    AssortmentReport.new(child_id,distribution["total_revenue"],label,'#' + color_value)
                end
            end

            def create_label_for_child(child_id)
                product = Spree::Product.find_by_id(child_id)
                if (!product.nil?)
                    return product.name
                else
                    return Spree::Taxon.find(child_id).name
                end
            end


        end
    end
end
