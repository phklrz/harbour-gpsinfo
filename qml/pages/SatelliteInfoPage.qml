import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "../components"

Page {
    id: satelliteInfoPage

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    property int declination: settings.magneticDeclination === undefined ? 0 : settings.magneticDeclination
    property variant satellites: status === PageStatus.Inactive ? [] : providers.gps.satellites;
    property variant sortedSatellites: status === PageStatus.Inactive ? [] : providers.gps.satellites.sort(function(a,b) {return (a.inUse ? 1:-1) - (b.inUse ? 1:-1)}) //so we can draw InUse sats on top...

    states: [
        State {
            name: 'landscape';
            when: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted;
            AnchorChanges {
                target: radar;
                anchors.horizontalCenter: undefined;
                anchors.left: satelliteInfoPage.left;
            }
            PropertyChanges {
                target: satellitesInfo;
                width: satelliteInfoPage.width / 2;
                anchors.leftMargin: satelliteInfoPage.width / 2.2;
            }
        }
    ]

    property alias pagePushTimer: pagePushTimer
    property bool barchartPagePushed: false
    Timer {
        id: pagePushTimer
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            if(!barchartPagePushed && satelliteInfoPage.status === PageStatus.Active) {
                console.log("Push barchartPage")
                pageStack.pushAttached(barchartPage)
                barchartPagePushed = true
            }
            else
                console.log("Don't push")
        }
    }

    property int radarWidth: Screen.width - Theme.paddingLarge
    property int diameter: radarWidth - 2 * Theme.paddingLarge
    property int radius: diameter / 2
    property int center: radarWidth / 2

    SilicaFlickable {
        anchors.fill: parent

        MainMenu { }

        PageHeader {
            title: qsTr("Satellite Info")
        }


        // Radar background gradient is symmetrical,
        // so we don't have to waste cycles rotating it.
        RadialGradient {
            id: radarBG
            anchors.centerIn: radar
            width: diameter
            height: diameter
            source: Rectangle {
                width: radarBG.width
                height: width
                radius: width / 2
            }

            horizontalOffset: 0
            horizontalRadius: width / 2
            verticalRadius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.0, 0.3, 0.0, 0.8) }
                GradientStop { position: 1.0; color: Qt.rgba(0.0, 0.7, 0.0, 0.8) }
            }
        }

        // The same applies to the radar rings, too.
        Repeater {
            model: [ 1, 2 ]
            delegate: Rectangle {
                width: diameter * Math.cos(Math.PI * modelData / 6)
                height: width
                anchors.centerIn: radar
                radius: width / 2
                color: "transparent"
                border.color: "#77ff77"
                border.width: Theme.iconSizeExtraSmall / 10.0
                opacity: 0.5
            }
        }

        // The main radar container item
        Item {
            id: radar
            width: radarWidth
            height: radarWidth
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter; //satelliteInfoPage.horizontalCenter;
            anchors.left: undefined;

            // At least with Jolla Phone, the reading must be negated
            // so that the compass turns in correct direction.

            property int north: !settings.rotate || status === PageStatus.Inactive || providers.compass.reading === null ? 0 : -providers.compass.reading.azimuth - declination;
            rotation: north

            // At least with Sony Xperia XA2, the compass value is updated
            // only a few times a second, resulting in jerkiness and poor user experience.
            // RotationAnimation really saves the day here!
            Behavior on rotation {
                RotationAnimation {
                    easing.type: Easing.Linear
                    direction: RotationAnimation.Shortest
                }
            }

            // The N-S and W-E lines, rotated by parent
            Repeater {
                model: [ 0, 1 ]
                delegate: Rectangle {
                    width: Theme.iconSizeExtraSmall / 10.0
                    height: diameter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: modelData * 90
                    color: "#77ff77"
                    opacity: 0.5
                }
            }
            // Magnetic North Indicator
            Rectangle {
                width: Theme.iconSizeExtraSmall / 10.0
                height: diameter/2
                anchors.left: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transform: Rotation { origin.x: 0 ; origin.y: diameter/2; angle: declination}
                color: "#77ff77"
                opacity: 0.5
                visible: settings.showMagneticNorth
            }
            // Movement Direction Indicator
            Rectangle {
                width: Theme.iconSizeExtraSmall / 10.0
                height: diameter/2
                anchors.left: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transform: Rotation { origin.x: 0 ; origin.y: diameter/2; angle: isNaN(providers.gps.movementDirection) ? 0 : providers.gps.movementDirection }
                border.color: "#ffffff"
                opacity: !isNaN(providers.gps.movementDirection) ? 0.75 : 0.0
                visible: settings.showDirectionIndicator && !isNaN(providers.gps.movementDirection)
            }

            // North, East, South, West, MagneticNorth indicators
            Repeater {
                model: settings.showMagneticNorth && declination !=0
                       ? [locationFormatter.north, locationFormatter.east, locationFormatter.south, locationFormatter.west, locationFormatter.mag]
                       : [locationFormatter.north, locationFormatter.east, locationFormatter.south, locationFormatter.west]

                delegate:
                    Label {
                    x: center + Math.sin((index !== 4 ? (index * 90) : declination) * Math.PI / 180) * (radius+width/2) - width / 2.0
                    y: center - Math.cos((index !== 4 ? (index * 90) : declination) * Math.PI / 180) * (radius+width/2) - height / 2.0
                    color: ["white","white","red"][iN]
                    font.weight: Font.Bold
                    font.pixelSize: Theme.fontSizeExtraSmall
                    property int iN: ((index !== 4 || !providers.compass.reading) ? 0 : (providers.compass.reading.calibrationLevel > 0.99 ? 1 : 2))
                    text: " "+[modelData,qsTr(locationFormatter.mag),"?"][iN]+" "


                    // Negate the radar containers rotation, so that the boxes and texts
                    // stay upright according to device orientation. Note that radar.rotation
                    // value read is already smoothed, so we can just use it raw.
                    rotation: -radar.rotation

                    Rectangle {
                        z: -1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width + parent.font.pixelSize / 8.0
                        height: parent.height + parent.font.pixelSize / 8.0
                        color: ["blue","red","transparent"][iN] //index !== 4 ? "blue" : "red"
                        radius: parent.font.pixelSize / 8.0
                    }
                }
            }
            // Satellite identifiers (numbers), and their respective box rssi color and inUse border
            // first draw them all solid , hiding the radar chart background, and ensuring colors are correct
            Repeater {
                model: status === PageStatus.Inactive ? [] : sortedSatellites
                delegate:
                    Label {
                    x: center + Math.sin((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - width / 2.0
                    y: center - Math.cos((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - height / 2.0
                    font.weight: Font.Bold
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: " "+modelData.identifier+" "
                    color: "white"
                    opacity: 1.0

                    // Negate the radar containers rotation, so that the boxes and texts
                    // stay upright according to device orientation. Note that radar.rotation
                    // value read is already smoothed, so we can just use it raw.
                    rotation: -radar.rotation

                    Rectangle {
                        z: -1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width + parent.font.pixelSize / 8.0
                        height: parent.height + parent.font.pixelSize / 8.0
                        color:  Qt.hsla(Math.floor(modelData.signalStrength < 40.0 ? modelData.signalStrength-(1.0/modelData.signalStrength) : 40.0) / 120.0, 1.0, 0.35, 1.0)
                        opacity: 1
                        radius: parent.font.pixelSize / 8.0

                        // If the satellite is used for calculating the position,
                        // draw a white border around the background box.
                        border.color: modelData.inUse ? "white" : "transparent"
                        border.width: modelData.inUse ? Theme.iconSizeExtraSmall / 10.0 : 0.0
                    }
                }
            }

            // Satellite identifiers (numbers), and their respective box rssi color and inUse border
            //now draw transparent, so that overlaid numbers can be read.
            Repeater {
                //sort active sats on top.
                model: status === PageStatus.Inactive ? [] : sortedSatellites
                delegate:
                    Label {
                    x: center + Math.sin((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - width / 2.0
                    y: center - Math.cos((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - height / 2.0
                    font.weight: Font.Bold
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: " "+modelData.identifier+" "
                    color: "white"

                    // Negate the radar containers rotation, so that the boxes and texts
                    // stay upright according to device orientation. Note that radar.rotation
                    // value read is already smoothed, so we can just use it raw.
                    rotation: -radar.rotation

                    // Rectangle {
                    //     z: -1
                    //     anchors.horizontalCenter: parent.horizontalCenter
                    //     anchors.verticalCenter: parent.verticalCenter
                    //     width: parent.width + parent.font.pixelSize / 8.0
                    //     height: parent.height + parent.font.pixelSize / 8.0
                    //     color: "transparent" //Qt.hsla(Math.floor(modelData.signalStrength < 40.0 ? modelData.signalStrength-(1.0/modelData.signalStrength) : 40.0) / 120.0, 1.0, 0.35, 1.0)
                    //     opacity: 0.5
                    //     radius: parent.font.pixelSize / 8.0

                    //     // If the satellite is used for calculating the position,
                    //     // draw a white border around the background box.
                    //     border.color: modelData.inUse ? "white" : "transparent"
                    //     border.width: modelData.inUse ? Theme.iconSizeExtraSmall / 10.0 : 0.0
                    // }
                }
            }


        }

        InfoField {
            id: satellitesInfo
            label: qsTr("Satellites in use / view")
            value: providers.gps.active ? providers.gps.numberOfUsedSatellites + " / " + providers.gps.numberOfVisibleSatellites : "-"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge*1.1  //move up a bit for parallax clipping at glass edge
        }
    }
}
