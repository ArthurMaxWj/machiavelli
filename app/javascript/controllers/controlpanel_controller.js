import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["commands", "prompt", "commandsTabbtn", "promptTabbtn"];
  static values = { current: String };
  static classes = ["hidden"];

  connect() {
    this.paginate(this.commandsTarget, this.promptTabbtnTarget);
  }

  switchTab(event) {
    let { name } = event.params;
    this.currentValue = name;

    this.paginate(this.byName(name), this.oppositeTabbtnByName(name));
  }

  paginate(targetTab, targetTabbtn) {
    this.hideAll();
    targetTab.classList.remove(this.hiddenClass);
    targetTabbtn.classList.remove(this.hiddenClass);
  }

  hideAll() {
    this.commandsTarget.classList.add(this.hiddenClass);
    this.promptTarget.classList.add(this.hiddenClass);

    this.commandsTabbtnTarget.classList.add(this.hiddenClass);
    this.promptTabbtnTarget.classList.add(this.hiddenClass);
  }

  byName(pageName) {
    switch (pageName) {
      case "commands":
        return this.commandsTarget;
      case "prompt":
        return this.promptTarget;
    }
  }

  oppositeTabbtnByName(pageName) {
    switch (pageName) {
      case "commands":
        return this.promptTabbtnTarget;
      case "prompt":
        return this.commandsTabbtnTarget;
    }
  }
}