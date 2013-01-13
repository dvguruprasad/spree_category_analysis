$(function(){
    var render_tree_map = function(list, type) {

        $('div#treemap-div').treemap(list, {
            backgroundColor:function (node, box) {
                return node.color;
            },
            click:function (node, box) {
                if(node.permalink == "#" && type == "taxon")
                    {
                        alert("Drill Down Data Not Available");
                    }
            }
        });
    }
    render_tree_map(list,type);
});
