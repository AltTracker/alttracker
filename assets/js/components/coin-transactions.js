
const summaries = document.querySelectorAll('.coin-trades-summary')

summaries.forEach((summary) => {
  summary.addEventListener('click', function () {
    const currencyId = this.getAttribute('data-currency-id')
    const coinTrades = document.querySelectorAll('.coin-trade-' + currencyId)

    coinTrades.forEach((coinTrade) => {
      coinTrade.classList.toggle("visible")
    })
  })
})


