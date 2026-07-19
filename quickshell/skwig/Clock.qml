import Quickshell
import QtQuick

Item {
    id: clock

    required property string format
    required property Theme theme

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 10

    SystemClock {
        id: sysclock
        precision: SystemClock.Minutes
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: clock.theme.radius
        color: hoverHandler.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        HoverHandler {
            id: hoverHandler
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: clock.clicked()
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: Qt.formatDateTime(sysclock.date, clock.format)
            color: clock.theme.fontColor
            font: clock.theme.font
        }
    }
}
