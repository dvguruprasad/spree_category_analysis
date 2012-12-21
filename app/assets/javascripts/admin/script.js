$(document).ready(function() {
  var startFlag = 0, startDate, endDate,index;
  $(".range-sel-box li a").on("click", function(){
    var parent = $(this).parent();

    if(!parent.is(".date-sel") && !parent.is(".date-start") && !parent.is(".date-end")) {
      if(!startFlag) {
        parent.addClass("date-start");
        startDate =   parseInt(parent.text().trim());
        startFlag = 1;
      } else {
          endDate = parseInt(parent.text().trim());

          if(endDate > startDate) {
              parent.addClass("date-end");
              startFlag = 0;
              index = endDate;
              parent.prevUntil(".date-start").addClass("date-sel");
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
  });
});

