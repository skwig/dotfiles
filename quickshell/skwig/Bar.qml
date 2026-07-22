import QtQuick
import Quickshell

Scope {
    id: root

    required property ShellScreen screen
    required property Theme theme
    required property var notificationService

    readonly property var window: barWindow

    signal systemTrayClicked(Item anchorItem)
    signal networkClicked(Item anchorItem)
    signal bluetoothClicked(Item anchorItem)
    signal batteryClicked(Item anchorItem)
    signal volumeClicked(Item anchorItem)
    signal notificationsClicked(Item anchorItem)
    signal clockClicked(Item anchorItem)

    PanelWindow {
        id: barWindow

        screen: root.screen

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

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                SystemTray {
                    id: systemTray
                    theme: root.theme
                    hideWhenEmpty: false
                    onClicked: root.systemTrayClicked(systemTray)
                }

                WindowTitle {
                    theme: root.theme
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Submap {
                    theme: root.theme
                    hideWhenDefault: true
                }

                Network {
                    id: network
                    theme: root.theme
                    onClicked: root.networkClicked(network)
                }

                Bluetooth {
                    id: bluetooth
                    theme: root.theme
                    onClicked: root.bluetoothClicked(bluetooth)
                }

                Battery {
                    id: battery
                    theme: root.theme
                    hideWhenUnavailable: true
                    onClicked: root.batteryClicked(battery)
                }

                Volume {
                    id: volume
                    theme: root.theme
                    onClicked: root.volumeClicked(volume)
                }

                Notifications {
                    id: notifications
                    theme: root.theme
                    count: root.notificationService.notificationCount
                    onClicked: root.notificationsClicked(notifications)
                }

                Clock {
                    id: clock
                    format: "HH:mm"
                    theme: root.theme
                    onClicked: root.clockClicked(clock)
                }
            }
        }
    }
}
