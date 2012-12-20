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
                startFlag = 0;
                index = parent.text();

      				parent.prevUntil(".date-start").addClass("date-sel");
               html = $("#promotion-type").html();
                $('.promo-bubble').wrap('<div class=bubble_' +index+' />');
                console.log(parent);
                parent.append(html);
			}
		}
    });
});
