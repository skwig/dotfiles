import Quickshell
import QtQuick

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    // WlrLayershell.layer: WlrLayer.Top
    // WlrLayershell.exclusiveZone: -1

    implicitHeight: 30

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
    }
}
