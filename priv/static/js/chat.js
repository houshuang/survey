$(document).ready(function() {
  Window.App = {}
  $('.modalform textarea').each(function(){
    var T = $(this);
    check_textarea_length(T, 10)
    T.on('keyup', function() {Window.App.area = check_textarea_length(T, 10) })
  });
  $('.modalform input').each(function(){
    var T = $(this);
    check_textarea_length(T, 2)
    T.on('keyup', function() {Window.App.text = check_textarea_length(T, 2) })
  });
  $('.modalform').on('submit', function(e) {
    e.preventDefault();    
    if(Window.App.text && Window.App.area) {
    $.post("/collab/email", $(".modalform").serialize(), function(data){
        console.log(data);
    });
    $(".close")[0].click();
    }
    return false;
  })

  topics = {
    "topics": "Topics", 
    "description": "Short description...", 
    "howtech": "How can technology help..."
  }
  Window.detail_ready = false
  Window.detail_queue = []
  $('#input').selectRange(0);
  $("#input").val("")
  Window.presence = []
  P = window.Phoenix
  socket = new P.Socket("/ws")
  socket.connect()
  chan = socket.chan("rooms:" + Window.groupid, 
                     {usernick: Window.usernick, userid: Window.userid})
  chan.join()
  chan.on('join', function(e) { 
    // console.log("join", e)
    Window.presence = _.map(e.presence, function(x) { return x.userid })
    render_presence() 
    $("#history").html("")
    _.each(e.previous, function(x) { add_msg(x) })
  })
  chan.on('user:entered', function(e) {
    Window.presence.push(e.userid)
    Window.presence = _.compact(_.intersection(Window.presence))
    // console.log("User entered", e, Window.presence)
    render_presence() 
    add_chat(info_line({msg: e.usernick + " joined"}))
  })
  chan.on('user:left', function(e) {
    // console.log("User left", e, Window.presence)
    Window.presence = _.compact(_.without(Window.presence, e.userid))
    render_presence() 
    add_chat(info_line({msg: e.usernick + " left"}))
  })
  chan.on('edit:lock', function(e) {
    console.log("edit:lock", e)
    if(e.user != Window.usernick) {
      sendFrame(e)
      if(e.msg) {
        add_chat(info_line({ msg: "<b>" + e.user + e.msg + topics[e.topic] + "</b>" }))
      }
    }
  })
  chan.on('edit:open', function(e) {
    console.log("edit:open", e.data)
    if(e.user != Window.usernick) {
      add_chat(info_line({ msg: "<b>" + e.user + e.msg + topics[e.topic] + "</b>" }))
      $("#detail_iframe")[0].contentWindow.postMessage(e, "*")
    }
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
  //
// Create IE + others compatible event handler
  var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
  var eventer = window[eventMethod];
  var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

  // Listen to message from child window
  eventer(messageEvent,function(e) {
    if(e.data.ready) {
      Window.detail_ready = true; sendFrameQueued() 
    } else {
      if(e.data.save) { kind = "edit:open" } else { kind = "edit:lock" }
      console.log(kind, e.data)
      chan.push(kind, $.extend({user: user}, e.data),false); 
    }
  })
})

function sendFrame(e) {
  if (Window.detail_ready) {
    console.log("Window ready")
    $("#detail_iframe")[0].contentWindow.postMessage(e, "*")
  } else {
    console.log("Queueing")
    Window.detail_queue.push(e)
  }
}

function sendFrameQueued() {
  console.log("Sending ready", Window.detail_queue)
  _.each(Window.detail_queue, function(x) {
    sendFrame(x)
  })
}

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

add_msg = function(e) { 
  // console.log(e)
  new_date = moment(e.time).format("MMMM Do, YYYY")
  if(old_date != new_date) {
    add_chat(date_line({date: new_date}))
    old_date = new_date
  }
  add_chat(message_line(e))
}

render_presence = function() {
  pres = _.map(Window.presence, function(x) { return x + "" } )

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
    $(".chatarea").prepend(chat)
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

check_textarea_length = function(T, min) {
  var len = T.val().trim().split(" ").length;
  if (len >= min) {
    T.next('.counter').html("<font color=green>✓</font>");
    return true;
  } else {
    T.next('.counter').html("<font color=red>At least " + (min - len) + " more words required</font>");
    return false;
  }         
}
