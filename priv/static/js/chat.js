$(document).ready(function() {

  P = window.Phoenix
  socket = new P.Socket("/ws", {
  logger: function(kind, msg, data) { console.log(`${kind}: ${msg}`, data) }})
  socket.connect()
  chan = socket.chan("rooms:" + id, {user: user})
  chan.join()
  chan.on('new:msg', function(e) {add_msg(e)})
    $("#input").on("keypress", function(e)  {
      if (e.keyCode == 13) {
        payload = {user: $("#username").val(), body: $("#input").val()}
        chan.push("new:msg", payload)
        $("#input").val("")
        add_msg(payload)
      }
    })
  chan.on("", function(e) { console.log(e) })

})
add_msg = function(e) { $("#messages").append("<li>" + e.body + " (<i>" + e.user + "</i>)</li>") }

