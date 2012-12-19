$(document).ready(function() {
	var startFlag = 0;
	$(".range-sel-box li a").off("click").on("click", function(){
		var parent = $(this).parent();

		if(!parent.is(".date-sel") && !parent.is(".date-start") && !parent.is(".date-end")) {
			if(!startFlag) {
				parent.addClass("date-start");
				startFlag = 1;
			} else {				
				parent.addClass("date-end");
        index = parent.text();
				parent.prevUntil(".date-start").addClass("date-sel");
        promotion_input = document.createElement('div')

        promotion_percentage_label = document.createElement('label');
        promotion_percentage = document.createElement('input');
        promotion_percentage.id = "promotion_percentage"+index;

        promotion_type_label = document.createElement('label');
        promotion_type = document.createElement('input');
        promotion_type.id = "promotion_type"+index;

        promotion_input.appendChild(promotion_percentage_label);
        promotion_input.appendChild(promotion_percentage);
        promotion_input.appendChild(promotion_type_label);
        promotion_input.appendChild(promotion_type);

        $(this).append(promotion_input);
        startFlag = 0;
			}
		}
    });
});
