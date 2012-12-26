(function($) {

    function Rectangle(x, y, width, height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.margin = 4;
    }

    Rectangle.prototype.style = function() {
        return {
            top: this.y + 'px',
            left: this.x + 'px',
            width: (this.width - this.margin) + "px",
            height: (this.height - this.margin) + "px"
        };
    }

    Rectangle.prototype.isWide = function() {
        return this.width > this.height;
    }

    function TreeMap($div, options) {
        var options = options || {};
        this.$div = $div;

        $div.css('position', 'relative');
        this.rectangle = new Rectangle(0, 0, $div.width(), $div.height());

        this.nodeClass = function() {
            return '';
        }
        this.click = function() {
        };
        this.mouseenter = function() {
        };
        this.mouseover = function() {
        };
        this.mouseleave = function() {
        };
        this.mousemove = function() {
        };
        this.paintCallback = function() {
        };
        this.ready = function() {
        };

        $.extend(this, options);

        this.setNodeColors = function(node, $box) {
            if (this.backgroundColor) $box.css('background-color', this.backgroundColor(node, $box));
            if (this.color) $box.css('color', this.color($box));
        }
    }

    TreeMap.SIDE_MARGIN = 20;
    TreeMap.TOP_MARGIN = 20;

    TreeMap.prototype.paint = function(nodeList) {
        var nodeList = this.squarify(nodeList, this.rectangle);

        for (var i = 0; i < nodeList.length; i++) {
            var node = nodeList[i];
            var nodeBounds = node.bounds;



            var sales_span = '<li><span>' +'<label> Total Revenue: </label>' +node.value +' <b>USD</b>'+'</span></li>';
            var total_target_span = '<li><span>' +'<label> Total Target: </label>' + node.total_target +' <b>USD</b>'+'</span></li>';
            var revenue_diff_span = '<li><span>' +'<label> Target Variation: </label>' + Math.round((node.total_target - node.value)*100)/100 +' <b>USD</b>'+'</span></li>';
            var profit_span = '<li><span>' +'<label> Profit: </label>' + node.profit +' <b>USD</b>'+'</span></li>';
            var profit_change_span = '<li><span>' +'<label> Profit Last Year: </label>' + node.profit_change +' <b>%</b>'+'</span></li>';
            var revenue_change_span = '<li><span>' +'<label> Revenue Last Year: </label>' + node.revenue_change +' <b>USD</b>'+'</span></li>';
            var hoverDiv = '<div id="'+node.id+'hover"  class="tooltip" style="display:none"><ul style="padding:0px;list-style-type:none">' + sales_span + total_target_span + revenue_diff_span + revenue_change_span + profit_span + profit_change_span +'</ul></div>';


            var $box = $('<div id=' + node.id + '></div>');
            $box.css($.extend(nodeBounds.style(), {
                'position' : 'absolute'
            }));

            this.setNodeColors(node, $box);

            $box.addClass('treemap-node');

            var self = this;
            $box.bind('click', node, function(e) {
                self.click(e.data, e);
            });
            $box.bind('mouseenter', node, function(e) {
                self.mouseenter(e.data, e);
            });
            $box.bind('mouseover', node, function(e) {
                self.mouseover(e.data, e);
            });
            $box.bind('mouseleave', node, function(e) {
                self.mouseleave(e.data, e);
            });
            $box.bind('mousemove', node, function(e) {
                self.mousemove(e.data, e);
            });

            $box.appendTo(this.$div);
            $box.addClass(this.nodeClass(node, $box));

            var $content = $("<div><p class='node-label'>" + node.label + "</p></div>");
            $content.addClass('treemap-label');
            $content.css({
                'display': 'block',
                'position': 'relative',
                'text-align': 'center',
                'font-size': '15px',
                'word-wrap':'break-word'
            });
            $box.append($content);
            $box.append(hoverDiv);

            //this.fitLabelFontSize($content, node);

            $content.css('margin-top', (parseInt($box.height()) / 2) - (parseInt($content.height()) / 2) + 'px');

        }
        this.ready();
    }

    TreeMap.prototype.fitLabelFontSize = function($content, node) {
        var nodeBounds = node.bounds
        while ($content.height() + TreeMap.TOP_MARGIN > nodeBounds.height || $content.width() + TreeMap.SIDE_MARGIN > nodeBounds.width) {
            var fontSize = parseFloat($content.css('font-size')) - 3;
            if (fontSize < 1) {
                $content.remove();
                break;
            }
            $content.css('font-size', fontSize + 'px');
        }
        $content.css('display', 'block');
        this.paintCallback($content, node);
    }

    TreeMap.HORIZONTAL = 1;
    TreeMap.VERTICAL = 2;

    TreeMap.prototype.squarify = function(nodeList, rectangle) {
        nodeList.sort(function(a, b) {
            return b.value - a.value;
        });
        this.divideDisplayArea(nodeList, rectangle);

        return nodeList;
    };

    TreeMap.prototype.divideDisplayArea = function(nodeList, destRectangle) {
        // Check for boundary conditions
        if (nodeList.length === 0) return;

        if (nodeList.length == 1) {
            nodeList[0].bounds = destRectangle;
            return;
        }

        var halves = this.splitFairly(nodeList);

        var midPoint;
        var orientation;

        var leftSum = this.sumValues(halves.left),
        rightSum = this.sumValues(halves.right),
        totalSum = leftSum + rightSum;

        if (leftSum + rightSum <= 0) {
            midPoint = 0;
            orientation = TreeMap.HORIZONTAL;
        } else {

            if (destRectangle.isWide()) {
                orientation = TreeMap.HORIZONTAL;
                midPoint = Math.round(( leftSum * destRectangle.width ) / totalSum);
            } else {
                orientation = TreeMap.VERTICAL;
                midPoint = Math.round(( leftSum * destRectangle.height ) / totalSum);
            }
        }

        if (orientation == TreeMap.HORIZONTAL) {
            this.divideDisplayArea(halves.left, new Rectangle(destRectangle.x, destRectangle.y, midPoint, destRectangle.height));
            this.divideDisplayArea(halves.right, new Rectangle(destRectangle.x + midPoint, destRectangle.y, destRectangle.width - midPoint, destRectangle.height));
        } else {
            this.divideDisplayArea(halves.left, new Rectangle(destRectangle.x, destRectangle.y, destRectangle.width, midPoint));
            this.divideDisplayArea(halves.right, new Rectangle(destRectangle.x, destRectangle.y + midPoint, destRectangle.width, destRectangle.height - midPoint));
        }
    };

    TreeMap.prototype.splitFairly = function(nodeList) {
        var halfValue = this.sumValues(nodeList) / 2;
        var accValue = 0;
        var length = nodeList.length;

        for (var midPoint = 0; midPoint < length; midPoint++) {
            if (midPoint > 0 && ( accValue + nodeList[midPoint].value > halfValue ))
                break;
            accValue += nodeList[midPoint].value;
        }

        return {
            left: nodeList.slice(0, midPoint),
            right: nodeList.slice(midPoint)
        };
    };

    TreeMap.prototype.sumValues = function(nodeList) {
        var result = 0;
        var length = nodeList.length;
        for (var i = 0; i < length; i++)
        result += nodeList[i].value;
        return result;
    };

    $.fn.treemap = function(json, options) {
        var self = this;
        return this.fadeOut('fast', function() {
            self.empty().fadeIn('fast', function() {
                new TreeMap(self, options).paint(json);
                children = $('#treemap-div').children()
                for(i=0;i<children.length;i++)
                {
                    id = "#" + children[i].id;
                    $(id).qtip({
                        content:$(id+"hover").html(),
                        style: {
                            width: 250,
                            border: {
                                width: 2,
                                radius: 3,
                                color: '#262626'
                            },
                            tip: { // Now an object instead of a string
                                corner: 'bottomLeft', // We declare our corner within the object using the corner sub-option
                            },
                            padding: 5,
                            textAlign: 'left',
                            //tip: 'auto',
                            // Give it a speech bubble tip with automatic corner detection
                            background: '#262626',//children[i].style.backgroundColor,// Style it according to the preset 'cream' style
                            color: '#E5E2CF'
                        },
                        position: {
                            corner: {
                                target: 'center',
                                tooltip: 'bottomLeft'
                            }
                        }
                    });
                }

            });

        });

    };

})(jQuery);
