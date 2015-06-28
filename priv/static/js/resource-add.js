$(document).ready(function(){
  $("#tags").columnize({ columns: 3 })
  $('tagit-placeholder').html('');
  Window.ms = $('#ms-suggest').tagit({
    fieldName: 'f[tags]',
    autocomplete: {delay: 0, minLength: 1},
    showAutocompleteOnFocus: true,
    caseSensitive: false,
    allowSpaces: true,
    singleField: true,
    singleFieldDelimiter: "|",
    placeholderText: "Enter your tags",
    afterTagRemoved: function(event, ui) {
      txt = ui.tagLabel
      id = txt.replace(/ /g,"_").replace(/,/g,"_");
      $('#' + id).html('<a href="#">' + txt + '</a>' )
    }  
  });

  $('#tagfieldset').hide()
  $('.tagsuggestion').on('click', function(e) {
    txt = $(this).text()
    $(this).html(txt)
    Window.ms.tagit("createTag", txt)
    return(false);
  })
  $('.stepsController a').on('click', function() {buttonclick(this);});

  $('.generic').on('click', function() {
    val = $('form input[type=radio][name*=generic]:checked').val()
    if(val == "true") { 
      $('#tagfieldset').hide()
    } else {
      $('#tagfieldset').show()
    }
  })

  $('input[name*=url]').on('change', check_url)
  $('textarea').each(function(){

    var T = $(this);
    var valueNum = T.next('.counter').attr('length');
    var min = T.next('.counter').attr('min');
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
    T.next('.counter').html("<font color=red>At least " + min + " more words required</font>");
    T.on('keyup', function(){

      var len = T.val().trim().split(" ").length;
      if (len >= min) {
    T.next('.counter').html("<font color=green>✓</font>");
      } else {
    T.next('.counter').html("<font color=red>At least " + (min - len) + " more words required</font>");
      }			
    });
    }
  });
});

buttonclick = function(e) {
  pre_validate()
};

post_validate = function(res) {
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

pre_validate = function() {
  check_url(true)
}

validate_page = function(pg) {
  var warnings= []
  if(!validate_text('name')) { warnings.push("Please add a name with more than three characters") }
  if(!validate_url('url')) { warnings.push("Please check your URL, it does not seem to be valid") }
  if(!validate_textarea('description')) { warnings.push("Please add a description with more than 10 words") }
  if(!validate_radio('generic')) { warnings.push("Please specify whether this is a generic or a discipline-specific resource") }
  if(!validate_select('sig_id')) { warnings.push("Please select a Special Interest Group (SIG)") }
  if(!validate_tags('tags')) { warnings.push("Please add at least one tag") }
  post_validate(warnings)
}

// from http://stackoverflow.com/questions/2723140/validating-url-with-jquery-without-the-validate-plugin
function isUrlValid(url) {
  return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
}

check_url = function(pagevalidate) {
  url = $('input[name*=url]').val()
  if(!isUrlValid(url)) {
    not_valid("This is not a valid URL. URLs should look like this: http://example.com, or https://resource.net/math. Please try again.")
  } else {
    valid()
  }

  if(pagevalidate===true) { validate_page() } 
} 

not_valid = function(message) {
  $("#urlverification").html('<font color=red>' + message + '</font>')
  Window.valid = false
}

valid = function(message) {
  $("#urlverification").html('')
  Window.valid = true
}

validate_url = function() {
  return(validate_text("url") && Window.valid !== false)
}
validate_tags = function(field) {
  if($('form input[type=radio][name*=generic]:checked').val() == "false") {
    return $('input[name*=' + field + ']').val() !== "" 
  } else {
    return true
  }
}
validate_text = function(field) {
  return $('input[name*=' + field + ']').val().length > 3
}
validate_textarea = function(field) {
  return $('textarea[name*=' + field + ']').val().trim().split(" ").length >= 10;
}
validate_radio = function(field) {
  return $('form input[type=radio][name*=' + field + ']:checked').val()
}

validate_select = function(field) {
  return $('select[name*=' + field + ']').val() != "noselection"
}
