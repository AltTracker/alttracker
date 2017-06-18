import anime from 'animejs'
import Highcharts from 'highcharts/highstock'

const coins = document.querySelectorAll('.landing__coin-icon')
const chartElement = document.getElementById('landing-intro__sample-graph')

if (coins) {
  window.setTimeout(() => {
    anime({
      targets: coins,
      opacity: [
        { value: 0.1, duration: 1000 },
        { value: 0.05, duration: 1000 }
      ],
      rotateX: 180,
      rotateY: 180,
      scale: 2,
      duration: 1000,
      autoplay: true,
      loop: true,
      direction: 'alternate',
      delay: (_, index) => index * 100
    })
  }, 1000)
}

if (chartElement) {
  const chart = new Highcharts.Chart({
    chart: {
      renderTo: 'landing-intro__sample-graph',
      backgroundColor: 'transparent',
      height: 151,
      marginLeft: 3,
      marginRight: 3,
      marginBottom: 0,
      marginTop: 0,
      type: 'area'
    },
    title: {
      text: ''
    },
    xAxis: {
      lineWidth: 0,
      tickWidth: 0,
      labels: { 
        enabled: false 
      },
      categories: []
    },
    yAxis: {
      labels: { 
        enabled: false 
      },
      gridLineWidth: 0,
      title: {
        text: null,
      },
    },
    series: [{
      name: 'More Awesomness',
      color: '#fff',
      type: 'line',
      data: [2492.73, 2490.97, 2497.94, 2499.22, 2493.28, 2508.53, 2501.55, 2500.88, 2509.64, 2512.86, 2520.94, 2545.46, 2546.52, 2547.48, 2545.97, 2538.32, 2541.65, 2537.57, 2542.25, 2543.18, 2559.26, 2563.72, 2554.71, 2555.18, 2553.7, 2546.97, 2549.07, 2561.09, 2556.87, 2557.43, 2564.74, 2569.7, 2566.44, 2570.51, 2575, 2588.22, 2608.7, 2595.36, 2597.12, 2604.83, 2598.37, 2599.16, 2599.47, 2596.79, 2600.1, 2594.33, 2595.56, 2601.75, 2599.66, 2585.72, 2595.4, 2592.96, 2588.89, 2592.93, 2589.46, 2591.41, 2609.28, 2618.33, 2633.97, 2641.1, 2642.62]
    }],
    credits: { 
      enabled: false 
    },
    legend: { 
      enabled: false 
    },
    plotOptions: {
      column: {
        borderWidth: 0,
        color: '#3d9e68',
        shadow: false
      },
      line: {
        marker: { 
          enabled: false 
        },
        lineWidth: 3
      }
    },
    tooltip: { 
      enabled: false
    }
  })

  let last = 2642.62
  setInterval(function() {
    const rand = Math.random()
    let changePerc = 2 * rand * 0.005
    if (changePerc > 0.005) {
      changePerc -= 1.75 * 0.005
    }
    const changeAmount = last * changePerc
    last = last + changeAmount
    
    chart.series[0].addPoint(last, true, true);
  }, 1000)
}
