import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "deckbox"
  ]
  static values = {
    decksize: Number
  }

  connect() {
    this.resizeDeckBox(this.decksizeValue)
  }

  /* used to block y-scroll, makes deck look better */
  resizeDeckBox(dsize) {
    let cardWidth = 147
    let boxWidth = cardWidth * dsize
    this.deckboxTarget.style.width = boxWidth + "px"
  }

  
  decksizeValueChanged(v) {
    this.resizeDeckBox(v)
  }
}
