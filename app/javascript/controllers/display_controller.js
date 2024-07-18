import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["tcard", "dcard", "spot", "tcounter", "dcounter", "scounter", "detected", "cmdargs", "submit"]
	static values = {tselected: Array, dselected: Array, sselected: Array}
	static classes = ["cselected", "sselected", "detected"]
	
	connect() {
		this.clearAll()
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
  let {cardno} = event.params

	this.swapSelectionDcard(cardno)
  }
  
  clearAll() {
	this.tselectedValue = []
	this.sselectedValue = []
	this.dselectedValue = []
  }
  
  
// UPDATING UI EVENTS:
  
  dselectedValueChanged(v) {
	  let self = this
	this.dcardTargets.forEach(function(card) {
		let { cardno } = card.dataset
		
		
		self.swapClassDcard(cardno)
	})
	this.dcounterTarget.innerHTML = v.length
	this.updateDetection()
	this.updateCmdArgs()
  }
  
  sselectedValueChanged(v) {
	  let self = this
	this.spotTargets.forEach(function(spot) {
		let { combno, spotno } = spot.dataset

		self.swapClassSpot(combno, spotno)
	})
	this.scounterTarget.innerHTML = v.length
	this.updateDetection()
	this.updateCmdArgs()
  }
	
  tselectedValueChanged(v) {
	 let self = this
	this.tcardTargets.forEach(function(card) {
		let { combno, cardno } = card.dataset

		self.swapClassTcard(combno, cardno)
	})
	this.tcounterTarget.innerHTML = v.length
	this.updateDetection()
	this.updateCmdArgs()
	
	this.updateSubmitRequiremnents()
  }
  
  	updateDetection() {
		let cmd = this.cmdDetect()
		this.detectedTarget.innerHTML = cmd.join(" ")
		this.highlightDetected(cmd)
	}
	
	updateCmdArgs() {
		let v = this.constructCmdArgs()

		this.cmdargsTargets.forEach(function(t) {
			t.value = v
		})
	}
	
	constructCmdArgs() {
	 	let ds = this.dselectedValue.map(card => ({combno: 0, cardno: card.cardno}) )
		let leftSide = this.tselectedValue.concat(ds).map(card => card.combno + "-" + card.cardno).join(",")
		let rightSide = this.sselectedValue.map(spot => spot.combno + "-" + spot.spotno).join(",")
		
		return (leftSide == "" ? "_" : leftSide) + ":" + (rightSide == "" ? "_" : rightSide)
	}
	
	updateSubmitRequiremnents() {
		let self = this
		this.submitTargets.forEach(function(t) {
			let r = self.requirementsOf(t.value)
			t.click = function(e) {
				if (!self.cmdDetect().contains(t.value)) {
					e.preventDefault()
					let req = self.requirementsOf(t.value)
					self.requirementserrorTarget.innerHtml = (
						"Requirements not met for comand" + t.value + ": Requires " +
						r.d + " deck cards, " + r.t + " table cards, " + r.s + " table spots"
						)
				}
			} 
		})
	}

	highlightDetected(cmd) {
		let self = this
		this.submitTargets.forEach(function(t) {
			console.log(t, t.getAttribute('data-cmd') == cmd)
			if (t.getAttribute('data-cmd') == cmd) {
				t.classList.add(self.detectedClass)
			} else {
				t.classList.remove(self.detectedClass)
			}
		})
	}

	
  
  
// HELPER METODS:
  
  isSelectedTcard(combno, cardno) {
	return this.tselectedValue.some(e => e.combno == combno && e.cardno == cardno)
  }
  
  isSelectedSpot(combno, spotno) {
	return this.sselectedValue.some(e => e.combno == combno && e.spotno == spotno)
  }
  
  isSelectedDcard(cardno) {
	return this.dselectedValue.some(e => e.cardno == cardno)
  }
	
	// ----
  
  
  tcardBy(combno, cardno) {
	  return this.tcardTargets.find( target => target.dataset.combno == combno && target.dataset.cardno == cardno)
  }
  
  spotBy(combno, spotno) {
	 return  this.spotTargets.find( target => target.dataset.combno == combno && target.dataset.spotno == spotno)
  }
  
  dcardBy(cardno) {
	  return this.dcardTargets.find( target => target.dataset.cardno == cardno)
  }
  
    // ----

  
  swapSelectionTcard(combno, cardno) {
	let selected = this.isSelectedTcard(combno, cardno)
	  
	if (selected) {
		this.tselectedValue = this.tselectedValue.filter(function(e){
			return !(e.combno == combno && e.cardno == cardno)
		})
	} else {
		this.tselectedValue = this.tselectedValue.concat([{combno: combno, cardno: cardno}])
	}
  }
  
  swapSelectionSpot(combno, spotno) {
	let selected = this.isSelectedSpot(combno, spotno)
	  
	if (selected) {
		this.sselectedValue = this.sselectedValue.filter(e => !(e.combno == combno && e.spotno == spotno))
	} else {
		this.sselectedValue = this.sselectedValue.concat([{combno: combno, spotno: spotno}])
	}
  }
  
  swapSelectionDcard(cardno) {
	let selected = this.isSelectedDcard(cardno)

	if (selected) {
		this.dselectedValue = this.dselectedValue.filter(e => e.cardno != cardno)
	} else {
		this.dselectedValue = this.dselectedValue.concat([{cardno: cardno}])
	}
  }
  
  
  // ----
  
  swapClassTcard(combno, cardno) {
	let selected = this.isSelectedTcard(combno, cardno)
	  
	if (!selected) {
		this.tcardBy(combno, cardno).classList.remove(this.cselectedClass)
	} else {
		this.tcardBy(combno, cardno).classList.add(this.cselectedClass)
	}
  }
  
   swapClassSpot(combno, spotno) {
	let selected = this.isSelectedSpot(combno, spotno)
	  
	if (!selected) {
		this.spotBy(combno, spotno).classList.remove(this.sselectedClass)
	} else {
		this.spotBy(combno, spotno).classList.add(this.sselectedClass)
	}
  }
  
  swapClassDcard(cardno) {
	let selected = this.isSelectedDcard(cardno)

	if (!selected) {
		this.dcardBy(cardno).classList.remove(this.cselectedClass)

	} else {
		this.dcardBy(cardno).classList.add(this.cselectedClass)
	}
  }
  
  // DECTECTION OF COMMAND: 
 
	cmdDetect() {
		let t = this.tselectedValue.length
		let s = this.sselectedValue.length
		let d = this.dselectedValue.length
		
		let c = this.commands().filter( c => c.t == t && c.s == s && c.d == d)
		
		return c.length > 0 ? c.map( c => c.identifier) : ["?"]
	}

	commands() {
		return [
			{t: 0, s: 0, d: 3, identifier: "n"},
			{t: 1, s: 1, d: 0, identifier: "m"},
			{t: 0, s: 1, d: 1, identifier: "p"},
			{t: 0, s: 1, d: 0, identifier: "b"}
		]
	}
	
	requirementsOf(id) {
		this.commands().find(c => c.identifier == id)
	}
}
