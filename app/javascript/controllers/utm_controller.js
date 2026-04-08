import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "source", "medium", "campaign", "content", "preview", "previewText"]

  updatePreview() {
    const base = this.urlTarget.value.trim()
    if (!base) { this.previewTarget.style.display = "none"; return }

    const params = {}
    if (this.sourceTarget.value)   params.utm_source   = this.sourceTarget.value
    if (this.mediumTarget.value)   params.utm_medium   = this.mediumTarget.value
    if (this.campaignTarget.value) params.utm_campaign = this.campaignTarget.value
    if (this.contentTarget.value)  params.utm_content  = this.contentTarget.value

    if (Object.keys(params).length === 0) {
      this.previewTarget.style.display = "none"
      this.urlTarget.dataset.finalUrl = base
      return
    }

    try {
      const url = new URL(base)
      Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v))
      const finalUrl = url.toString()

      this.previewTextTarget.textContent = finalUrl
      this.previewTarget.style.display   = "block"

      // Write the UTM-appended URL back into the hidden field we'll submit
      this.urlTarget.value = finalUrl
    } catch {
      this.previewTarget.style.display = "none"
    }
  }
}
