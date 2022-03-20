import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    PullDownMenu {
        MenuItem {
            text: qsTr("About")
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/AboutPage.qml"))
        }
        MenuItem {
            text: qsTr("Settings")
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/SettingsPage.qml"))
        }
        MenuItem {
            text: providers.position.active ? qsTr("Deactivate GPS") : qsTr("Activate GPS")
            onClicked: {
                providers.toggleActive()
            }
        }
        MenuItem {
            enabled: providers.gps.active
            text: qsTr("Copy location")
            onClicked: {
                if (settings.coordinateFormat === "DEG") {
                    Clipboard.text = locationFormatter.decimalLatToDMS(providers.position.position.coordinate.latitude, 2)
                            + ", "
                            + locationFormatter.decimalLongToDMS(providers.position.position.coordinate.longitude, 2);
                } else {
                    Clipboard.text = providers.position.position.coordinate.latitude
                            + ", "
                            + providers.position.position.coordinate.longitude
                }
            }
        }
    }
}
