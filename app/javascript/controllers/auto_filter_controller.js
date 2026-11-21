import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 250 } }

  connect() {
    this.timeout = null
  }

  disconnect() {
    this.clearTimeout()
  }

  schedule() {
    this.clearTimeout()
    this.timeout = setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    this.clearTimeout()
    this.element.requestSubmit()
  }

  clearTimeout() {
    if (this.timeout) {
      window.clearTimeout(this.timeout)
      this.timeout = null
    }
  }
}
