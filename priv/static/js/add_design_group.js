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
  Window.counter = 1;
  buttons();
});

check_textarea_length = function(T, min) {
  var len = T.val().trim().split(" ").length;
  if (len >= min) {
    T.next('.counter').html("<font color=green>✓</font>");
  } else {
    T.next('.counter').html("<font color=red>At least " + (min - len) + " more words required</font>");
  }			
}

buttons = function() {
  $('.stepsController a').on('click', function() {buttonclick(this);});
}

buttonclick = function(e) {
  res = validate_page(Window.counter)
  if (res.length === 0 || (Window.counter == 2 && e.text == "Back")) {

    if(e.text == "Submit" && Window.counter == 2) {
      console.log("2->eternity")
      $('.header').html("")
      $('form').submit();

      $('.navbuttons').html("");
      Window.submit = true;

      $('.blocks').html("<h3>Submitting and redirecting, please don't close window...</h3>")
    } else if(e.text == "Submit") {
      console.log("1->2")
      $("#section1").hide()
      $("#section2").show()
      Window.counter = 2
    } else if(e.text == "Back" && Window.counter == 2) {
      console.log("2->1")
      $("#section1").show()
      $("#section2").hide()
      Window.counter = 1
    }
    var simbolo = "0";
    $('html,body').animate({
      scrollTop: $('#top').offset().top},
      300, function(){
      });
      return false;
  }
  else {
    var txt = _.map(res, function(x) { return x + "<br>" }).join("")
    txt = "<p class='alert alert-warning'>"+ txt +"</p>"
    $('.header').html(txt)
  }
  return false;
};


// -------------------------------------------------------
validate_page = function(pg) {
  var res 
  switch(pg) {
    case 1: res = validate_page1()
    break
    case 2: res = validate_page2()
    break
    case 3: res = []//validate_page3()
    break
  }
  return res
}

validate_page1 = function() {
  var warnings= []
  if(!validate_text('topics')) { warnings.push("Please write something about which topics the lesson design will address") }
  if(!validate_textarea('description')) { warnings.push("Please write at least ten words in the description field") }
  if(!validate_textarea('howtech')) { warnings.push("Please write at least ten words about how technology can help students") }
  return warnings
}

validate_page2 = function() {
  var warnings= []
  if(!validate_text('title')) { warnings.push("Please fill out a descriptive title") }
  return warnings;
}
validate_textarea = function(field) {
  return $('textarea[name*=' + field + ']').val().trim().split(" ").length >= 10;
}
validate_select = function(field) {
  return $('select[name*=' + field + ']').val() != "noselection"
}

validate_text = function(field) {
  return $('input[name*=' + field + ']').val().length > 3
}

validate_multi = function(sel) {
  return _.reduce($('input[name*=' + sel + ']'), function(acc, x){ return acc || $(x).attr('checked')}, false)
}

