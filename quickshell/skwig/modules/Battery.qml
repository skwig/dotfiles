import QtQuick
import ".."

Item {
    id: root

    required property Theme theme
    required property var batteryService
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
                text: root.batteryService.batteryIcon()
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryAvailable ? root.percentage + "%" : "--%"
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
            }
        }
    }
}
