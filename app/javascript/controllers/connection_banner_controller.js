import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  connect() {
    this.showIfOffline = this.showIfOffline.bind(this)
    this.hideBanner = this.hideBanner.bind(this)

    this.showIfOffline()
    window.addEventListener("offline", this.showIfOffline)
    window.addEventListener("online", this.hideBanner)
  }

  disconnect() {
    window.removeEventListener("offline", this.showIfOffline)
    window.removeEventListener("online", this.hideBanner)
  }

  showIfOffline() {
    if (!navigator.onLine) {
      this.bannerTarget.classList.remove("hidden")
    }
  }

  hideBanner() {
    this.bannerTarget.classList.add("hidden")
  }
}
