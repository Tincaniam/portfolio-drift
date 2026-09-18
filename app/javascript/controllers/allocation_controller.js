import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "rows", "template", "total", "addButton"]

  connect() {
    this.nextIndex = Date.now()
    this.rowTargets.filter(row => row.hidden).forEach(row => this.disableRow(row))
    this.update()
  }

  add() {
    if (this.visibleRows.length >= 12) return
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", this.nextIndex++)
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    this.visibleRows.at(-1).querySelector('input[type="text"]').focus()
    this.update()
  }

  remove(event) {
    const row = event.target.closest(".holding-row")
    row.querySelector('[data-allocation-target="destroy"]').value = "1"
    row.hidden = true
    this.disableRow(row)
    this.update()
  }

  disableRow(row) {
    row.querySelectorAll("input:not([type='hidden'])").forEach(input => { input.disabled = true })
  }

  update() {
    const total = this.visibleRows.reduce((sum, row) => {
      const value = Number(row.querySelector('[data-allocation-target="weight"]').value)
      return sum + Math.round((Number.isFinite(value) ? value : 0) * 100)
    }, 0)
    const remaining = (10000 - total) / 100
    const message = total === 10000 ? "Ready to save" : `${Math.abs(remaining).toFixed(2)}% ${remaining > 0 ? "remaining" : "over target"}`
    this.totalTarget.textContent = `${(total / 100).toFixed(2)}% allocated · ${message}`
    this.totalTarget.classList.toggle("complete", total === 10000)
    this.addButtonTarget.disabled = this.visibleRows.length >= 12
  }

  get visibleRows() {
    return this.rowTargets.filter(row => !row.hidden)
  }
}
