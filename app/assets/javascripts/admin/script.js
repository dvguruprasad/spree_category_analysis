var startFlag = 0;
var promotion_number = 0;
$(document).ready(function() {
    var startDate, endDate,index;
    var hoverBinder = function(){
        $(".date-start , .date-sel, .date-end").hover(function(){
        promotion_number = $(this).data("promotion-number");
        type = $(".date-end.promotion_" + promotion_number).find("form input:radio[name=group1]:checked").val();
//        console.log($(".date-end.promotion_" + promotion_number).find("form input:radio[name=group1]:checked").val());
        if(type == "Percentage"){
            percentage = $(".date-end.promotion_" + promotion_number).find('form input[id^=promotion_percentage]').val();
//            console.log(percentage);
        }else{
            buy = $(".date-end.promotion_" + promotion_number).find('form input[id^=promotion_buy]').val();
            get = $(".date-end.promotion_" + promotion_number).find('form input[id^=promotion_get]').val();
            console.log(buy);
            console.log(get);
        }
    })};
    hoverBinder();
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
    };

    var add_promotion_details = function(parent){
        parent.addClass("promotion_" + promotion_number.toString());
        parent.data("promotion-number",promotion_number)
    };
    $(".calendar_promo.date-end").each(function(index,value){
        var parent = $(value);
        promotion_number += 1;
        add_promotion_details(parent);
        add_promotion_details(parent.find('form.promo-form'));
        add_promotion_details(parent.find('form.promo-form input.remove_button'));
        add_promotion_details(parent.find('form.promo-form input.ok_button'));
        add_promotion_details(parent.find('.promo-bubble'));
        var precodes= preUntilAcrosSiblings(parent);
        add_promotion_details(precodes.first().prev());
        add_promotion_details(precodes);
        $("li.promotion_" + promotion_number).click(function(event){
            promotion_number = $(this).data("promotion-number");
            $(".promo-bubble.promotion_" + promotion_number).toggle(true);
            return false;
        });

        $(parent.find('form.promo-form input.remove_button')).click(
            function(){
            promotion_number = $(this).data("promotion-number");
            remove_promotion(promotion_number);
        }
        );
        console.log(parent.data("promotion-number"));
        $(parent.find('form.promo-form input.ok_button.promotion_'+parent.data("promotion-number"))).click(
            function(){
            promotion_number = $(this).data("promotion-number");
            $(".promo-bubble.promotion_" + promotion_number).toggle(false);
            return false;

        }
        );
    });
    $("li.calendar_promo").click(function(event){
        promotion_number = $(this).data("promotion-number");
        $(".promo-bubble.promotion_" + promotion_number).toggle(true);
        return false;
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
                        add_promotion_details(parent.find('form.promo-form'));
                        add_promotion_details(parent.find('form.promo-form input.remove_button'));
                        add_promotion_details(parent.find('form.promo-form input.ok_button'));
                        add_promotion_details(parent.find('.promo-bubble'));
                        startFlag = 0;
                        index = endDate;
                        var precodes= preUntilAcrosSiblings(parent);
                        $.each(precodes,function(){
                            $(this).addClass("date-sel");
                        })
                        add_promotion_details(precodes);
                        $("li.promotion_" + promotion_number).click(function(event){
                            promotion_number = $(this).data("promotion-number");
                            $(".promo-bubble.promotion_" + promotion_number).toggle(true);
                            return false;
                        });
                        $(parent.find('form.promo-form input.remove_button')).click(
                            function(event){
                            promotion_number = $(this).data("promotion-number");
                            remove_promotion(promotion_number);
                            return false;
                        }
                        );
                        $(parent.find('form.promo-form input.ok_button.promotion_'+promotion_number)).click(
                            function(event){
                            promotion_number = $(this).data("promotion-number");
//                            console.log(promotion_number);
//                            console.log('.promo-bubble.hidden.promotion_'+promotion_number);
                            $('.promo-bubble.promotion_'+promotion_number).toggle(false);
                            return false;
                        }
                        );
                        hoverBinder();

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

    var clear_promotion_data = function (promotion_number) {
        $(".promotion_" + promotion_number.toString()).each(function (index, element) {
            if ($(element).is(".week-start") || $(element).is(".hidden")) {
                $(element).removeClass("date-sel");
                $(element).removeClass("date-start");
                $(element).removeClass("date-end");
                $(element).removeClass("calendar_promo");
                $(element).removeClass("promotion_" + promotion_number.toString());
            }
            else {
                $(element).removeClass();
            }
        });
        promotion_number -= 1;
    }


    var remove_promotion = function(promotion_number){
        $('form.promotion_'+promotion_number.toString()).each(function(){this.reset();});
        clear_promotion_data(promotion_number);
        $(".promo-bubble").toggle(false);
    };


});
