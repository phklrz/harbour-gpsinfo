import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

CoverBackground {

    Image {
        id: bgimg
        source: "../../images/coverbg.png"
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
    }
    Column {
        id: column
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingMedium
        width: parent.width
        spacing: Theme.paddingLarge
        InfoField {
            label: qsTr("GPS")
            visible: settings.showGpsStateCover
            fontpixelSize: Theme.fontSizeMedium
            value: providers.position.active ? qsTr("active") : qsTr("inactive")
        }
        InfoField {
            label: providers.position.position.latitudeValid ? "" : qsTr("Latitude")
            visible: settings.showLatitudeCover
            fontpixelSize: Theme.fontSizeMedium
            value: {
                if (providers.position.position.latitudeValid) {
                    if (settings.coordinateFormat === "DEG") {
                        return locationFormatter.decimalLatToDMS(providers.position.position.coordinate.latitude, 0)
                    } else {
                        return providers.position.position.coordinate.latitude
                    }
                }
                return "-"
            }
        }
        InfoField {
            label: providers.position.position.longitudeValid ? "" : qsTr("Longitude")
            visible: settings.showLongitudeCover
            fontpixelSize: Theme.fontSizeMedium
            value: {
                if (providers.position.position.longitudeValid) {
                    if (settings.coordinateFormat === "DEG") {
                        return locationFormatter.decimalLongToDMS(providers.position.position.coordinate.longitude, 0)
                    } else {
                        return providers.position.position.coordinate.longitude
                    }
                }
                return "-"
            }
        }
        InfoField {
            label: qsTr("Altitude")
            visible: settings.showAltitudeCover
            fontpixelSize: Theme.fontSizeMedium
            value: {
                if (providers.position.position.altitudeValid) {
                    if (settings.units == "MET") {
                        return locationFormatter.roundToDecimal(providers.position.position.coordinate.altitude, 2) + " m"
                    } else {
                        return locationFormatter.roundToDecimal(providers.position.position.coordinate.altitude * 3.2808399, 2) + " ft"
                    }
                }
                return "-"
            }
        }
        InfoField {
            label: providers.position.position.speedValid ? "" : qsTr("Speed")
            visible: settings.showSpeedCover
            fontpixelSize: Theme.fontSizeMedium
            value: {
                if (providers.position.position.speedValid) {
                    if (settings.units == "MET") {
                        if (settings.speedUnit == "SEC") {
                            return locationFormatter.roundToDecimal(providers.position.position.speed, 2) + " " + qsTr("m/s")
                        } else {
                            return locationFormatter.roundToDecimal(providers.position.position.speed * 60 * 60 / 1000, 2) + " " + qsTr("km/h")
                        }
                    } else {
                        if (settings.speedUnit == "SEC") {
                            return locationFormatter.roundToDecimal(providers.position.position.speed * 3.2808399, 2) + " " + qsTr("ft/s")
                        } else {
                            return locationFormatter.roundToDecimal(providers.position.position.speed * 2.23693629, 2) + " " + qsTr("mph")
                        }
                    }
                }
                return "-"
            }
        }
        InfoField {
            label: qsTr("Mov.")
            visible: settings.showMovementDirectionCover
            fontpixelSize: Theme.fontSizeMedium
            value: isNaN(providers.gps.movementDirection) ? "-" : locationFormatter.formatDirection(providers.gps.movementDirection)
        }
        InfoField {
            label: ""
            visible: settings.showLastUpdateCover
            fontpixelSize: Theme.fontSizeMedium
            value: providers.position.position.valid ? Qt.formatTime(providers.position.position.timestamp, "hh:mm:ss") : "-"
        }
        InfoField {
            label: qsTr("Vert. acc.")
            visible: settings.showVerticalAccuracyCover
            fontpixelSize: Theme.fontSizeMedium
            value: {
                if (providers.position.position.verticalAccuracyValid) {
                    if (settings.units == "MET") {
                        return locationFormatter.roundToDecimal(providers.position.position.verticalAccuracy, 2) + " m"
                    } else {
                        return locationFormatter.roundToDecimal(providers.position.position.verticalAccuracy * 3.2808399, 2) + " ft"
                    }
                }
                return "-"
            }
        }
        InfoField {
            label: qsTr("Hor. acc.")
            visible: settings.showHorizontalAccuracyCover
            fontpixelSize: Theme.fontSizeMedium
            value: {
                if (providers.position.position.horizontalAccuracyValid) {
                    if (settings.units == "MET") {
                        return locationFormatter.roundToDecimal(providers.position.position.horizontalAccuracy, 2) + " m"
                    } else {
                        return locationFormatter.roundToDecimal(providers.position.position.horizontalAccuracy * 3.2808399, 2) + " ft"
                    }
                }
                return "-"
            }
        }
        InfoField {
            label: qsTr("Satel.")
            visible: settings.showSatelliteInfoCover
            fontpixelSize: Theme.fontSizeMedium
            value: providers.gps.numberOfUsedSatellites + "/" + providers.gps.numberOfVisibleSatellites
        }
        InfoField {
            label: qsTr("Com.")
            visible: settings.showCompassDirectionCover
            fontpixelSize: Theme.fontSizeMedium
            value: locationFormatter.formatDirection(providers.compass.reading === null ? 0 : providers.compass.reading.azimuth)
        }
        InfoField {
            label: qsTr("Cal.")
            visible: settings.showCompassCalibrationCover
            fontpixelSize: Theme.fontSizeMedium
            value: providers.compass.reading === null ? "-" : Math.round(providers.compass.reading.calibrationLevel * 100) + "%"
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: providers.position.active ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
            onTriggered: { providers.toggleActive()
            }
        }
    }
}


