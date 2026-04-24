import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "selectWrapper", "createBtn", "createForm",
                     "nameInput", "slugInput", "colorPicker", "error"]
  static values = { createUrl: String, csrf: String, slugs: Object }

  selectedColor = "orange"

  // Sync utm_campaign field when campaign changes
  syncUtm() {
    const campaignId = this.selectTarget.value
    const slug = this.slugsValue[campaignId] || ""
    const utmCampaignInput = document.querySelector('[data-utm-target="campaign"]')
    if (utmCampaignInput) {
      utmCampaignInput.value = slug
      utmCampaignInput.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }

  showCreate() {
    this.createFormTarget.classList.remove("hidden")
    this.createBtnTarget.classList.add("hidden")
    this.nameInputTarget.focus()
  }

  hideCreate() {
    this.createFormTarget.classList.add("hidden")
    this.createBtnTarget.classList.remove("hidden")
    this.nameInputTarget.value = ""
    this.slugInputTarget.value = ""
    this.errorTarget.classList.add("hidden")
  }

  generateSlug() {
    const name = this.nameInputTarget.value
    this.slugInputTarget.value = name
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")
  }

  static RING_CLASSES = {
    orange: "ring-orange-300", blue: "ring-blue-300", emerald: "ring-emerald-300",
    violet: "ring-violet-300", rose: "ring-rose-300"
  }

  pickColor(event) {
    event.preventDefault()
    this.selectedColor = event.currentTarget.dataset.color
    this.colorPickerTarget.querySelectorAll("button").forEach(btn => {
      btn.classList.remove("ring-2", "ring-offset-2")
      Object.values(this.constructor.RING_CLASSES).forEach(c => btn.classList.remove(c))
    })
    const btn = event.currentTarget
    const ringClass = this.constructor.RING_CLASSES[this.selectedColor]
    if (ringClass) btn.classList.add("ring-2", ringClass, "ring-offset-2")
  }

  async submitCreate(event) {
    event.preventDefault()
    const name = this.nameInputTarget.value.trim()
    const slug = this.slugInputTarget.value.trim()

    if (!name) {
      this.showError("Campaign name is required")
      return
    }

    try {
      const response = await fetch(this.createUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfValue
        },
        body: JSON.stringify({
          campaign: { name, slug: slug || undefined, color: this.selectedColor }
        })
      })

      const data = await response.json()

      if (response.ok) {
        // Add new option to select and select it
        const option = new Option(data.name, data.id, true, true)
        this.selectTarget.add(option)

        // Update slugs map
        const slugs = { ...this.slugsValue }
        slugs[data.id] = data.slug
        this.slugsValue = slugs

        this.hideCreate()
        this.syncUtm()
      } else {
        this.showError(data.errors?.join(", ") || "Failed to create campaign")
      }
    } catch {
      this.showError("Network error. Please try again.")
    }
  }

  showError(msg) {
    this.errorTarget.textContent = msg
    this.errorTarget.classList.remove("hidden")
  }
}
