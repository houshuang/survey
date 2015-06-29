// Resource-review
$(document).ready(function(){

  $('#rateit').on('click', function(e) { 
    $('#rating_input').val($(this).rateit('value')) 
  })

  $('#edit_desc').on('click', function() {
    text = $('#description').text()
    $('#edit_button').html('')
    $('#description').html('<textarea name="f[description]">' + $.trim(text) + '</textarea>')
    return false;
  })

  if ($("#tags").length !== 0) { $("#tags").columnize({ columns: 3 }) 
    $('tagit-placeholder').html('');
    Window.ms = $('#ms-suggest').tagit({
      fieldName: 'f[tags]',
      caseSensitive: false,
      allowSpaces: true,
      singleField: true,
      singleFieldDelimiter: "|",
      placeholderText: "Enter your tags",
      beforeTagRemoved: function(event, ui) {
        if($.inArray(ui.tagLabel, Window.tags) > -1 ){
          return false
        } else {
          return true
        }
      },
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
  }
  $('.stepsController a').on('click', function() { submit() });

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
  } else {
    T.next('.counter').html("<font color=red>At least " + (min - len) + " more words required</font>");
  }			
}

submit = function(res) {
  $('.header').html("")

  $('form').submit();

  $('.blocks').html("<h3>Submitting and redirecting, please don't close window...</h3>")
  return false;
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

check_url = function(pagevalidate) {
  session = $('input[name*=session]').val()
  url = $('input[name*=url]').val()
  if(!isUrlValid(url)) {
    not_valid("This is not a valid URL. URLs should look like this: http://example.com, or https://resource.net/math. Please try again.")
    if(pagevalidate===true) { validate_page() }
  } else {
    $.post("/resource/check_url",
           {url: url, session: session})
           .then(function(e) {
             console.log(e)
             url_callback(e, pagevalidate)
           })
  }
} 

url_callback = function(valid, pagevalidate) {
  switch(valid.result) {
    case "success":
      $("#urlverification").html('<font color=green>✓</font>')
    Window.valid = true
    break
    case "not found":
      not_valid("This URL seems unreachable, perhaps you mistyped it? Please try again, or add another resource instead.") 
    break
    case "exists":
      session = $('input[name*=session]').val()
    url = '/resource/review/' + valid.id + '?session=' + session
    not_valid("Someone else in your SIG already added this URL. Please suggest another resource instead.")
    // not_valid("This URL already exists. <a href=" + url + ">Click here</a> to see the existing submission, and add your comments.")
    break
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
//
// from http://stackoverflow.com/questions/2723140/validating-url-with-jquery-without-the-validate-plugin
function isUrlValid(url) {
  return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
}
