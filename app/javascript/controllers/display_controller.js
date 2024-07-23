import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tcard",
    "dcard",
    "spot",
    "tcounter",
    "dcounter",
    "scounter",
    "detected",
    "cmdargs",
    "submit",
    "deckbox",
    "spin",
    "requirementserror",
    "tocoloronreqnotmet"
  ]
  static values = {
    tselected: Array,
    dselected: Array,
    sselected: Array,
    decksize: Number,
  }
  static classes = ["cselected", "sselected", "detected", "spin", "reqerrcolor"]

  connect() {
    this.clearAll()
    this.updateDetection()
    this.resizeDeckBox(this.decksizeValue)
  }

  /* used to block y-scroll, makes deck look better */
  resizeDeckBox(dsize) {
    let cardWidth = 147
    let boxWidth = cardWidth * dsize
    this.deckboxTarget.style.width = boxWidth + "px"
  }


  // KEYDOWN EVENTS:


  nCalled() {
    this.callCommandByLetter("n")
  }

  mCalled() {
    this.callCommandByLetter("m")
  }

  pCalled() {
    this.callCommandByLetter("p")
  }

  bCalled() {
    this.callCommandByLetter("b")
  }

  // MOUSE EVENTS:

  spin() {
    this.spinTarget.classList.add(this.spinClass)
  }

  nospin() {
    this.spinTarget.classList.remove(this.spinClass)
  }

  // SELECTING EVENTS:


  selectTableCard(event) {
    let { combno, cardno } = event.params

    this.swapSelectionTcard(combno, cardno)
  }

  selectSpot(event) {
    let { combno, spotno } = event.params

    this.swapSelectionSpot(combno, spotno)
  }

  selectDeckCard(event) {
    let { cardno } = event.params

    this.swapSelectionDcard(cardno)
  }

  clearAll() {
    this.tselectedValue = []
    this.sselectedValue = []
    this.dselectedValue = []
  }


  // UPDATING UI EVENTS:

  clearAllOf(spotsOrCards) {
    let cls = [this.sselectedClass, this.cselectedClass, 
              this.selectionLevel(0), this.selectionLevel(1), this.selectionLevel(2), 
              this.selectionLevel(3) // out of bounds
    ] 
    spotsOrCards.forEach( (sc) => cls.forEach( (cl) => sc.classList.remove(cl)))
  }

  dselectedValueChanged(v) {
    this.clearAllOf(this.dcardTargets)
    let sel = this.dselectedValue.map((v) => {
      let {cardno} = v
      return this.dcardBy(cardno)
    })
  
    sel.forEach((card, idx) => {
      this.swapClassDcard(card, idx)
    })

    this.dcounterTargets.forEach((t) => (t.innerHTML = v.length))
    this.updateDetection()
    this.updateCmdArgs()
  }

  sselectedValueChanged(v) {
    this.clearAllOf(this.spotTargets)

    let sel = this.sselectedValue.map((v) => {
      let {combno, spotno} = v
      return this.spotBy(combno, spotno)
    })

    sel.forEach((spot, idx) => {
      this.swapClassSpot(spot, idx)
    })

    this.scounterTargets.forEach((t) => (t.innerHTML = v.length))
    this.updateDetection()
    this.updateCmdArgs()
  }

  tselectedValueChanged(v) {
    this.clearAllOf(this.tcardTargets)
    let sel = this.tselectedValue.map((v) => {
      let {combno, cardno} = v
      return this.tcardBy(combno, cardno)
    })

    sel.forEach((card, idx) => {
      this.swapClassTcard(card, idx)
    })

    this.tcounterTargets.forEach((t) => (t.innerHTML = v.length))
    this.updateDetection()
    this.updateCmdArgs()
  }


  decksizeValueChanged(v) {
    this.resizeDeckBox(v)
  }

  // shows error when clicking commands with wrong requirements
  checkCmdRequiremnentsMet(e) {
    let cmd = e.target.getAttribute("data-cmd")
    let rq = this.requirementsOf(cmd)

    if (!this.cmdDetect().includes(cmd)) {
      e.preventDefault() // we dont send form as is invalid

      this.requirementserrorTarget.innerHTML = (
        `Requirements not met for comand ${cmd}:` +
        `Requires ${rq.d} deck cards, ${rq.t} table cards, ${rq.s} table spots`
      )
      this.tocoloronreqnotmetTarget.classList.add(this.reqerrcolorClass)
    }
  }

  updateDetection() {
    let info =
      "[ None: Each command needs to satisfy requirements: (no. of table cards, no. of spots in  table, no. of deck cards) order of each matters ]"
    let cmd = this.cmdDetect()

    let msg = cmd.join(" ")
    this.detectedTarget.innerHTML = msg.length == 0 ? info : msg

    this.highlightDetected(cmd)
  }

  updateCmdArgs() {
    let v = this.constructCmdArgs()

    this.cmdargsTargets.forEach(function (t) {
      t.value = v
    })
  }

  constructCmdArgs() {
    let ds = this.dselectedValue.map((card) => ({
      combno: 0,
      cardno: card.cardno,
    }))
    let leftSide = this.tselectedValue
      .concat(ds)
      .map((card) => card.combno + "-" + card.cardno)
      .join(",")
    let rightSide = this.sselectedValue
      .map((spot) => spot.combno + "-" + spot.spotno)
      .join(",")

    return (
      (leftSide == "" ? "_" : leftSide) +
      ":" +
      (rightSide == "" ? "_" : rightSide)
    )
  }

  highlightDetected(cmd) {
    let self = this
    this.submitTargets.forEach(function (t) {
      if (t.getAttribute("data-cmd") == cmd) {
        t.classList.add(self.detectedClass)
      } else {
        t.classList.remove(self.detectedClass)
      }
    })
  }


  // HELPER METODS:


  isSelectedTcard(combno, cardno) {
    return this.tselectedValue.some(
      (e) => e.combno == combno && e.cardno == cardno
    )
  }

  isSelectedSpot(combno, spotno) {
    return this.sselectedValue.some(
      (e) => e.combno == combno && e.spotno == spotno
    )
  }

  isSelectedDcard(cardno) {
    return this.dselectedValue.some((e) => e.cardno == cardno)
  }

  // ----

  tcardBy(combno, cardno) {
    return this.tcardTargets.find(
      (target) =>
        target.dataset.combno == combno && target.dataset.cardno == cardno
    )
  }

  spotBy(combno, spotno) {
    return this.spotTargets.find(
      (target) =>
        target.dataset.combno == combno && target.dataset.spotno == spotno
    )
  }

  dcardBy(cardno) {
    return this.dcardTargets.find((target) => target.dataset.cardno == cardno)
  }

  // ----

  swapSelectionTcard(combno, cardno) {
    let selected = this.isSelectedTcard(combno, cardno)

    if (selected) {
      this.tselectedValue = this.tselectedValue.filter(function (e) {
        return !(e.combno == combno && e.cardno == cardno)
      })
    } else {
      this.tselectedValue = this.tselectedValue.concat([
        { combno: combno, cardno: cardno },
      ])
    }
  }

  swapSelectionSpot(combno, spotno) {
    let selected = this.isSelectedSpot(combno, spotno)

    if (selected) {
      this.sselectedValue = this.sselectedValue.filter(
        (e) => !(e.combno == combno && e.spotno == spotno)
      )
    } else {
      this.sselectedValue = this.sselectedValue.concat([
        { combno: combno, spotno: spotno },
      ])
    }
  }

  swapSelectionDcard(cardno) {
    let selected = this.isSelectedDcard(cardno)

    if (selected) {
      this.dselectedValue = this.dselectedValue.filter(
        (e) => e.cardno != cardno
      )
    } else {
      this.dselectedValue = this.dselectedValue.concat([{ cardno: cardno }])
    }
  }

  // ----

  swapClassTcard(card, idx)  {
    card.classList.add(this.cselectedClass)
    card.classList.add(this.selectionLevel(idx))
  }

  swapClassSpot(spot, idx) {
    spot.classList.add(this.sselectedClass)
    spot.classList.add(this.selectionLevel(idx))
  }

  swapClassDcard(card, idx) {
    card.classList.add(this.cselectedClass)
    card.classList.add(this.selectionLevel(idx))
  }

  selectionLevel(num) {
    if (num < 3) {
      return `selection-level-${num + 1}`
    } else {
      return `selection-level-outofbounds`
    }
  }


  // DETECTION OF COMMANDS:


  cmdDetect() {
    let t = this.tselectedValue.length
    let s = this.sselectedValue.length
    let d = this.dselectedValue.length

    let c = this.commands().filter((c) => c.t == t && c.s == s && c.d == d)

    return c.length > 0 ? c.map((c) => c.identifier) : [""]
  }

  commands() {
    return [
      { t: 0, s: 0, d: 3, identifier: "n" },
      { t: 1, s: 1, d: 0, identifier: "m" },
      { t: 0, s: 1, d: 1, identifier: "p" },
      { t: 0, s: 1, d: 0, identifier: "b" },
    ]
  }

  requirementsOf(id) {
    return this.commands().find((c) => c.identifier == id)
  }

  callCommandByLetter(letter) {
    this.submitTargets.forEach(function (t) {
      if (t.getAttribute("data-cmd") == letter) {
        t.click()
      }
    })
  }
}
