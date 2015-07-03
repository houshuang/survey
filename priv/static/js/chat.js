$(document).ready(function() {
Window.presence = []
  P = window.Phoenix
  socket = new P.Socket("/ws", {
  logger: function(kind, msg, data) { if (! msg.match("phx") && (! msg.match("error")) && (! msg.match("ping"))) { console.log(`${kind}: ${msg}`, data)} }})
  socket.connect()
  chan = socket.chan("rooms:" + id, {user: user})
  chan.join()
  chan.on('join', function(e) { 
    Window.presence = e.presence
    render_presence() 
  })
  chan.on('user:entered', function(e) {
    Window.presence.push(e.user)
    Window.presence = _.intersection(Window.presence)
    render_presence() 
    if(e.user != user) {
      add_chat("<b>" + e.user + " joined")
    }
  })
  chan.on('user:left', function(e) {
    Window.presence = _.without(Window.presence, e.user)
    render_presence() 
    add_chat("<b>" + e.user + " left")
  })
  chan.on('color', function(e) {
    $("#header").css('background', e.color)
    if (e.color == "White") { back = "; background-color: black;" } else { back = ";" }
    add_chat("<p style='color: " + e.color + back + "'>" + e.user + " changed the color</font>") 
  })

  chan.on('new:msg', function(e) {add_msg(e)})
  $("form").on("submit", function() { return false })
  $("#input").on("keypress", function(e)  {
    if (e.keyCode == 13) {
      payload = {user: user, body: $("#input").val()}
      chan.push("new:msg", payload)
      $("#input").val("")
      // add_msg(payload)
    }
  })
  $(".color").on("click", function(e) { 
    color = $(this).text()
    chan.push("color", {user: user, color: color})
    return false
  })
})
add_msg = function(e) { 
  add_chat(e.body + " (<i>" + e.user + "</i>)") 
}

render_presence = function() {
  pres = Window.presence
  txt = _.map(pres, function(x) { return "<li>" + x + "</li>" }).join("")
  console.log(txt)
  $("#presence").html(txt)
}

last_chat = ""
add_chat = function(chat) {
  if (!(last_chat == chat)) {
    $("#history").prepend("<li>" + chat + "</li>")
    last_chat = chat
  }
}

