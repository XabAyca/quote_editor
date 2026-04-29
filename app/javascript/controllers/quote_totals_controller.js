import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "vatRate", "totalExclVAT", "totalInclVAT"]
  static values = {
    locale: { type: String, default: "fr" }
  }

  connect() {
    this.update
  }

  formatCurrency(value) {
    return new Intl.NumberFormat(this.localeValue, {
      style: "currency",
      currency: "EUR"
    }).format(value)
  }

  update() {
    const quantity = parseFloat(this.quantityTarget.value) || 0
    const price  = parseFloat(this.unitPriceTarget.value) || 0
    const vat = parseFloat(this.vatRateTarget.value) || 0

    const totalExclVAT =  quantity * price
    const totalInclVAT = totalExclVAT * (1 + vat / 100)

    this.totalExclVATTarget.textContent = this.formatCurrency(totalExclVAT)
    this.totalInclVATTarget.textContent = this.formatCurrency(totalInclVAT)
  }
}
