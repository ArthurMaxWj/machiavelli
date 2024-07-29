import { Controller } from "@hotwired/stimulus"
import popup from "shared/popup"


export default class extends Controller {
  static targets = ["commands", "prompt", "infoerrors", 
                    "commandsTabbtn", "promptTabbtn", "infoerrorsTabbtn",
                    "fatalerror"
  ]
  static values = { current: String }
  static classes = ["hidden"]

  connect() {
    let [tab, btn] = this.byName("commands")
    this.paginate(tab, btn)
    
    this.fatalPopup(this.fatalerrorTarget)
  }

  switchTab(event) {
    let { name } = event.params
    this.currentValue = name

    let [tab, btn] = this.byName(name)
    this.paginate(tab, btn)
  }

  paginate(targetTab, targetTabbtn) {
    this.hideAllTabs()
    this.showAllBtns()

    targetTab.classList.remove(this.hiddenClass)
    targetTabbtn.classList.add(this.hiddenClass)
  }

  hideAllTabs() {
    this.commandsTarget.classList.add(this.hiddenClass)
    this.promptTarget.classList.add(this.hiddenClass)
    this.infoerrorsTarget.classList.add(this.hiddenClass)

    
  }

  showAllBtns() {
    this.commandsTabbtnTarget.classList.remove(this.hiddenClass)
    this.promptTabbtnTarget.classList.remove(this.hiddenClass)
    this.infoerrorsTabbtnTarget.classList.remove(this.hiddenClass)
  }

  byName(name) {
    let correspondences = {
      "commands": [this.commandsTarget, this.commandsTabbtnTarget],
      "prompt": [this.promptTarget, this.promptTabbtnTarget],
      "infoerrors": [this.infoerrorsTarget, this.infoerrorsTabbtnTarget]
    }
    return correspondences[name]
  }

  fatalPopup(target) {
    let errorOccured = target.innerHTML.trim().length > 0
    if (errorOccured) {
      popup(target.innerHTML, "color-level-4")
    }
  }
}
