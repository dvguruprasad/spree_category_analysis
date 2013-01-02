module Spree
  module Admin
    class CalendarPromotion
      def initialize(start_date,end_date,promotion_percentage)
        @start_date = start_date
        @end_date = end_date
        @promotion_percentage = promotion_percentage
      end
    end
  end
end
