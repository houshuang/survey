// Reflection.js
//
$(document).ready(function(){
  // preload old values
  _.forOwn(response, function(item,i) { restore(item, i, questions[i].type) })

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

// Still need text input and grid
function restore(item, i, type) {
  switch(type) {
    case "textbox":
      $("textarea[name='f[" + i + "]']").val(item)
      break;
    case "radio":
      $("input[name='f["+ i +"]'][value='"+ item +"']").prop('checked', true)
      break;
    case "multi":
      _.each(item, function(e) {
        $("input[name='f["+ i +"|" + e +"]']").prop('checked', true)
      })
      break
  }
}


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
  // res = validate_page();
  // if (res.length === 0) {
    $('.header').html("")

    $('form').submit();

    $('.blocks').html("<h3>Submitting and redirecting, please don't close window...</h3>")
    return false;
  }
  // else {
  //   var txt = _.map(res, function(x) { return x + "<br>" }).join("")
  //   txt = "<p class='alert alert-warning'>"+ txt +"</p>"
  //   $('.header').html(txt)
  //   var simbolo = "0";
  //   $('html,body').animate({
  //     scrollTop: $('#top').offset().top},
  //     300, function(){

  //     });
  // }
// }

validate_page = function(pg) {
  var warnings= []
  if(!validate_textarea('1')) { warnings.push("Please write more than ten words in the first textbox") }
  if(!validate_textarea('2')) { warnings.push("Please write more than ten words in the second textbox") }
  return warnings;
}

validate_textarea = function(field) {
  return $('textarea[name*=' + field + ']').val().trim().split(" ").length >= 10;
}

