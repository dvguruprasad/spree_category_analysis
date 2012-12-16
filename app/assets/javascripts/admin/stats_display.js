window.onload = function(){
    console.log(response);
    var total_sales = document.getElementById('total_sales');
    var target_sales = document.getElementById('target_sales');
    var gap = document.getElementById('gap');
    var gross_profit = document.getElementById('gross_profit');
    var growth = document.getElementById('growth');
    var stock_out_of_date = document.getElementById('stock_out_of_date');
    var revenue_increase = document.getElementById('revenue_increase');
    var profit_increase = document.getElementById('profit_increase');

    total_sales.innerHTML = response.stats_report.total_sales
    target_sales.innerHTML = response.stats_report.target_sales
    gap.innerHTML = response.stats_report.gap
    gross_profit.innerHTML = response.stats_report.gross_profit
    growth.innerHTML = response.stats_report.growth_over_previous_period
    stock_out_of_date.innerHTML = response.stats_report.stock_out_date
    revenue_increase.innerHTML = response.stats_report.revenue_increase_out_of_promotion
    profit_increase.innerHTML = response.stats_report.profit_increase_out_of_promotion
}
