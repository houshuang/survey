$(document).ready(function(){
$(".numeric").keyup(function() {
    // Get the non Numeric char that was enetered
    var nonNumericChars = $(this).val().replace(/[0-9]/g, '');                                  
    // Now set the value in text box 
    $(this).val( $(this).val().replace(nonNumericChars, ''));    

});
	var blocksLength = $('.blocks form .block').length;

	$('.stepsbar .bar .progress').css({
		"width": (100/blocksLength)+"%"
	});

	$('.stepsbar .bar .progress span').text("1/"+blocksLength);

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

	var counter = 1;

	$('.stepsController a').on('click', function(){



		var simbolo = "0";

		if($(this).parent().hasClass('next')){
			counter++;
			simbolo = "+";
		} else {
			counter--;
			simbolo = "-";
		}



		$('html,body').animate({
			scrollTop: $('#top').offset().top},
			300, function(){

				$('.stepsbar .bar .progress').stop().animate({
					"width": simbolo+'='+(100/blocksLength)+"%"
				});

				$('.blocks form .block:visible').fadeOut(100, function(){
					$('.blocks form .block:eq('+(counter-1)+')').fadeIn(100);
				});

				$('.stepsbar .bar .progress span').text(counter+"/"+blocksLength);

			});

			return false;

	});

});
