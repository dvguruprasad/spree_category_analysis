var startFlag = 0;
var promotion_number = 0;
$(document).ready(function() {
    var startDate, endDate,index;
    var hoverBinder = function(){
        promotion_ends = $(".date-end");
        promotion_ends.each(function(index,element){
            this_end = $(element);
            promo_number = $(element).data("promotion-number");
            type = this_end.find("form input:radio[name=group1]:checked").val();
            selected = $("li.promotion_" + promo_number.toString());
            duration = selected.siblings("li.date-start").find("a").attr("title")+ ' to ' + selected.siblings("li.date-end").find("a").attr("title");
            durationLabel = "<li><span class='psm-left-label'>Period </span><span class='psm-right-label'>: "+duration+"</span></li>";

            if(type == "Percentage"){
                percentage = this_end.find('form input[id^=promotion_percentage]').val();
                typeLabel = "<li><span class='psm-left-label'>Type </span> <span class='psm-right-label'>: " + type +"</span></li>";
                percentageLabel = "<li><span class='psm-left-label'> Value  </span> <span class='psm-right-label'>: " + percentage.toString() +"</span></li>";
                hoverData = "<div class='tooltip'><ul class='tooltip-ul'>"+durationLabel+typeLabel+percentageLabel+"</ul></div>"
            }else if(type == "Quantity"){
                buy = this_end.find('form input[id^=promotion_buy]').val();
                get = this_end.find('form input[id^=promotion_get]').val();
                typeLabel = "<li><span class='psm-left-label'>Type</span> <span class='psm-right-label'>: " + type +"</span></li>";
                offerLabel = "<li><span class='psm-left-label'> Value</span> <span class='psm-right-label'>: Buy " + buy.toString() + " and Get "+get.toString()+"</span></li>";
                hoverData = "<div class='tooltip'><ul class='tooltip-ul'>"+durationLabel+typeLabel+offerLabel+"</ul></div>";
            }else{
                hoverData = "<div class='tooltip'><ul class='tooltip-ul'>"+durationLabel+"<li>Please Select Details By Clicking On the Selectors</li></ul></div>";
            }

            $(selected).qtip({
                content:hoverData,
                style: {
                    width: 240,
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
                        target: 'right',
                        tooltip: 'bottomLeft'
                    }
                }
            });

        });
    }
    var preUntilAcrosSiblings = function(sel){
        var start_in_same_wrapper = sel.prevUntil(".date-start").andSelf().prev("li").first();
        if(start_in_same_wrapper.is(".date-start")){
            return sel.prevUntil(".date-start");
        }
        var tarck_for_start= sel.prevUntil(".date-start");
        var nearest_wrapper =sel.closest(".week_wrapper");

        for(var i=0;i<5;i++)
        {
            var check=nearest_wrapper.prev().find('.date-start');
            if(check.length){
                var tarck_for_end = check.first().nextUntil(".date-end");
                var selected_elements = $().add(tarck_for_start).add(tarck_for_end);
                return selected_elements;
            }
            else {
                nearest_wrapper = nearest_wrapper.prev();
                var tarck_for_start=$().add(tarck_for_start).add(nearest_wrapper.find("li"));

            }

        }
    };

    var apply_promotion_details_to_form = function(date_end_li){
        add_promotion_details(date_end_li.find('form.promo-form'));
        add_promotion_details(date_end_li.find('form.promo-form input.remove_button'));
        add_promotion_details(date_end_li.find('form.promo-form input.ok_button'));
        add_promotion_details(date_end_li.find('.promo-bubble'));
    }
    var add_promotion_details = function(parent){
        parent.addClass("promotion_" + promotion_number.toString());
        parent.data("promotion-number",promotion_number)
    };

    var is_overlapping = function(element){
        list_of_inbetween_li = preUntilAcrosSiblings(element);
        for(i=0; i< list_of_inbetween_li.length ; i++){
            $target = $(list_of_inbetween_li[i]);
            if($target.is(".date-sel") || $target.is(".date-end") || $target.is(".date-start"))
                return true;
        }
        return false;
    };

    var clear_promotion_data = function (promo_number) {
        selected = $(".date-start , .date-sel, .date-end").siblings(".promotion_"+promo_number.toString());
        $(".promotion_" + promo_number.toString()).each(function (index, element) {
            if($(element).data('qtip')) {$(element).removeData('qtip');$(element).unbind('mouseover');}
            if ($(element).is(".week-start") || $(element).is(".hidden")) {
                $(element).removeClass("date-sel");
                $(element).removeClass("date-start");
                $(element).removeClass("date-end");
                $(element).removeClass("calendar_promo");
                $(element).removeClass("promotion_" + promo_number.toString());
            }
            else {
                $(element).removeClass();
            }
        });
    }

    var remove_promotion = function(promo_number){
        $('form.promotion_'+promo_number.toString()).each(function(){this.reset();$(this).removeAttr('value');});
        clear_promotion_data(promo_number);
        $(".promo-bubble").toggle(false);
    };

    $(".date-start , .date-sel, .date-end").live("click", function(){
        promo_number = $(this).data("promotion-number");
        $(".promo-bubble.promotion_" + promo_number).toggle(true);
        return false;
    });
    $('form.promo-form input.remove_button').live("click",function(event){
        promo_number = $(this).data("promotion-number");
        remove_promotion(promo_number);
        hoverBinder();
        return false;
    });
    $('form.promo-form input.ok_button').live("click",function(event){
        promo_number = $(this).data("promotion-number");
        $('.promo-bubble.promotion_'+promo_number).toggle(false);
        if(!$('.promotion_'+promo_number.toString()).data('qtip')){
            $('.promotion_'+promo_number.toString()).removeData('qtip');
            $('.promotion_'+promo_number.toString()).unbind('mouseover');
        }
        hoverBinder();
        return false;
    });

    $(".calendar_promo.date-end").each(function(index,value){
        var parent = $(value);
        promotion_number += 1;
        add_promotion_details(parent);
        apply_promotion_details_to_form(parent);
        var precodes= preUntilAcrosSiblings(parent);
        add_promotion_details(precodes.first().prev());
        $.each(precodes,function(){
            $(this).addClass("date-sel");
        });
        add_promotion_details(precodes);
    });

    $(".range-sel-box li a").on("click", function(){
        var parent = $(this).parent();

        if(!parent.is(".date-sel") && !parent.is(".date-start") && !parent.is(".date-end")) {
            if(!startFlag) {
                promotion_number += 1;
                parent.addClass("date-start");
                add_promotion_details(parent);
                startDate =   parseInt(parent.text().trim());
                startFlag = 1;
            } else {
                endDate = parseInt(parent.text().trim());
                if(endDate > startDate ) {
                    if(!is_overlapping(parent)){
                        parent.addClass("date-end");
                        add_promotion_details(parent);
                        apply_promotion_details_to_form(parent);
                        startFlag = 0;
                        index = endDate;
                        var precodes= preUntilAcrosSiblings(parent);
                        $.each(precodes,function(){
                            $(this).addClass("date-sel");
                        })
                        add_promotion_details(precodes);
                        $(".promo-bubble").toggle(false);
                        $("#bubble"+index).toggle();
                    }
                    else{
                        remove_promotion(promotion_number);
                        startFlag = 0;
                        alert("Overlaping promotions not allowed");
                    }
                }
                else {
                    alert("Please select a date after the start date");
                }

            }
        }
        else{
            $(".promo-bubble").toggle(false);
        }
    });
    hoverBinder();
});
