import QtQuick 2.0
import QtPositioning 5.2
import QtSensors 5.0
import Harbour.GPSInfo 1.0
import Sailfish.Silica 1.0
import "../components"


Item {
    id: providers
    property alias position: positionSource
    property alias compass: compass
    property alias gps: gpsDataSource
    property alias timing: timing
    function toggleActive() {
        if (positionSource.active) {
            console.log("deactivating GPS");
            positionSource.stop();
            gpsDataSource.active = false;
        } else {
            console.log("activating GPS");
            positionSource.start();
            gpsDataSource.active = true;
        }

    }

    PositionSource {
        id: positionSource
        updateInterval: settings.updateInterval
        active: true
        //timestamp seems to be the only way to know gps has a new fix
        position.onTimestampChanged: {
            if (position.coordinate.isValid) {
                timing.setTimeToFirstFix()
            }
        }
    }

    Compass {
        id: compass
        active: true
    }

    GPSDataSource {
        id: gpsDataSource
        updateInterval: settings.updateInterval
        active: true
        Component.onCompleted:{ //as onActiveChanged is not fired at startup
            onActiveChanged(null)
        }

        onActiveChanged: {
            if (active) {
                timing.start()
            }
        }
        //onNumberOfUsedSatellitesChanged: console.log("ousc")

    }
    Item {
        id: timing
        property date gpsActivationTime: new Date()
        property date firstLocationFixTime: new Date()
        property date lastPositionTimestamp: positionSource.position.timestamp //new Date()

        property bool pendingFix: true
        property int secondsToLocationFix: 0
        property int secondsSinceLastLocationFix: 0

        Timer { //keep secsXX running when no position updates
            id: timer
            interval: 1000;
            running: true
            repeat: true;
            onTriggered: {
                //console.log("tick")
                timing.secondsSinceLastLocationFix = Math.round((new Date() - timing.lastPositionTimestamp)/1000)
                if (timing.pendingFix) {
                    timing.secondsToLocationFix = Math.round(-(new Date() - timing.gpsActivationTime)/1000);
                }
            }
        }
        function start() {
            firstLocationFixTime = gpsActivationTime = new Date()
            lastPositionTimestamp = positionSource.position.timestamp
            pendingFix =true
            secondsToLocationFix = 0
            console.log("c "+pendingFix)
        }

        function setTimeToFirstFix() {
            secondsSinceLastLocationFix = Math.round((positionSource.position.timestamp - lastPositionTimestamp)/1000)
            lastPositionTimestamp = positionSource.position.timestamp
            if (pendingFix) {
                secondsToFirstFix = Math.round((new Date() - gpsActivationTime)/1000)
                pendingFix=false
                Notices.show(qsTr("Time to First Fix") + ": " + secondsToFirstFix + "s", Notice.Long)
            }

        }
        function formatElapsedTime(t) { //print fn for elapsed times
            if (t<=90) return Math.round(t)+ "sec"
            t=t/60;
            if (t<=90) return locationFormatter.roundToDecimal(T,1)+ "min"
            t=t/60;
            return locationFormatter.roundToDecimal(t,1)+ "hr"
        }
        Component.onCompleted: {

        }
    }
}
