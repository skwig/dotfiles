import QtQuick
import ".." as Root
import "../services" as Services

Item {
    id: root

    required property Root.Theme theme
    required property Services.BatteryService batteryService
    property bool hideWhenUnavailable: false

    readonly property bool batteryAvailable: batteryService.batteryAvailable
    readonly property int percentage: batteryService.percentage

    signal clicked

    anchors.verticalCenter: parent.verticalCenter
    visible: !hideWhenUnavailable || batteryAvailable
    implicitWidth: visible ? content.implicitWidth + 20 : 0
    implicitHeight: content.implicitHeight + 10

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: hoverHandler.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        HoverHandler {
            id: hoverHandler
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryService.batterySymbol()
                color: root.theme.onSurface
                font.family: root.theme.iconFontFamily
                font.pixelSize: root.theme.iconSizeSmall
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryAvailable ? root.percentage + "%" : "--%"
                color: root.theme.onSurface
                font: root.theme.fontSmall
            }
        }
    }
}
