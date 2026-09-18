import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "threshold", "summary"]
  static values = { threshold: Number }

  connect() {
    this.update()
  }

  update() {
    this.thresholdValue = Number(this.thresholdTarget.value)
    let count = 0
    this.rowTargets.forEach(row => {
      const highlighted = Number(row.dataset.gap) >= this.thresholdValue
      row.classList.toggle("highlighted", highlighted)
      if (highlighted) count++
    })
    this.summaryTarget.textContent = `${count} ${count === 1 ? "holding is" : "holdings are"} at least ${this.thresholdValue} percentage points from target. The full rebalance preview stays the same.`
  }
}
