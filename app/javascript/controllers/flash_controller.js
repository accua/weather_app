import { Controller } from "@hotwired/stimulus"

console.log('Flash controller loaded')

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.remove()
    }, 5000)
  }
}