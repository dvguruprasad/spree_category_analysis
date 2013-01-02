$(function(){
    var render_tree_map = function(list, type) {

        $('div#treemap-div').treemap(list, {
            backgroundColor:function (node, box) {
                return node.color;
            }
        });
    }
    render_tree_map(list,type);
});
