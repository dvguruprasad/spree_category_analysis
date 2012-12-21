$(document).ready(function() {
  var startFlag = 0;
  $(".range-sel-box li a").on("click", function(){
    var parent = $(this).parent();

    if(!parent.is(".date-sel") && !parent.is(".date-start") && !parent.is(".date-end")) {
      if(!startFlag) {
        parent.addClass("date-start");
        startFlag = 1;
      } else {				
        parent.addClass("date-end");
        startFlag = 0;
        text = parent.text().trim();
        index = text.substring(0,2).trim();

        parent.prevUntil(".date-start").addClass("date-sel");
        alert("#bubble"+index);
        $(".promo-bubble").toggle(false);
        $("#bubble"+index).toggle();
        prev_id = index;
      }
    }
  });
});
