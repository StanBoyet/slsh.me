import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "taken"]
  static values  = { existsUrl: String }

  #timer = null

  check() {
    clearTimeout(this.#timer)
    const slug = this.inputTarget.value.trim()
    if (!slug) { this.takenTarget.classList.add("hidden"); return }

    this.#timer = setTimeout(() => this.#verify(slug), 350)
  }

  async #verify(slug) {
    try {
      const res  = await fetch(`/links/check_slug?slug=${encodeURIComponent(slug)}`, {
        headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content }
      })
      const data = await res.json()
      this.takenTarget.classList.toggle("hidden", !data.taken)
    } catch { /* ignore network errors */ }
  }
}
