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
                scaleSteps: 20,
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

            gpsDataSource.satellites.forEach(function(sat) {
                var found = false;
                var labelIndex = 0;
                var changed = false;
                rssiBarChart.chartData.labels.forEach(function(label) {
                    if (label === sat.identifier) {
                        found = true;
                        return true;
                    }
                    labelIndex++;
                });

                if (found) {
                    if (sat.signalStrength === 0) {
                        // remove column
                        rssiBarChart.chartData.datasets.splice(labelIndex, 1);
                        changed = true;
                    } else {
                        /// update column
                        if (rssiBarChart.chartData.datasets[0].data[labelIndex] !== sat.signalStrength) {
                            rssiBarChart.chartData.datasets[0].data[labelIndex] = sat.signalStrength;
                            rssiBarChart.chartData.datasets[0].fillColor[labelIndex] = getRSSI_Color(sat.signalStrength);
                            changed = true;
                        }
                    }
                } else {
                    if (sat.signalStrength !== 0) {
                        rssiBarChart.chartData.labels.push(sat.identifier);
                        rssiBarChart.chartData.datasets[0].data.push(sat.signalStrength);
                        rssiBarChart.chartData.datasets[0].fillColor.push(getRSSI_Color(sat.signalStrength));
                        changed = true;
                    }
                }

                if (changed)
                    rssiBarChart.requestPaint();
            });
        }
    }
}
