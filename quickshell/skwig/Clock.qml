import Quickshell
import QtQuick

Item {
    id: clock

    required property string format
    required property Theme theme

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: label.implicitWidth + 20

    SystemClock {
        id: sysclock
        precision: SystemClock.Seconds
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        text: Qt.formatDateTime(sysclock.date, clock.format)
        color: theme.fontColor
        font: theme.font
    }
}
