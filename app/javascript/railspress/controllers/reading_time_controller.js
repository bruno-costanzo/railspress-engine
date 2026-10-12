import { Controller } from "@hotwired/stimulus"

/**
 * Reading Time Controller
 *
 * Fills the reading time field with the value calculated on the server.
 *
 * Usage:
 *   <div data-controller="railspress--reading-time">
 *     <input type="number" data-railspress--reading-time-target="input">
 *     <button type="button"
 *             data-action="railspress--reading-time#calculate"
 *             data-railspress--reading-time-minutes-param="5">Calculate</button>
 *   </div>
 */
export default class extends Controller {
  static targets = ["input"]

  calculate({ params: { minutes } }) {
    this.inputTarget.value = minutes
  }
}
