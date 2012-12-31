$(document).ready(function() {
    var promotion_number = 0;
    var startFlag = 0, startDate, endDate,index;
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

                if(endDate > startDate) {
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
                } else {
                    alert("Please select a date after the start date");
                }

                $(".promo-bubble").toggle(false);
                $("#bubble"+index).toggle();
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
