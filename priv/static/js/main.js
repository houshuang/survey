$(document).ready(function(){

    $(".numeric").keyup(function() {
	// Get the non Numeric char that was enetered
	var nonNumericChars = $(this).val().replace(/[0-9]/g, '');                                  
	// Now set the value in text box 
	$(this).val( $(this).val().replace(nonNumericChars, ''));    

    });
    Window.counter = 1;
    Window.blocksLength = $('.blocks form .block').length;

    $('.stepsbar .bar .progress').css({
	"width": (100/Window.blocksLength)+"%"
    });

    $('.stepsbar .bar .progress span').text("1/"+Window.blocksLength);
    $('input[type="text"].masked').mask('9?9');
    $('.none').each(function(){

	var labelThis = $(this).parent();
	$(this).on('change', function(){
	    if($(this).is(':checked')){
		labelThis.prevAll('label').find('input[type="checkbox"]:checked').click();
		labelThis.prevAll('label').find('input[type="checkbox"]').attr('disabled',"true");
		labelThis.next('fieldset').fadeIn();

	    } else {
		labelThis.prevAll('label').find('input[type="checkbox"]').removeAttr('disabled');
		labelThis.next('fieldset').fadeOut();
	    }
	});
    });

    $('textarea').each(function(){

	var T = $(this);
	var valueNum = T.next('.counter').attr('length');
	T.next('.counter').text(valueNum);
	T.on('keyup', function(){

	    var len = T.val().length;
	    if (len > valueNum) {
		newValue = T.val().substring(0, valueNum);
		T.val(newValue);
	    } else {
		T.next('.counter').text(valueNum - len);
	    }			
	});

    });

    buttons();
});

buttons = function() {
    Window.counter = Window.counter;
    Window.blocksLength = Window.blocksLength;
    var txt = "";
    if (Window.counter == Window.blocksLength && Window.counter !== undefined) {
	txt =  "<div class='stepsController prev left'><a href='#'>Previous</a></div>" + 
	"<div class='stepsController submit right'><a href='#'>Submit</a></div>";
    } else if (Window.counter == 1 || Window.counter === undefined) {
	txt = "<div class='stepsController next right'><a href='#'>Next</a></div>";
    } else {
	txt = "<div class='stepsController next right'><a href='#'>Next</a></div>" +
	    "<div class='stepsController prev left'><a href='#'>Previous</a></div>";
    }
    $('.navbuttons').html(txt);
    $('.stepsController a').on('click', function() {buttonclick(this);});
};

buttonclick = function(e) {
    if(e.text == "Submit") {
	$('form').submit();
    }
    $.post("/tags/submitajax", $("form").serialize(), function(data){
    });
    var simbolo = "0";
    if($(e).parent().hasClass('next')){
	Window.counter++;
	simbolo = "+";
    } else if($(e).parent().hasClass('prev')){
	Window.counter--;
	simbolo = "-";
    } else {console.log(e);}
    $('html,body').animate({
	scrollTop: $('#top').offset().top},
	300, function(){

	    $('.stepsbar .bar .progress').stop().animate({
		"width": simbolo+'='+(100/Window.blocksLength)+"%"
	    });
	    $('.blocks form .block:visible').fadeOut(100, function(){
		$('.blocks form .block:eq('+(Window.counter-1)+')').fadeIn(100);
	    });
	    $('.navbuttons').html(buttons(Window.counter, Window.blocksLength));
	    $('.stepsbar .bar .progress span').text(Window.counter+"/"+Window.blocksLength);
	});
	return false;
};
