$(document).ready(function(){

  $(".numeric").keyup(function() {
    // Get the non Numeric char that was enetered
    var nonNumericChars = $(this).val().replace(/[0-9]/g, '');                                  
    // Now set the value in text box 
    $(this).val( $(this).val().replace(nonNumericChars, ''));    

  });
  Window.counter = 1;
  Window.blocksLength = $('.blocks form .block').length;

  $('.fieldlevel').on('change', function(e) {
    if (this.name == 'f[grade|noK12]' && this.checked) {
      $('.k12').prop('checked', false)
    } else {
      $('.nok12').prop('checked', false)
    }
  })
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
  res = validate_page(Window.counter)
  console.log(res)
  if (res.length === 0) {
    $('.header').html("")
    find_data_selectors();

    if(e.text == "Submit") {
      $('form').submit();
    }
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
  }
  else {
    var txt = _.map(res, function(x) { return x + "<br>" }).join("")
    txt = "<p class='alert alert-warning'>"+ txt +"</p>"
    $('.header').html(txt)
  }
};

find_data_selectors = function() {
  $.post("/user/get_tags", $("form").serialize(), function(data){

  $('#ms-suggest').tagit({
    fieldName: 'f[tags]',
    availableTags: data,
    autocomplete: {delay: 0, minLength: 1},
    showAutocompleteOnFocus: true,
    caseSensitive: false,
    allowSpaces: true,
    singleField: true,
    singleFieldDelimiter: "|",
    placeholderText: "Enter your tags"
  });
  })

  if(Window.counter==1) {
  console.log("Recalculating suggestions")
  var data = {};
  $("form").serializeArray().map(function(x){data[x.name] = x.value;}); 

  steams = []
  if (data["f[steam|S]"]) { steams.push("S") }
  if (data["f[steam|T]"]) { steams.push("T") }
  if (data["f[steam|E]"]) { steams.push("E") }
  if (data["f[steam|A]"]) { steams.push("A") }
  if (data["f[steam|M]"]) { steams.push("M") }
  if (data["f[steam|+]"]) { steams.push("+") }

  grades = []
  if (data["f[grade|1-3]"]) { grades.push("1-3") }
  if (data["f[grade|4-6]"]) { grades.push("4-6") }
  if (data["f[grade|7-8]"]) { grades.push("7-8") }
  if (data["f[grade|9-12]"]) { grades.push("9-12") }

  // -------------------------------------------------------

  steamstr = {
    "S": "Science",
    "T": "Technology",
    "E": "Engineering",
    "A": "Arts",
    "M": "Mathematics",
    "+": "+"}
  format_option = function(x) {
    return "<label> <input name='f[choices|"+ x + "]' value='true' type='checkbox'> <span>"+ x +"</span> </label>"
  }

  format_question = function(x, opts) {
    if (opts.length===0) { return ""}
    else{
    return "<fieldset><h4>" + steamstr[x] + "</h4>" + opts + "</fieldset>"
    }
  }

  getages = function(ages, steam) {
    return _.uniq(_.flatten(_.map(ages, function(x) { return _.map(Window.choices[x][steam], format_option) }))).join("")
  }

  choices = _.map(steams, function(x) { return format_question(x, getages(grades, x)) }).join("")
 $('#choices').html(choices) 
  }
};

// -------------------------------------------------------
validate_page = function(pg) {
  var res 
  switch(pg) {
    case 1: res = validate_page1()
    break
    case 2: res = []//validate_page2()
    break
    case 3: res = []//validate_page3()
    break
  }
  return res
}

validate_page1 = function() {
  var warnings= []
  if(!validate_text('nick')) { warnings.push("Please enter a nickname longer than three characters") }
  if(!validate_multi('grade')) { warnings.push("Please select at least one grade level") }
  if(!validate_multi('steam')) { warnings.push("Please select at least one of STEAM+") }
  return warnings
}

validate_text = function(field) {
  return $('input[name*=' + field + ']').val().length > 3
}

validate_multi = function(sel) {
  return _.reduce($('input[name*=' + sel + ']'), function(acc, x){ return acc || $(x).attr('checked')}, false)
}

