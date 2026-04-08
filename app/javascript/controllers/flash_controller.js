import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.messageTargets.forEach(el => {
      setTimeout(() => {
        el.style.transition = "opacity 0.4s ease"
        el.style.opacity    = "0"
        setTimeout(() => el.remove(), 400)
      }, 3500)
    })
  }
}
