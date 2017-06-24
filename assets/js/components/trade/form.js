import flatpickr from 'flatpickr'

if (document.getElementById('trade_form')) {
  const tradeForm = {
    usdBtcPrice: document.getElementById('trade_cost_group').dataset.usdBtcPrice,
    amount: document.getElementById('trade_amount'),
    cost: document.getElementById('trade_cost'),
    totalCost: document.getElementById('trade_total_cost'),
    totalCostBTC: document.getElementById('trade_total_cost_btc')
  }

  console.log(tradeForm.usdBtcPrice)
  tradeForm.cost.addEventListener('keyup', function (e) {
    const cost = e.currentTarget.value

    tradeForm.totalCost.value = cost * tradeForm.amount.value
    tradeForm.totalCostBTC.value = tradeForm.totalCost.value / tradeForm.usdBtcPrice
  })

  tradeForm.totalCost.addEventListener('keyup', function (e) {
    const totalCost = e.currentTarget.value

    tradeForm.cost.value = totalCost / tradeForm.amount.value
    tradeForm.totalCostBTC.value = totalCost / tradeForm.usdBtcPrice
  })

  tradeForm.totalCostBTC.addEventListener('keyup', function (e) {
    const totalCostBTC = e.currentTarget.value

    tradeForm.totalCost.value = totalCostBTC * tradeForm.usdBtcPrice
    tradeForm.cost.value = tradeForm.totalCost.value / tradeForm.amount.value
  })

  flatpickr('#trade_date')
}
