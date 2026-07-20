import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turn-timer"
export default class extends Controller {
  static values = { duration: Number }
  static targets = [ "display" ]

  connect() {
    this.timeLeft = this.durationValue
    this.updateDisplay()
  
    this.timer = setInterval(() => { this.tick() }, 1000)
  }

  updateDisplay() {
    this.displayTarget.textContent = this.timeLeft
  }

  tick() {
    this.timeLeft--
    this.updateDisplay()
  
    if (this.timeLeft <= 0) {
      clearInterval(this.timer)
      this.dispatch("ended")
    }
  }
}
