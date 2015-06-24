$(document).ready(function(){

    $('.stepsController a').on('click', function() {buttonclick(this);});
  
});

buttonclick = function(e) {
  res = validate_page()
  console.log(res)
  if (res.length === 0) {
    $('.header').html("")

    if(e.text == "Submit") {
      $('form').submit();

      $('.blocks').html("<h3>Submitting and redirecting, please don't close window...</h3>")
    }
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

validate_page = function(pg) {
  var warnings= []
  if(!validate_select('sig_id')) { warnings.push("Please select a Special Interest Group (SIG)") }
  return warnings
}

validate_select = function(field) {
  return $('select[name*=' + field + ']').val() != "noselection"
}
