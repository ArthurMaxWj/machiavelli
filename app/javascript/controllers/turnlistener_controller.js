import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    ourplayer: String,
    intervalId: Number,
    responseTurn: String
  }

  connect() {
    console.log('ok')
    this.responseTurnValue = '{"player_turn": "<unknown>}"}'
    this.startListening()
  }

  startListening() {
    console.log('i am list')
    this.intervalIdValue = setInterval( () => {
        this.ajaxGetPlayerTurn()
        console.log("json:", `'${this.responseTurnValue}'`)
        let playerTurn = JSON.parse(this.responseTurnValue)['player_turn']
        console.log("turn:", `'${playerTurn}'`)

        if (this.ourplayerValue == this.responseTurnValue) {
          console.log("ourplayerValue:", this.ourplayerValue)
            this.stopListening()
            // this.goHome()
        }
    }, 1000)
 }

 stopListening() {
    clearInterval(this.intervalIdValue)
 }

 goHome() {
    window.location.href = "/"
 }

 ajaxGetPlayerTurn() {
      const xhttp = new XMLHttpRequest()
      let self = this
      xhttp.onload = function() {
        self.responseTurnValue = this.responseText
      }
      xhttp.open("GET", "/whose-turn");
      xhttp.send();
    }
}
