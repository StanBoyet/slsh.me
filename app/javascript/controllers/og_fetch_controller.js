import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner"]
  static values = { url: String }

  async fetch() {
    const urlField = document.querySelector("[name='link[original_url]']")
    const url = urlField?.value?.trim()
    if (!url) return

    this.buttonTarget.disabled = true
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.remove("hidden")

    try {
      const token = document.querySelector("meta[name='csrf-token']")?.content
      const res = await window.fetch(this.urlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": token, "Accept": "application/json" },
        body: JSON.stringify({ url })
      })
      const data = await res.json()

      if (data.title) {
        const titleField = document.querySelector("[name='link[title]']")
        if (titleField) titleField.value = data.title
      }
      if (data.description) {
        const descField = document.querySelector("[name='link[description]']")
        if (descField) descField.value = data.description
      }
    } catch { /* ignore */ } finally {
      this.buttonTarget.disabled = false
      if (this.hasSpinnerTarget) this.spinnerTarget.classList.add("hidden")
    }
  }
}
