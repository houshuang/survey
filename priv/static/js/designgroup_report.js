$(document).ready(function() {
  P = window.Phoenix
  socket = new P.Socket("/ws")
  socket.connect()
  chan = socket.chan("admin", {})
  chan.join()
  chan.on('join', function(e) { 
    console.log("join", e)
    Window.presence = e.room_users
    render_presence() 
  })
  chan.on('user:entered', function(e) {
    Window.presence.push(e.msg.userid)
    Window.presence = _.compact(_.intersection(Window.presence))
    console.log("User entered", e, Window.presence)
    render_presence() 
  })
  chan.on('user:left', function(e) {
    console.log("User left", e, Window.presence)
    Window.presence = _.compact(_.without(Window.presence, e.msg.userid))
    render_presence() 
    add_chat(info_line({msg: e.usernick + " left"}))
  })
  chan.on('color', function(e) {
    $("#header").css('background', e.color)
    if (e.color == "White") { back = "; background-color: black;" } else { back = ";" }
    add_chat("<p style='color: " + e.color + back + "'>" + e.user + " changed the color</font>") 
  })

  chan.on('new:msg', function(e) {add_msg(e)})
  $("form#textentry").on("submit", function() { 
    send_msg()
    return false 
  })

  $("#input").on("keypress", function(e)  {
    if (e.keyCode == 13) {
      send_msg()
      return false
    }
  })
  $(".color").on("click", function(e) { 
    color = $(this).text()
    chan.push("color", {user: user, color: color})
    return false
  })
})

send_msg = function() {
  payload = {user: user, body: $("#input").val()}
  chan.push("new:msg", payload)
  $('#input').selectRange(0);
  $("#input").val("")
}
var info_line = _.template('<li class="message"> <span class="info"><span class="time"><%= moment.utc().format("h:mm a UTC") %> - <%= msg %></span> </li>')
var message_line = _.template('<li class="message"> <span class="info"><span class="time"><%= moment(time).format("h:mm a UTC") %> - </span><span class="name"><%= user %>: </span></span><span class="messagetext"><%= body %></span> </li>')

var date_line = _.template(' <li class="date"> <span class="info"><%= date %></span></li>')
old_date = ""

add_msg = function(c) { 
  e = c.msgstruct
  room = c.room
  console.log(e)
  new_date = moment(e.time).format("MMMM Do, YYYY")
  if(old_date != new_date) {
    add_chat(date_line({date: new_date}))
    old_date = new_date
  }
  add_chat(message_line(e), room)
}

render_presence = function() {
  pres = _.map(Window.presence, function(x) { return x + "" } )
  console.log(pres)
  $('.presence').each(function() { 
    if(~pres.indexOf(this.id)) {
      $(this).addClass('online').removeClass('offline')
    } else {
      $(this).removeClass('online').addClass('offline')
    }
  })
}

last_chat = ""
add_chat = function(chat) {
  if (!(last_chat == chat)) {
    $(".chat#" + room).prepend(chat)
    last_chat = chat
  }
}

$.fn.selectRange = function(start, end) {
  if(!end) end = start; 
  return this.each(function() {
    if (this.setSelectionRange) {
      this.focus();
      this.setSelectionRange(start, end);
    } else if (this.createTextRange) {
      var range = this.createTextRange();
      range.collapse(true);
      range.moveEnd('character', end);
      range.moveStart('character', start);
      range.select();
    }
  });
};
