$('document').ready(function () { 

  elements = ['topics', 'howtech', 'description']

  $('a.edit').on('click', function(e) { edit_click(this) })
  $("a.save").on('click', function() { save_and_close(unitname) })

  var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
  var eventer = window[eventMethod];
  var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
  console.log("Ready!")
  parent.postMessage({ready: true},"*");

  eventer(messageEvent,function(e) {
    if(e.data.save) {
      elem = e.data.topic
      $elem = $("#" + elem)
      if (e.data.newval) {
        $elem.html('<p id="' + elem + '">' + e.data.newval + '</p>')
      }
      $("#otheredit_" + e.data.topic).html("")
      $("#edit_" + elem).show()
      if($elem.hasClass('beingEdited')) {
        $elem.removeClass('beingEdited')
        $elemedit = $('#save_' + elem)
        $elemedit.hide()
        $("#edit_" + elem).show()
      }
    } else {
      $("#otheredit_" + e.data.topic).html("<font color=red>" + e.data.user + " is editing this field</font>")
      $("#edit_" + e.data.topic).hide()
    }

  })
})

function edit_click(that) {
  id = $(that).parent().attr('id')
  unitname = id.split("_")[1]
  unit = $("#" + unitname)
  if (!unit.hasClass('beingEdited')) {
    _.each(_.without(elements, unitname), function(x) { save_and_close(x) })
    unit.addClass('beingEdited')
    text = unit.text()
    unit.html('<div class=block><fieldset><textarea id="' + unitname + '_textedited">' + text + 
              '</textarea></fieldset></div>')
    $(that).parent().hide()
    $("#save_" + unitname).show()
    parent.postMessage({msg: " is now editing ", topic: unitname},"*");
  }
  return false 
}

function save_and_close(elem) {
  $elem = $('#' + elem)
  if ($elem.hasClass('beingEdited')) {
    $elem.removeClass('beingEdited')
    $elemedit = $('#save_' + elem)
    $elemedit.hide()
    $("#edit_" + elem).show()
    text = $('#' + elem + '_textedited').val()
    $elem.html('<p id="' + elem + '">' + text + '</p>')
    $.post('/design_groups/submit_edit', {id: designid, item: elem, value: text, session: session})
    parent.postMessage({save: true, item: elem, msg: " has finished editing ", topic: elem, newval: text},"*");
  }
}
