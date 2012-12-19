$(function(){
    var render_tree_map = function(list, type) {

        $('div#treemap-div').treemap(list, {
            backgroundColor:function (node, box) {
                return node.color;
            },
            click:function (node, event) {


                if (type != "product"){
                    window.location.href = "/admin/assortment_map/" + node.id + "/" + year_to_date;
                }
            }
        });
    }
    render_tree_map(list,type);
    $('#weekly_range').buttonset();
});