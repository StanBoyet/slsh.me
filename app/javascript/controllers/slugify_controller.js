import { Controller } from "@hotwired/stimulus"

// Fills `target` with a slugified version of `source` on source blur,
// but only when target is currently empty. Lets users override by typing.
export default class extends Controller {
  static targets = ["source", "target"]

  fillIfEmpty() {
    if (this.targetTarget.value.trim() !== "") return

    this.targetTarget.value = this.sourceTarget.value
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")
  }
}
