import QtQuick 2.6//0
import Sailfish.Silica 1.0
import QtPositioning 5.4//2
import QtSensors 5.0
import harbour.gpsinfo 1.0
import "../components"

import "../LocationFormatter.js" as LocationFormater

Page {
    id: page
    property PositionSource positionSource
    property Compass compass
    property GPSDataSource gpsDataSource
    property bool subPagesPushed: false
    property date activateGPSTimestamp: new Date()

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    onStatusChanged: {
        if (status == PageStatus.Active && !subPagesPushed) {
            subPagesPushed = true
            pageStack.pushAttached(Qt.resolvedUrl("SatelliteInfoPage.qml"),
                           { gpsDataSource: page.gpsDataSource, compass: page.compass})
        }
    }
    Item {
            id: gpsTimes
            property date activateGPSTimestamp: new Date()
            property date firstFixTimestamp: new Date()
            property bool pendingFix : true;
            property int tTFF: { console.log("PF"+pendingFix);
                if ( pendingFix && positionSource.position.coordinate.isValid && (positionSource.position.timestamp > activateGPSTimestamp)) {
                    pendingFix=false
                    firstFixTimestamp=positionSource.position.timestamp
                    Notices.show("GPS Time to First Fix ", Notice.Long)
                }
                if ( pendingFix) {
                    console.log("PF"+pendingFix);
                    return Math.round((new Date() - activateGPSTimestamp)/1000)
                } else {
                    console.log("PF"+pendingFix);
                 return Math.round((firstFixTimestamp - activateGPSTimestamp)/1000)
                }
            }
            function tTFFStr() {

            }

            function clear() {
              firstFixTimestamp = activateGPSTimestamp = new Date()
              pendingFix =true
            }
            function roundElapsedTime(T) {
                if (T<=90) return Math.round(T)+ "sec"
                T=T/60;
                if (T<=90) return LocationFormater.roundToDecimal(T,1)+ "min"
                T=T/60;
                return LocationFormater.roundToDecimal(T,1)+ "hr"
            }
    }

    states: [
        State {
            name: 'landscape';
            when: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted;
            PropertyChanges {
                target: column;
                anchors.leftMargin: page.width * 0.125;
                anchors.rightMargin: page.width * 0.125;
            }
        }
    ]

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: positionSource.active ? qsTr("Deactivate GPS") : qsTr("Activate GPS")
                onClicked: {
                    if (positionSource.active) {
                        console.log("deactivating GPS");
                        positionSource.stop();
                        gpsDataSource.active = false;
                        console.log("active: " + positionSource.active);
                    } else {
                        console.log("activating GPS");
                        positionSource.start();
                        gpsDataSource.active = true;
                        gpsTimes.clear()
                        activateGPSTimestamp = new Date()
                        console.log("active: " + positionSource.active);
                    }
                }
            }
            MenuItem {
                enabled: gpsDataSource.active
                text: qsTr("Copy location")
                onClicked: {
                    if (settings.coordinateFormat === "DEG") {
                        Clipboard.text = LocationFormater.decimalLatToDMS(positionSource.position.coordinate.latitude, 2)
                                + ", "
                                + LocationFormater.decimalLongToDMS(positionSource.position.coordinate.longitude, 2);
                    } else {
                        Clipboard.text = positionSource.position.coordinate.latitude
                                + ", "
                                + positionSource.position.coordinate.longitude
                    }
                }
            }
            MenuItem {
                enabled: gpsDataSource.active
                text: qsTr("Share Location")
                onClicked: pageStack.push(Qt.resolvedUrl("SharePage.qml"))
            }
        }

        contentHeight: pageHeader.height + column.height;

        PageHeader {
            id: pageHeader
            title: qsTr("GPS Info")
        }

        Column {
            id: column
            spacing: Theme.paddingLarge
            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
                leftMargin: 0
                rightMargin: Theme.paddingSmall
            }

            InfoField {
                label: qsTr("GPS")
                visible: settings.showGpsStateApp
                value: positionSource.active ? qsTr("active") : qsTr("inactive")
            }
            InfoField {
                label: qsTr("Latitude")
                visible: settings.showLatitudeApp
                value: {
                    if (positionSource.position.latitudeValid) {
                        if (settings.coordinateFormat === "DEG") {
                            return LocationFormater.decimalLatToDMS(positionSource.position.coordinate.latitude, 2)
                        } else {
                            return positionSource.position.coordinate.latitude
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Longitude")
                visible: settings.showLongitudeApp
                value: {
                    if (positionSource.position.longitudeValid) {
                        if (settings.coordinateFormat === "DEG") {
                            return LocationFormater.decimalLongToDMS(positionSource.position.coordinate.longitude, 2)
                        } else {
                            return positionSource.position.coordinate.longitude
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Altitude")
                visible: settings.showAltitudeApp
                value: {
                    if (positionSource.position.altitudeValid) {
                        if (settings.units == "MET") {
                            return LocationFormater.roundToDecimal(positionSource.position.coordinate.altitude, 2) + " m"
                        } else {
                            return LocationFormater.roundToDecimal(positionSource.position.coordinate.altitude * 3.2808399, 2) + " ft"
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Speed")
                visible: settings.showSpeedApp
                value: {
                    if (positionSource.position.speedValid) {
                        if (settings.units == "MET") {
                            if (settings.speedUnit == "SEC") {
                                return LocationFormater.roundToDecimal(positionSource.position.speed, 2) + " " + qsTr("m/s")
                            } else {
                                return LocationFormater.roundToDecimal(positionSource.position.speed * 60 * 60 / 1000, 2) + " " + qsTr("km/h")
                            }
                        } else {
                            if (settings.speedUnit == "SEC") {
                                return LocationFormater.roundToDecimal(positionSource.position.speed * 3.2808399, 2) + " " + qsTr("ft/s")
                            } else {
                                return LocationFormater.roundToDecimal(positionSource.position.speed * 2.23693629, 2) + " " + qsTr("mph")
                            }
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Movement direction")
                visible: settings.showMovementDirectionApp
                value: isNaN(gpsDataSource.movementDirection) ? "-" : LocationFormater.formatDirection(gpsDataSource.movementDirection)
            }
            InfoField {
                label: qsTr("Last update")
                visible: settings.showLastUpdateApp
                value: { //
                    var secsSincePosition = (new Date() - positionSource.position.timestamp)/1000
                    return ((secsSincePosition > (1 +settings.updateInterval) ) ? "-"+roundElapsedTime(secsSincePosition)+"  " : " ")
                            + (positionSource.position.coordinate.isValid ? Qt.formatTime(positionSource.position.timestamp, "hh:mm:ss") : "-")
                }
            }
            InfoField {
                label: qsTr("Time to First Fix")
                visible: settings.showLastUpdateApp
                value : gpsTimes.tTFF//roundElapsedTime(gpsTimes.tTFF) // roundElapsedTime((positionSource.position.timestamp - activateGPSTimestamp)/1000) //Qt.formatTime(Date(new Date() - positionSource.position.timestamp),"h:mm:ss.zzz")
                //value: positionSource.position.coordinate.isValid ? Qt.formatTime(new Date - positionSource.position.timestamp, "hh:mm:ss") : "-"
            }

            InfoField {
                label: qsTr("Vertical accuracy")
                visible: settings.showVerticalAccuracyApp
                value: {
                    if (positionSource.position.verticalAccuracyValid) {
                        if (settings.units == "MET") {
                            return LocationFormater.roundToDecimal(positionSource.position.verticalAccuracy, 2) + " m"
                        } else {
                            return LocationFormater.roundToDecimal(positionSource.position.verticalAccuracy * 3.2808399, 2) + " ft"
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Horizontal accuracy")
                visible: settings.showHorizontalAccuracyApp
                value: {
                    if (positionSource.position.horizontalAccuracyValid) {
                        if (settings.units == "MET") {
                            return LocationFormater.roundToDecimal(positionSource.position.horizontalAccuracy, 2) + " m"
                        } else {
                            return LocationFormater.roundToDecimal(positionSource.position.horizontalAccuracy * 3.2808399, 2) + " ft"
                        }
                    }
                    return "-"
                }
            }
            InfoField {
                label: qsTr("Satellites in use / view")
                visible: settings.showSatelliteInfoApp
                value: gpsDataSource.numberOfUsedSatellites + " / " + gpsDataSource.numberOfVisibleSatellites
            }
            SectionHeader {
                visible: settings.showCompassDirectionApp
                text: "Compass"
            }
            InfoField {
                label: qsTr("Direction")
                visible: settings.showCompassDirectionApp
                value: compass.reading === null ? "-" : LocationFormater.formatDirection(compass.reading.azimuth)
            }
            InfoField {
                label: qsTr("Calibration")
                visible: settings.showCompassCalibrationApp && settings.showCompassDirectionApp
                value: compass.reading === null ? "-" : Math.round(compass.reading.calibrationLevel * 100) + "%"
            }
            InfoField { //this won't work until QTPositioning V5.4 or maybe 5.2 or, who knows?
                label: qsTr("Magnetic Variation")
                visible: settings.showCompassDirectionApp
                value: {
                    if (positionSource.position.magneticVariationValid === true) {
                        var md = LocationFormater.roundToDecimal(positionSource.position.magneticVariation, 1)
                        return md
                    } else {
                        if (positionSource.position.magneticVariationValid === undefined)
                        return  "req QtPos 5.4"
                        else return " - "


                } }
            }
            InfoField {
                label: qsTr("Magnetic Declination")
                visible: settings.showCompassDirectionApp && (settings.magneticDeclination >0)
                value:  LocationFormater.roundToDecimal(settings.magneticDeclination,0)
            }

            // This element is "necessary", because Sony Xperia XA2 Ultra (at least)
            // messes up the column height calculation with only InfoFields...
            Rectangle {
                color: "transparent"
                width: parent.width
                height: 1.0
            }
        }
    }
}


