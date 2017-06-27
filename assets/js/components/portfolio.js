import R from 'ramda'
import Highcharts from 'highcharts/highstock' 
import theme from '../modules/charts/theme' 

const links = document.querySelectorAll('[data-bind-link]')

function onBindLinkClick (e) {
  e.preventDefault()
  window.location = e.currentTarget.dataset['bindLink']
}

links.forEach(l => l.addEventListener('click', onBindLinkClick))

const chart = document.getElementById('portfolio-chart')
if (chart) {
  const chartData = JSON.parse(chart.dataset.currencies)

  Highcharts.setOptions(theme)
  if (chartData.length > 0) {
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

    function getSeriesData () {
      const uniqChartData = R.uniqBy(R.prop('symbol'))(chartData)

      return Promise.all(
        uniqChartData.map(({ name, symbol }) => {
          const getTicks = R.pipe(
            JSON.parse,
            R.prop('ticks'),
            R.map(({ time, high }) => ([time * 1000, high]))
          )

          return fetch(`/api/coin_daily_history/${symbol}`)
            .then(resp => resp.text())
            .then(curr => {
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
            })
            .catch(e => {
              console.error(e)
            })
        })
      )
    }
  }
}

const pie = document.getElementById('portfolio-pie')
if (pie) {
  const hashMapToArray = data => R.map(R.prop(R.__, data), R.keys(data))
  const pieData = JSON.parse(pie.dataset.trades)

  const pieSeriesData = (
    hashMapToArray(
      pieData.reduce((acc, val) => {
        const nameWithSymbol = `${val.currency.name} (${val.currency.symbol})`
        const accumulatedY = acc[nameWithSymbol] ? acc[nameWithSymbol].y : 0

        // no transform spread :(
        return Object.assign({}, acc, {
          [nameWithSymbol]: {
            name: nameWithSymbol,
            y: accumulatedY + parseFloat(val.current_value)
          }
        })
      }, {})
    )
  )

  if (pieSeriesData.length > 0) {
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
  }
}
