import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["destinationUrl", "rowsBody", "rowTemplate", "row", "saveButton", "status", "rowCount"]
  static values  = { updateUrl: String, csrf: String, registry: Object, campaignSlug: String }

  connect() {
    this.refreshRowCount()
  }

  // ── Row management ───────────────────────────────────────────────
  addRow(event) {
    event?.preventDefault()
    const template = this.rowTemplateTarget.content.firstElementChild.cloneNode(true)
    template.dataset.clientId = `new-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`
    this.rowsBodyTarget.appendChild(template)
    this.refreshRowCount()
    template.querySelector('[data-field="utm_source"]')?.focus()
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-channel-matrix-target='row']")
    if (!row) return

    const id = row.dataset.linkId
    if (id) {
      // Existing link — mark for destroy via hidden flag, hide row
      row.dataset.destroy = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
    this.refreshRowCount()
  }

  // ── Channel preset (when user picks a known channel from <select>) ──
  presetChannel(event) {
    const value = event.currentTarget.value
    if (!value) return
    const preset = this.registryValue[value]
    const row = event.currentTarget.closest("[data-channel-matrix-target='row']")
    if (!row || !preset) return

    const sourceField = row.querySelector('[data-field="utm_source"]')
    const mediumField = row.querySelector('[data-field="utm_medium"]')
    const slugField   = row.querySelector('[data-field="slug"]')

    if (sourceField && !sourceField.value) sourceField.value = value
    if (mediumField && !mediumField.value && preset.medium) mediumField.value = preset.medium
    if (slugField && !slugField.value) slugField.value = `${this.campaignSlugValue}-${value}`
  }

  // ── Save ─────────────────────────────────────────────────────────
  async save(event) {
    event?.preventDefault()
    if (this.hasStatusTarget) this.statusTarget.textContent = "Saving…"
    this.saveButtonTarget.disabled = true

    const payload = {
      destination_url: this.destinationUrlTarget.value.trim(),
      channels: this.rowTargets.map(row => this.serializeRow(row))
    }

    try {
      const response = await fetch(this.updateUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept":       "application/json",
          "X-CSRF-Token": this.csrfValue
        },
        body: JSON.stringify(payload)
      })

      const data = await response.json()

      if (!response.ok) {
        const msg = data.error || (data.errors && JSON.stringify(data.errors)) || "Save failed"
        if (this.hasStatusTarget) this.statusTarget.textContent = msg
        return
      }

      // Reload to refetch the matrix from server (simplest; preserves stat strip & live feed in sync)
      window.location.reload()
    } catch (err) {
      if (this.hasStatusTarget) this.statusTarget.textContent = "Network error"
      console.error(err)
    } finally {
      this.saveButtonTarget.disabled = false
    }
  }

  serializeRow(row) {
    return {
      id:          row.dataset.linkId || null,
      client_id:   row.dataset.clientId || null,
      _destroy:    row.dataset.destroy === "1" ? "1" : null,
      utm_source:  row.querySelector('[data-field="utm_source"]')?.value || "",
      utm_medium:  row.querySelector('[data-field="utm_medium"]')?.value || "",
      slug:        row.querySelector('[data-field="slug"]')?.value || "",
      custom_domain_id: row.querySelector('[data-field="custom_domain_id"]')?.value || ""
    }
  }

  refreshRowCount() {
    if (!this.hasRowCountTarget) return
    const visible = this.rowTargets.filter(r => r.dataset.destroy !== "1").length
    this.rowCountTarget.textContent = `${visible} link${visible === 1 ? "" : "s"}`
  }
}
