Spree::Taxon.class_eval do
    has_many    :weekly_sales, :class_name => "Spree::Admin::WeeklySales", :foreign_key => "parent_id"

    def weekly_sales_by_time_frame(number_of_weeks_from_today)
        from_week_date = from_date(number_of_weeks_from_today)
        #to_week_date = Date.today.beginning_of_week
        to_week_date = to_date(number_of_weeks_from_today)
        Spree::Admin::WeeklySales.where("parent_id = ? and week_start_date >= ? and week_start_date < ?",id,from_week_date,to_week_date)
    end

    def from_date(week_number)
        if week_number < 0
            return Date.today() + 7 * week_number
        else
            return Date.today()
        end
    end

    def to_date(week_number)
        if week_number < 0
            return Date.today()
        else
            return Date.today() + 7 * week_number
        end
    end
end

