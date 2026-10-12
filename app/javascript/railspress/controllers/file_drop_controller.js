import { Controller } from "@hotwired/stimulus"

/**
 * File Drop Controller
 *
 * Drag-and-drop file picker for forms that submit the files themselves
 * (post imports, CMS transfer). Shows the chosen files and enables the
 * submit button once there is at least one.
 *
 * Usage:
 *   <form data-controller="railspress--file-drop">
 *     <label class="rp-dropzone"
 *            data-action="dragenter->railspress--file-drop#activate
 *                         dragover->railspress--file-drop#activate
 *                         dragleave->railspress--file-drop#deactivate
 *                         drop->railspress--file-drop#drop">
 *       <input type="file" data-railspress--file-drop-target="input"
 *              data-action="change->railspress--file-drop#update">
 *     </label>
 *
 *     <!-- one .rp-file-item per file -->
 *     <div data-railspress--file-drop-target="list" hidden></div>
 *     <!-- or "name (size)" of the first file -->
 *     <div data-railspress--file-drop-target="summary" hidden></div>
 *
 *     <input type="submit" data-railspress--file-drop-target="submit" disabled>
 *   </form>
 */
export default class extends Controller {
  static targets = ["input", "list", "summary", "submit"]

  activate(event) {
    event.preventDefault()
    event.currentTarget.classList.add("rp-dropzone--active")
  }

  deactivate(event) {
    event.preventDefault()
    event.currentTarget.classList.remove("rp-dropzone--active")
  }

  drop(event) {
    this.deactivate(event)
    this.inputTarget.files = event.dataTransfer.files
    this.update()
  }

  update() {
    const files = Array.from(this.inputTarget.files)
    const chosen = files.length > 0

    if (this.hasListTarget) {
      this.listTarget.replaceChildren(...files.map(file => this.fileItem(file)))
      this.listTarget.hidden = !chosen
    }

    if (this.hasSummaryTarget) {
      this.summaryTarget.textContent = chosen ? `${files[0].name} (${this.formatSize(files[0].size)})` : ""
      this.summaryTarget.hidden = !chosen
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !chosen
    }
  }

  fileItem(file) {
    const item = document.createElement("div")
    item.className = "rp-file-item"
    item.append(this.span("rp-file-name", file.name), this.span("rp-file-size", this.formatSize(file.size)))
    return item
  }

  span(className, text) {
    const span = document.createElement("span")
    span.className = className
    span.textContent = text
    return span
  }

  formatSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }
}
