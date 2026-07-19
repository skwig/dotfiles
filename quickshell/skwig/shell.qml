import Quickshell
import QtQuick

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 32

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)

        Workspaces {
            anchors.horizontalCenter: parent.horizontalCenter
            minCount: 5
        }

        WindowTitle {
            anchors.left: parent.left
        }

        Clock {
            anchors.right: parent.right
            format: "HH:mm"
        }
    }
}
