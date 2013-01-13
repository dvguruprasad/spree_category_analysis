$(function(){
    $('ul.group').find('a').click(function(){
        if ($(this).attr('href') == '#')
            alert("Drill Down Data Not Available");
    });
});
