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

    readonly property Theme theme: Theme {
        font: ({ family: "JetBrainsMono Nerd Font", pixelSize: 13 })
        fontColor: "#ffffff"
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)

        Workspaces {
            anchors.horizontalCenter: parent.horizontalCenter
            minCount: 5
            theme: root.theme
        }

        WindowTitle {
            anchors.left: parent.left
            theme: root.theme
        }

        Clock {
            anchors.right: parent.right
            format: "HH:mm"
            theme: root.theme
        }
    }
}
