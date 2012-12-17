var show_sales_statistics = function(report){
    console.log(report);
    var total_sales = document.getElementById('total_sales');
    var target_sales = document.getElementById('target_sales');
    var reveneue_variation= document.getElementById('revenue_variation');
    var gross_profit = document.getElementById('gross_profit');
    var growth = document.getElementById('growth');
    var stock_out_of_date = document.getElementById('stock_out_of_date');
    var revenue_change = document.getElementById('revenue_change');
    var profit_change = document.getElementById('profit_change');
    var simulated_revenue = document.getElementById('simulated_revenue');
    var simulated_profit = document.getElementById('simulated_profit');

    total_sales.innerHTML = report.total_sales
    target_sales.innerHTML = report.target_sales
    reveneue_variation.innerHTML = report.revenue_variation
    gross_profit.innerHTML = report.gross_profit
    growth.innerHTML = report.growth_over_previous_period
    stock_out_of_date.innerHTML = report.stock_out_date
    revenue_change.innerHTML = report.promotional_revenue_change    
    profit_change.innerHTML = report.promotional_profit_change
    simulated_revenue.innerHTML = report.simulated_revenue
    simulated_profit.innerHTML = report.simulated_profit
};

