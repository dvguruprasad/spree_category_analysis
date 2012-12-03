$(function () {
    var chart;
    $(document).ready(function() {
        chart = new Highcharts.Chart({
            chart: {
                renderTo: 'container',
              zoomType: 'xy'
            },
              title: {
                  text: 'Promotion Simulator'
              },
              xAxis: [{
                  categories: ['Current Week', 'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']
              }],
              yAxis: [{ // Primary yAxis
                  labels: {
                      formatter: function() {
                          return this.value;
                      },
              style: {
                  color: '#89A54E'
              }
                  },
              title: {
                  text: 'Temperature',
                  style: {
                      color: '#89A54E'
                  }
              }
              }, { // Secondary yAxis
                  title: {
                      text: 'Rainfall',
                      style: {
                          color: '#4572A7'
                      }
                  },
                  labels: {
                      formatter: function() {
                          return this.value +' mm';
                      },
                      style: {
                          color: '#4572A7'
                      }
                  },
                  opposite: true
              }],
                  tooltip: {
                      formatter: function() {
                          return ''+
                              this.x +': '+ this.y +
                              (this.series.name == 'Rainfall' ? ' mm' : '°C');
                      }
                  },
                  legend: {
                      layout: 'horizontal',
                      align: 'left',
                      x: 120,
                      verticalAlign: 'top',
                      y: 100,
                      floating: true,
                      backgroundColor: '#FFFFFF'
                  },
                  series: [{
                      name: 'Rainfall',
                      color: '#4572A7',
                      type: 'column',
                      yAxis: 1,
                      data: [49.9, 71.5, 106.4, 129.2, 144.0, 176.0]

                  }, {
                      name: 'Temperature',
                      color: '#89A54E',
                      type: 'spline',
                      data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5]
                  },{
                      name: 'foobar',
                      color: '#83c8f9',
                      type: 'spline',
                      data: [8.0, 10.9, 9.5, 24.5, 28.2, 41.5]
                  }]
        });
    });

});
