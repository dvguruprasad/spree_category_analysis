module Spree
    module Admin
        class AssortmentMapController < Spree::Admin::BaseController
            respond_to :json, :html

            def index
                @taxon = Spree::Taxon.find_by_id(Spree::Admin::WeeklySales.category_taxon_id)
                weekly_aggregate_for_category = WeeklySales.generate_category_aggregates()
                return if weekly_aggregate_for_category.nil? or weekly_aggregate_for_category.empty?
                @data = create_chart_data(weekly_aggregate_for_category)
                @year_to_date = Date.parse('2012-12-24').cweek * -1
                @time_start = @taxon.from_date(@year_to_date)
                @time_end = @taxon.to_date(@year_to_date)
                respond_with(@data.to_json)
            end

            def show
                @taxon = Spree::Taxon.find_by_id(params[:taxon_id])
                return if @taxon.nil?
                week = params[:week].to_i
                weekly_sales_for_taxon = @taxon.weekly_sales_by_time_frame(params[:week].to_i)
                weekly_aggregate_for_taxon = WeeklySales.generate_aggregates(weekly_sales_for_taxon)
                return if weekly_sales_for_taxon.nil? or weekly_sales_for_taxon.empty?
                if !weekly_aggregate_for_taxon.nil?
                    @data = create_chart_data(weekly_aggregate_for_taxon).to_json
                end
                @time_start = @taxon.from_date(week)
                @time_end = @taxon.to_date(week)
                @year_to_date =  Date.today.cweek * -1
                respond_with(@data)
            end

            def create_chart_data(sales_distribution)
                sales_distribution.map do |child_id, distribution|
                    color_value = ColorGenerator.generate(distribution["total_revenue"],distribution["total_target_revenue"])
                    profit = distribution["total_revenue"] - distribution["total_cost"]
                    profit_last_period = distribution["last_period_revenue"] - distribution["last_period_cost"]
                    label, @type = create_label_for_child(child_id)
                    revenue_change = distribution["last_period_revenue"]
                    profit_change = distribution["previous_period_profit"]
                    @legend = ColorGenerator.legend
                    p "###################### profits now:#{profit }   last period profits: #{profit_last_period}"
                    AssortmentReport.new(child_id,distribution["total_revenue"].round(2),label,'#' + color_value, distribution["total_target_revenue"],profit.round(2), revenue_change.round(2), profit_change.round(2), distribution["total_units"])
                end
            end

            def create_label_for_child(child_id)
                product = Spree::Product.find_by_id(child_id)
                if (!product.nil?) 
                    return product.name, "product"
                else
                    return Spree::Taxon.find(child_id).name, "taxon"
                end
            end

        end
    end
end
