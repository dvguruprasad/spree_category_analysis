module Spree
    module Admin
        class AssortmentMapController < Spree::Admin::BaseController
            respond_to :json, :html

            def index
                @taxon = Spree::Taxon.find_by_id(Spree::Admin::WeeklySales.category_taxon_id)
                weekly_aggregate_for_category = WeeklySales.generate_category_aggregates()
                return if weekly_aggregate_for_category.nil? or weekly_aggregate_for_category.empty?
                @year_to_date = Date.today.cweek * -1 + 1
                @week = @year_to_date
                @data = create_chart_data(weekly_aggregate_for_category)
                @number_of_products = number_of_products_for_categories()
                current_view()
                respond_with(@data.to_json)
            end

            def show
                @taxon = Spree::Taxon.find_by_id(params[:taxon_id])
                return if @taxon.nil?
                @week = params[:week].to_i
                weekly_sales_for_taxon = @taxon.weekly_sales_by_time_frame(@week)
                weekly_aggregate_for_taxon = WeeklySales.generate_aggregates(weekly_sales_for_taxon)
                return if weekly_sales_for_taxon.nil? or weekly_sales_for_taxon.empty?
                @year_to_date =  Date.today.cweek * -1 + 1
                if !weekly_aggregate_for_taxon.nil?
                    @data = create_chart_data(weekly_aggregate_for_taxon).to_json
                end
                current_view()
                respond_with(@data)
            end

            def create_chart_data(sales_distribution)
                @time_start = @taxon.from_date(@week)
                @time_end = @taxon.to_date(@week)
                @period = "#{@time_start.strftime('%d %b %y')} to #{@time_end.strftime('%d %b %y')}"
                @ancestory = ancestory_list(@taxon)
                sales_distribution.map do |child_id, distribution|
                    color_value = ColorGenerator.generate(distribution["total_revenue"],distribution["total_target_revenue"])
                    profit = distribution["total_revenue"] - distribution["total_cost"]
                    profit_last_period = distribution["last_period_revenue"] - distribution["last_period_cost"]
                    label, @type = create_label_for_child(child_id)
                    revenue_change = distribution["last_period_revenue"]
                    revenue_difference = distribution["total_revenue"] - distribution["total_target_revenue"]
                    profit_change = distribution["previous_period_profit"]
                    @legend = ColorGenerator.legend
                    permalink = "#"
                    permalink = "/admin/assortment_map/#{child_id}/#{@year_to_date}" if @type == "taxon" and has_assortment_map?(child_id)
                    p "year to date #{@year_to_date}"
                    p "###################### profits now:#{profit }   last period profits: #{profit_last_period}"
                    AssortmentReport.new(child_id,distribution["total_revenue"].round(2),label,'#' + color_value, distribution["total_target_revenue"],profit.round(2), revenue_change.round(2), revenue_difference.round(2),profit_change.round(2), distribution["total_units"], permalink)
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

            def ancestory_list(taxon)
                ancestory = {}
                taxon.ancestors.each do |t|
                    if t.id == Spree::Admin::WeeklySales.category_taxon_id
                        ancestory["Home"]= "/admin/assortment_map"
                    elsif has_assortment_map?(t.id)
                        ancestory[t.name]= "/admin/assortment_map/#{t.id}/#{@year_to_date}"
                    else
                        ancestory[t.name] = "#"
                    end
                end
                if taxon.id == Spree::Admin::WeeklySales.category_taxon_id
                    ancestory["Home"]= "/admin/assortment_map"
                elsif has_assortment_map?(taxon.id)
                    ancestory[taxon.name]= "/admin/assortment_map/#{taxon.id}/#{@year_to_date}"
                else
                    ancestory[taxon.name] = "#"
                end
                ancestory
            end
            def has_assortment_map?(taxon_id)
                !Spree::Admin::WeeklySales.find_by_parent_id(taxon_id).nil?
            end
            def number_of_products_for_categories
                product_count_hash = {}
                taxons_under_categories = Spree::Taxon.find_all_by_parent_id(Spree::Admin::WeeklySales.category_taxon_id)
                taxons_under_categories.map do |taxon|
                    product_count_hash[taxon.id] = Spree::Product.in_taxon(taxon).count
                end
                product_count_hash
            end
            def current_view
                @current_view = {"last_week" => '',"last_four_weeks" => '', "next_week" => '', "next_four_weeks" => '', "year_to_date" => ''}
                if(@year_to_date == @week)
                    @current_view["year_to_date"] = 'selected'
                elsif(@week == -1)
                    @current_view["last_week"] = 'selected'
                elsif(@week == -4)
                    @current_view["last_four_weeks"] = 'selected'
                elsif(@week == 1)
                    @current_view["next_week"] = 'selected'
                elsif(@week == 4)
                    @current_view["next_four_weeks"] = 'selected'
                end

            end
        end
    end
end
