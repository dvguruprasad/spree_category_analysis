module Spree
  module Admin
   class PeriodicStats

     def self.generate()
      total_sales = 10
      target_sales = 11
      gap  = 12
      gross_profit = 13
      growth_over_previous_period = 14
      stock_out_date = 15
      revenue_increase_out_of_promotion = 0
      profit_increase_out_of_promotion = 0
      {:total_sales => total_sales, :target_sales=>target_sales, :gap=>gap, :gross_profit=>gross_profit,
       :growth_over_previous_period=>growth_over_previous_period, :stock_out_date=>stock_out_date,
       :revenue_increase_out_of_promotion=>revenue_increase_out_of_promotion,
       :profit_increase_out_of_promotion=>profit_increase_out_of_promotion}
     end

     def self.generate_with_promotion()
       total_sales = 10
       target_sales = 11
       gap  = 12
       gross_profit = 13
       growth_over_previous_period = 14
       stock_out_date = 15
       revenue_increase_out_of_promotion = 16
       profit_increase_out_of_promotion = 17
       {:total_sales => total_sales, :target_sales=>target_sales, :gap=>gap, :gross_profit=>gross_profit,
        :growth_over_previous_period=>growth_over_previous_period, :stock_out_date=>stock_out_date,
        :revenue_increase_out_of_promotion=>revenue_increase_out_of_promotion,
        :profit_increase_out_of_promotion=>profit_increase_out_of_promotion}
     end

   end
  end
end

