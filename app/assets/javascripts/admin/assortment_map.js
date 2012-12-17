$(function(){
    var render_tree_map = function(list, type) {

        $('div#treemap-div').treemap(list, {
            backgroundColor:function (node, box) {
                return node.color;
            },
            click:function (node, event) {
                if (type != "product")
                    window.location.href = "/admin/assortment_map/" + node.id + "/" + year_to_date;
            }
        });
    }
    var fill_hover_details = function(list){
        //console.log(list)
        //$('#weekly_range').buttonset();
        for(child=0;child<list.length;child++){
            var sales_span = '<span>' +'<h3><label> Total Revenue: </label>' + list[child].value +'</h3>'+'</span>';
            var total_target_span = '<span>' +'<h3><label> Total Target: </label>' + list[child].total_target +'</h3>'+'</span>';
            var revenue_diff_span = '<span>' +'<h3><label> Revenue Difference: </label>' + (list[child].total_target - list[child].value) +'</h3>'+'</span>';
            var profit_span = '<span>' +'<h3><label> Profit: </label>' + list[child].profit +'</h3>'+'</span>';
            var profit_change_span = '<span>' +'<h3><label> Profit Change: </label>' + list[child].profit_change +'</h3>'+'</span>';
            var revenue_change_span = '<span>' +'<h3><label> Revenue Change: </label>' + list[child].revenue_change +'</h3>'+'</span>';
            var hoverDiv = '<div id="'+list[child].id+'hover"  class="tooltip">' + sales_span + total_target_span + revenue_diff_span + revenue_change_span + profit_span + profit_change_span +'</div>';
            var id =  '#' + list[child].id ;
            //$(id).append(hoverDiv);
            $(id).hovercard({
                detailsHTML: hoverDiv,
                width: 400,
            });
            console.log($(id));
            //$(id).attr("title",hoverDiv);
        }
    }
    render_tree_map(list,type);
    fill_hover_details(list);
    //$(document).tooltip();
});

