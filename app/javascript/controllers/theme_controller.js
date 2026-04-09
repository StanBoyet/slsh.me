import { Controller } from "@hotwired/stimulus"

// Manages light/dark theme with system-preference default.
// Cycles: system → light → dark → system
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyTheme()
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.onSystemChange = () => { if (this.mode === "system") this.applyTheme() }
    this.mediaQuery.addEventListener("change", this.onSystemChange)
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.onSystemChange)
  }

  get mode() {
    return localStorage.getItem("theme") || "system"
  }

  toggle() {
    const order = ["system", "light", "dark"]
    const next = order[(order.indexOf(this.mode) + 1) % order.length]
    if (next === "system") {
      localStorage.removeItem("theme")
    } else {
      localStorage.setItem("theme", next)
    }
    this.applyTheme()
  }

  applyTheme() {
    const isDark = this.mode === "dark" ||
      (this.mode === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches)

    document.documentElement.classList.toggle("dark", isDark)
    this.updateIcon()
  }

  updateIcon() {
    if (!this.hasIconTarget) return
    const icons = { system: "computer", light: "sun", dark: "moon" }
    this.iconTarget.setAttribute("data-icon", icons[this.mode])
  }
}
