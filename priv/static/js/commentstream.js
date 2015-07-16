// Commentstream
$(document).ready(function(){
  $('.stepsController a').on('click', function() { submit_comment() });

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

check_textarea_length = function(T, min) {
  var len = T.val().trim().split(" ").length;
  if (len >= min) {
    T.next('.counter').html("<font color=green>✓</font>");
    return true;
  } else {
    T.next('.counter').html("<font color=red>At least " + (min - len) + " more words required</font>");
    return false;
  }			
}

submit_comment = function(res) {
    $.post("/commentstream/submit", $("form").serialize(), function(data){
      text = $.trim($("#comment_area").val())
      $("#addnew").html("Thank you for submitting")
      $("#submit").html("")
      $("#textbox").html("")
      $("#commentlist").append("<p>" + text + " <i>(" + nick + ")</i></p>")
      console.log(data)
    });
  return false;
}

