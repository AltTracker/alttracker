import Highcharts from 'highcharts/highstock' 
import theme from '../modules/charts/theme' 
 
const chart = document.getElementById('portfolio-chart')
const chartData = JSON.parse(chart.dataset.currencies)

const seriesData = (
  chartData.map(({ id, name, symbol, ticks }) => ({
    id,
    name: `${name} (${symbol})`,
    data: ticks.map(({ cost_usd, last_updated }) => ([last_updated * 1000, parseFloat(cost_usd)]))
  }))
)

const pie = document.getElementById('portfolio-pie')
const pieData = JSON.parse(pie.dataset.trades)

const pieSeriesData = (
  pieData.map(({ id, currency: { name, symbol }, current_value }) => ({
    id,
    name: `${name} (${symbol})`,
    y: parseFloat(current_value)
  }))
)

Highcharts.setOptions(theme)
Highcharts.stockChart('portfolio-chart', {
  legend: {
    enabled: true
  },

  rangeSelector: {
    selected: 1
  },

  tooltip: {
    valueDecimals: 2,
    pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>${point.y}</b><br/>'
  },

  series: seriesData
})

Highcharts.chart('portfolio-pie', {
  title: false,
  chart: {
    plotBackgroundColor: null,
    plotBorderWidth: null,
    plotShadow: false,
    type: 'pie'
  },
  tooltip: {
    pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
  },
  plotOptions: {
    pie: {
      allowPointSelect: true,
      cursor: 'pointer',
      dataLabels: {
        enabled: false
      },
      showInLegend: true
    }
  },
  series: [{
    name: 'Portfolio',
    colorByPoint: true,
    data: pieSeriesData
  }]
})
