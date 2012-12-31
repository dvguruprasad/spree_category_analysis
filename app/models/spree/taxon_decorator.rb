Spree::Taxon.class_eval do
    has_many    :weekly_sales, :class_name => "Spree::Admin::WeeklySales", :foreign_key => "parent_id"
    has_many    :weekly_sales_forecasts, :class_name => "Spree::Admin::WeeklySalesForecasts", :foreign_key => "parent_id"

    def weekly_sales_by_time_frame(number_of_weeks_from_today)
        return if number_of_weeks_from_today == 0
        from_week_date = from_date(number_of_weeks_from_today)
        to_week_date = to_date(number_of_weeks_from_today)
        if number_of_weeks_from_today < 0
            Spree::Admin::WeeklySales.where("parent_id = ? and week_start_date >= ? and week_start_date < ?",id,from_week_date,to_week_date)
        else
            Spree::Admin::WeeklySalesForecast.where("parent_id = ? and week_start_date >= ? and week_start_date < ?",id,from_week_date,to_week_date)
        end
    end

    def from_date(week_number)
        if week_number < 0
            return Date.parse('2012-12-24') + 7 * week_number
        else
            return Date.parse('2012-12-24')
        end
    end

    def to_date(week_number)
        if week_number < 0
            return Date.parse('2012-12-24')
        else
            return Date.parse('2012-12-24') + 7 * week_number
        end
    end
end

