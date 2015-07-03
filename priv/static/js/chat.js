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
  })
  chan.on('user:left', function(e) {
    Window.presence = _.without(Window.presence, e.user)
    render_presence() 
  })
  chan.on('new:msg', function(e) {add_msg(e)})
  $("form").on("submit", function() { return false })
  $("#input").on("keypress", function(e)  {
    if (e.keyCode == 13) {
      payload = {user: user, body: $("#input").val()}
      chan.push("new:msg", payload)
      $("#input").val("")
      add_msg(payload)
    }
  })
  chan.on("", function(e) { console.log(e) })

})
add_msg = function(e) { $("#history").append("<li>" + e.body + " (<i>" + e.user + "</i>)</li>") }

render_presence = function() {
  pres = Window.presence
  txt = _.map(pres, function(x) { return "<li>" + x + "</li>" }).join("")
  console.log(txt)
  $("#presence").html(txt)
}
