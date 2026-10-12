import { Controller } from "@hotwired/stimulus"

/**
 * Auto Submit Controller
 *
 * Submits the form as soon as one of its fields changes.
 *
 * Usage:
 *   <form data-controller="railspress--auto-submit">
 *     <select data-action="railspress--auto-submit#submit">...</select>
 *   </form>
 */
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
