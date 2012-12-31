var startFlag = 0;
$(document).ready(function() {
    var promotion_number = 0;
    var startDate, endDate,index;
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
                        add_promotion_details(parent.find('form.promo-form'));
                        add_promotion_details(parent.find('form.promo-form input.remove_button'));
                        $(parent.find('form.promo-form input.remove_button')).click(
                            function(){
                            promotion_number = $(this).data("promotion-number");
                            remove_promotion(promotion_number);
                        }
                        );
                        startFlag = 0;
                        index = endDate;
                        parent.prevUntil(".date-start").addClass("date-sel");
                        add_promotion_details(parent.prevUntil(".date-start"));
                    }
                    else{
                        alert("Overlaping promotions not allowed");
                    }
                    $(".promo-bubble").toggle(false);
                    $("#bubble"+index).toggle();

                }
                else {
                    alert("Please select a date after the start date");
                }

            }
        } else if (parent.is(".date-end")) {

            index = parseInt(parent.text().trim());
            $(".promo-bubble").toggle(false);
            $("#bubble"+index).toggle();
        }
        else{
            $(".promo-bubble").toggle(false);
        }
    });

    var is_overlapping = function(element){
        list_of_inbetween_li = element.prevUntil(".date-start");
        for(i=0; i< list_of_inbetween_li.length ; i++){
            $target = $(list_of_inbetween_li[i]);
            if($target.is(".date-sel") || $target.is(".date-end") || $target.is(".date-start"))
                return true;
        }
        return false;
    };

    var clear_promotion_data = function(promotion_number){
        li_for_a_promotion = $(".promotion_"+promotion_number.toString()).removeClass();
        promotion_number -= 1;
    }


    var add_promotion_details = function(parent){
        parent.addClass("promotion_" + promotion_number.toString());
        parent.data("promotion-number",promotion_number)
    };

    var remove_promotion = function(promotion_number){
        $('form.promotion_'+promotion_number.toString()).each(function(){this.reset();});
        clear_promotion_data(promotion_number);
        $(".promo-bubble").toggle(false);
    };

});
