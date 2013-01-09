$(function(){
    $('ul.group').find('a').click(function(){
        if ($(this).attr('href') == '#')
            alert("Data Not Available");
    });
});
