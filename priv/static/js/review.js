// Reflection.js
//
$(document).ready(function(){

  $('textarea').each(function(){

    var T = $(this);
    var valueNum = T.next('.counter').attr('length');
    var min = parseInt(T.next('.counter').attr('min')) + 1;
    if (valueNum) {
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
    }
    if (min) {
      check_textarea_length(T, min)
      T.on('keyup', function() {check_textarea_length(T, min) })
    }
  });
  $('.stepsController.submit a').on('click', function() {
    console.log("validate")
    validate()
    false;
  });
  $('.stepsController.cancel a').on('click', function() {
    console.log("redirect")
    $(location).attr('href', '/review/cancel?session='+session)
    false;
  })

});


check_textarea_length = function(T, min) {
  var len = T.val().trim().split(" ").length;
  if (len >= min) {
    T.next('.counter').html("<font color=green>✓</font>");
  } else {
    T.next('.counter').html("<font color=red>At least " + (min - len) + " more words required</font>");
  }			
}


validate = function(res) {
  res = validate_page();
  console.log(res)
  if (res.length === 0) {
    console.log("Here we go")
    $('.header').html("")

    $('form').submit();

    $('.blocks').html("<h3>Submitting and redirecting, please don't close window...</h3>")
    return false;
  }
  else {
    var txt = _.map(res, function(x) { return x + "<br>" }).join("")
    txt = "<p class='alert alert-warning'>"+ txt +"</p>"
    $('.header').html(txt)
    $(".sidebar").animate({ scrollTop: 0 }, "fast");
  }
}

validate_page = function(pg) {
  var warnings= []
  if(!validate_textarea('1')) { warnings.push("Please write more than ten words in the first textbox") }
  if(!validate_textarea('2')) { warnings.push("Please write more than ten words in the second textbox") }
  if(!validate_textarea('3')) { warnings.push("Please write more than ten words in the third textbox") }
  if(!validate_textarea('4')) { warnings.push("Please write more than ten words in the fourth textbox") }
  return warnings;
}

validate_textarea = function(field) {
  return $('textarea[name*=' + field + ']').val().trim().split(" ").length >= 10;
}

