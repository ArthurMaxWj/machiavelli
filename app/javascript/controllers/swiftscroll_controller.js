import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["scrollballs"];
  static values = { abovecontentid: String };
  static classes = ["hidden"];

  connect() {
    this.showScrollBalls()
    this.scrollControl()

    /* OPTIMIZE use addEventListener ? or not?  | first fix scroll condition, look below */
    // let f = () =>  { this.scrollControl() } 
    // window.onscroll = f
    // window.onresize = f
  }

  // EVENTS:

  goTop() {
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
  }

  goBot() {
    document.body.scrollTop = document.body.scrollHeight; // For Safari
    document.documentElement.scrollTop = document.body.scrollHeight; // For Chrome, Firefox, IE and Opera
  }

  // HELPER METHODS:


  scrollControl() {
    // OPTIMIZE we might consider adding a condition for hiding scrollbars but none I found were satisfying or working, eg:
    /*
    let body = document.body
    let html = document.documentElement
    let docHeight = Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight)
    let winHeight =  Math.max( window.innerHeight, window.clientHeight, window.offsetHeight, window.scrollHeight ) 
    */
    
    if (true) {
        this.showScrollBalls()
    } else {
        this.hideScrollBalls()
    }
  }

  hideScrollBalls() {
    this.scrollballsTarget.classList.add(this.hiddenClass)
  }

  showScrollBalls() {
    this.scrollballsTarget.classList.remove(this.hiddenClass)
  }

}

