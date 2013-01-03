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
                        //alert('dsf'+preUntilAcrosSiblings(parent).length);
                        var precodes= preUntilAcrosSiblings(parent);
                        $.each(precodes,function(){
                            $(this).addClass("date-sel");
                        })
                        //parent.prevUntil(".date-start").addClass("date-sel");  //alert(parent.prevUntil(".date-start").length);
                        //add_promotion_details(parent.prevUntil(".date-start"));
                        add_promotion_details(precodes);
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
        list_of_inbetween_li = preUntilAcrosSiblings(element);
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
        var preUntilAcrosSiblings = function(sel){
            if(sel.closest(".week_wrapper").find('.date-start').length){
                 var obj= sel.prevUntil(".date-start");
                return obj;
            }
            else {
                var obj1= sel.prevUntil(".date-start"); //alert('nearest obj1'+obj1.length);
                var current =sel.closest(".week_wrapper");

                for(var i=0;i<5;i++)
                {
                    var check=current.prev().find('.date-start');
                    if(check.length){
                        var obj2= check.first().nextUntil(".date-end");      // alert("obj1"+obj1.length+" obj2 "+obj2.length);
                        var obj=$().add(obj1).add(obj2);   //  alert("obj "+obj.length);
                        return obj;
                    }
                    else {
                        current = current.prev();
                        var obj1=$().add(obj1).add(current.find("li")); // alert("else obj1" +obj1.length) ;

                    }

                }

             }
        }


});
