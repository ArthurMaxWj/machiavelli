import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["pages"];
  static values = { expanded: Boolean };
  static classes = ["hidden"];

  connect() {
    /* hides but it doesnt affect big screen version because of usage of 'hidden-on-small' class */
    this.hide()
    this.expandedValue = false
  }

  // EVENTS

  toggle() {
    this.expandedValue ? this.hide() : this.show()
    this.expandedValue = !this.expandedValue
  }
  
  // HELPER METHODS:

  hide() {
    this.pagesTarget.classList.add(this.hiddenClass)
  }

  show() {
    this.pagesTarget.classList.remove(this.hiddenClass)
  }
}
