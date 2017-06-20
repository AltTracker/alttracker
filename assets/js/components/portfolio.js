import R from 'ramda'
import Highcharts from 'highcharts/highstock' 
import theme from '../modules/charts/theme' 

const chart = document.getElementById('portfolio-chart')
const chartData = JSON.parse(chart.dataset.currencies)

Highcharts.setOptions(theme)
const portchart = Highcharts.stockChart('portfolio-chart', {
  chart: {
    events: {
      load: getSeriesData
    }
  },

  legend: {
    enabled: true
  },

  rangeSelector: {
    selected: 1
  },

  tooltip: {
    pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>${point.y}</b><br/>'
  },

  series: []
})
 

async function getSeriesData () {
  await Promise.all(
    chartData.map(async ({ name, symbol }) => {
      try {
        const getTicks = R.pipe(
          JSON.parse,
          R.prop('ticks'),
          R.map(({ time, high }) => ([time * 1000, high]))
        )

        const resp = await fetch(`/api/coin_daily_history/${symbol}`)
        const curr = await resp.text()

        const displayName = `${name} (${symbol})`

        portchart.addAxis({
          id: displayName,
          title: {
            text: `${name}`
          },
          visible: false
        })
        portchart.addSeries({
          name: displayName ,
          data: getTicks(curr),
          yAxis: displayName
        })
      } catch (e) {
        console.error(e)
      }
    })
  )
}

const pie = document.getElementById('portfolio-pie')
const pieData = JSON.parse(pie.dataset.trades)

const pieSeriesData = (
  pieData.map(({ id, currency: { name, symbol }, current_value }) => ({
    id,
    name: `${name} (${symbol})`,
    y: parseFloat(current_value)
  }))
)

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
