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
				parent.prevUntil(".date-start").addClass("date-sel");
				startFlag = 0;
			}
		}
      		
    });
});