import Quickshell
import QtQuick

ShellRoot {
    id: root

    readonly property Theme theme: Theme {
        font: ({
                family: "JetBrainsMono Nerd Font",
                pixelSize: 16
            })
        fontColor: "#ffffff"
        radius: 4
    }

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 40
        color: "transparent"

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
                id: clock
                anchors.right: parent.right
                format: "HH:mm"
                theme: root.theme
                onClicked: calendarPopup.visible = !calendarPopup.visible
            }
        }
    }

    CalendarPopup {
        id: calendarPopup
        theme: root.theme
        anchorItem: clock
    }
}
