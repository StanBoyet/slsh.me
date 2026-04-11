import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "placeholder", "remove", "removeBtn"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewTarget.src = e.target.result
      this.previewTarget.classList.remove("hidden")
      if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
      if (this.hasRemoveTarget) this.removeTarget.value = ""
      if (this.hasRemoveBtnTarget) this.removeBtnTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }

  removeImage() {
    this.previewTarget.classList.add("hidden")
    this.previewTarget.src = ""
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("hidden")
    if (this.hasRemoveTarget) this.removeTarget.value = "1"
    if (this.hasRemoveBtnTarget) this.removeBtnTarget.classList.add("hidden")
    this.inputTarget.value = ""
  }
}
