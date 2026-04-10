import { Controller } from "@hotwired/stimulus"

// Watches for new visit rows (via Turbo Stream) and sequentially
// reloads each analytics turbo-frame with a staggered cascade.
export default class extends Controller {
  static targets = ["frame"]
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.addedNodes.length > 0) {
          this.refreshAll()
          break
        }
      }
    })

    const tbody = document.getElementById("visits-table-body")
    if (tbody) {
      this.observer.observe(tbody, { childList: true })
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  refreshAll() {
    // Debounce: if multiple rows arrive at once, only refresh once
    if (this.refreshTimer) return
    this.refreshTimer = setTimeout(() => {
      this.refreshTimer = null
      this.cascadeRefresh()
    }, 500)
  }

  cascadeRefresh() {
    this.frameTargets.forEach((frame, index) => {
      setTimeout(() => {
        frame.src = frame.dataset.src
        frame.reload()
      }, index * this.delayValue)
    })
  }
}
