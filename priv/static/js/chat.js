$(document).ready(function() {
  P = window.Phoenix
  socket = new P.Socket("/ws")
  socket.connect()
  chan = socket.chan("rooms:lobby", {})
  chan.join().receive("ok", function() {
    console.log(["ok", this])
  }).
    receive("error", function() { console.log(["error", this]) }).receive("new:msg", function() {console.log(["newmsg", this]) })
})
