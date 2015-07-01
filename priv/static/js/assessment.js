// Reflection.js
//
$(document).ready(function(){
  // preload old values
  if(typeof(response) !== "undefined") {
    value = response[1]
    selects = $('input[name*=1]');
    selects.filter('[value="'+ value +'"]').prop('checked', true)
  }

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

});

$('.stepsController a').on('click', function() {validate()});

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
  if (res.length === 0) {
    $('.header').html("")

    $('form').submit();

    $('.blocks').html("<h3>Submitting and redirecting, please don't close window...</h3>")
    return false;
  }
  else {
    var txt = _.map(res, function(x) { return x + "<br>" }).join("")
    txt = "<p class='alert alert-warning'>"+ txt +"</p>"
    $('.header').html(txt)
    var simbolo = "0";
    $('html,body').animate({
      scrollTop: $('#top').offset().top},
      300, function(){

      });
  }
}

validate_page = function(pg) {
  var warnings= []
  if(!validate_select('1')) { warnings.push("Please make a choice") }
  return warnings;
}

validate_select = function(field) {
  return $('input[name*=' + field + ']:checked', 'form').val()
}

