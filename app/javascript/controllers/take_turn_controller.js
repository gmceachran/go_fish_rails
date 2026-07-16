import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="take-turn"
export default class extends Controller {
  static targets = [ "submitButton" ]

  connect() {
    
  }

  endTurn(event) {
    this.submitButtonTarget.click()
  }
}
