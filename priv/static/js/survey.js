$(document).ready(function () {

  if ( typeof(Window.Survey) == "undefined" ) {
    Window.Survey = { cur: 1, max: $(".section").length 
  }}
survey = Window.Survey;
  percent = 100 * (1 / survey.max);
  progtext = 1 + "/" + survey.max; 
  $(".progress-bar")
    .css({width: percent+ "%"})
    .text(progtext);
  window.scrollTo(0,0);

  $('#form').submit(function(e) {
    e.preventDefault();    

    $.post("/tags/submit", $("#form").serialize(), function(data){
        alert(data);
    });
 
  var survey = Window.Survey;
  var cur = survey.cur;
  var next = cur + 1;

  if ( next == survey.max ) {
    $("#submit").attr("value", "Submit")
  };

  $("#section" + cur).hide();
  survey.cur = next;
  $("#section" + next).show();
  percent = 100 * (next / survey.max);
  progtext = next + "/" + survey.max; 
  $(".progress-bar")
    .css({width: percent+ "%"})
    .text(progtext);
  window.scrollTo(0,0);


})})
