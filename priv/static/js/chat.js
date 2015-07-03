$(document).ready(function() {
  heartbeatTimer = setInterval(sendHeartbeat, 5000);

  P = window.Phoenix
  socket = new P.Socket("/ws")
  socket.connect()
  chan = socket.chan("rooms:" + id, {})
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

})
add_msg = function(e) { $("#messages").append("<li>" + e.body + " (<i>" + e.user + "</i>)</li>") }
sendHeartbeat = function() {
  chan.push("heartbeat", {})
}

