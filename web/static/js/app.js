import {Socket} from "phoenix"


class App {
  static init(){
    let socket = new Socket("/ws")
    socket.connect()
    let chan = socket.chan("rooms:lobby", {})
    chan.join().receive("ok", chan => {
      console.log("Welcome to Phoenix Chat!")
    })
  }
}

$( () => App.init() )
export default App
