import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSensors 5.0
import harbour.gpsinfo 1.0
import "../QChart"
import "../components"

Page {
    id: satelliteBarchartPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    property GPSDataSource gpsDataSource

    PageHeader {
        id: header
        title: qsTr("Satellite signal strengths")
    }

    Chart {
        id: rssiBarChart;
        width: satelliteBarchartPage.width;
        height: satelliteBarchartPage.height - header.height;
        y: header.height
        chartAnimated: true;
        chartAnimationEasing: Easing.Linear;
        chartAnimationDuration: 2000;
        chartType: Charts.ChartType.BAR
        property variant satellites : gpsDataSource.satellites;
        property bool componentLoaded: false
        Component.onCompleted: {
            chartData = {
                labels: [],
                datasets: [{
                        data: [],
                        fillColor: []
                    }]
            }
            chartOptions = {
                scaleStartValue: 0,
                scaleStepWidth: 5,
                scaleSteps: 10,
                scaleOverride: true,
                scaleFontColor: Theme.secondaryHighlightColor,
                scaleFontSize: Theme.fontSizeSmall,
                scaleFontFamily: Theme.fontFamily
            }
            rssiBarChart.componentLoaded = true
        }

        function getRSSI_Color(rssi)
        {
            return "hsl(" + (rssi < 40 ? rssi : 40) * 3 + ",100%,35%)";
        }

        onSatellitesChanged: {
            if (!rssiBarChart.componentLoaded || pageStack.currentPage !== satelliteBarchartPage)
                return;

            var results = [];
            gpsDataSource.satellites.forEach(function(sat) {

                // Add visible satellites
                if(sat.signalStrength > 0)
                    results.push(sat)
            });

            if(results.length > 0) {
                // Sort satellites by signal strength
                results.sort(function(a,b) {return b.signalStrength - a.signalStrength})

                // Clear the chart data
                rssiBarChart.chartData.labels = []
                rssiBarChart.chartData.datasets[0].data = []
                rssiBarChart.chartData.datasets[0].fillColor = []

                // Insert the data
                results.forEach(function(barSat) {
                    rssiBarChart.chartData.labels.push(barSat.identifier);
                    rssiBarChart.chartData.datasets[0].data.push(barSat.signalStrength);
                    rssiBarChart.chartData.datasets[0].fillColor.push(getRSSI_Color(barSat.signalStrength));
                });


            }
            rssiBarChart.requestPaint();
        }
    }
}
