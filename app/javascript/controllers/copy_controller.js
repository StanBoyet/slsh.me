import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "label"]
  static values  = { text: String }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      this.showCheckmark()
    })
  }

  showCheckmark() {
    if (this.hasIconTarget) {
      this.iconTarget.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M5 13l4 4L19 7"/>`
    }
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = "Copied!"
    }
    setTimeout(() => this.reset(), 2000)
  }

  reset() {
    if (this.hasIconTarget) {
      this.iconTarget.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/>`
    }
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = "Copy"
    }
  }
}
