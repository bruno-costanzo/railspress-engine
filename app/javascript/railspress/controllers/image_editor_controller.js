import { Controller } from "@hotwired/stimulus"

/**
 * Image Editor Controller
 *
 * Change and Remove actions of the image section editor form. Both submit
 * the form natively (not through Turbo), so the page reloads with the result.
 *
 * Usage:
 *   <form data-controller="railspress--image-editor">
 *     <input type="file" name="image" data-action="change->railspress--image-editor#replace">
 *
 *     <button type="button"
 *             data-action="railspress--image-editor#remove"
 *             data-railspress--image-editor-confirmation-param="Remove this image?">Remove</button>
 *     <input type="hidden" name="remove_image" value="0" data-railspress--image-editor-target="removeImage">
 *   </form>
 */
export default class extends Controller {
  static targets = ["removeImage"]

  replace() {
    this.element.submit()
  }

  remove({ params: { confirmation } }) {
    if (!confirm(confirmation)) return

    this.removeImageTarget.value = "1"
    this.element.submit()
  }
}
