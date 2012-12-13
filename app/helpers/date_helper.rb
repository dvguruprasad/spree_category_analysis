module Spree
  module Admin
    class  DateHelper
      def day_of_year(date)
        date.yday
      end
    end
  end
end

