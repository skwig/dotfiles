//@ pragma UseQApplication

import Quickshell
import Quickshell.Hyprland
import QtQuick
import "services" as Services

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
    readonly property var notificationService: notificationServiceInstance
    readonly property var popups: [calendarPopup, volumePopup, networkPopup, bluetoothPopup, batteryPopup, systemTrayPopup, notificationHistoryPopup]
    property bool switchingPopup: false

    function closePopups(except) {
        for (const popup of popups) {
            if (popup !== except)
                popup.visible = false;
        }
    }

    function togglePopup(popup) {
        switchingPopup = true;
        const nextVisible = !popup.visible;
        closePopups(popup);
        popup.visible = nextVisible;
        Qt.callLater(() => switchingPopup = false);
    }

    PanelWindow {
        id: barWindow

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
                id: leftModules
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                SystemTray {
                    id: systemTray
                    theme: root.theme
                    hideWhenEmpty: false
                    onClicked: root.togglePopup(systemTrayPopup)
                }

                WindowTitle {
                    theme: root.theme
                }
            }

            Row {
                id: rightModules
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Submap {
                    theme: root.theme
                    hideWhenDefault: true
                }

                Network {
                    id: network
                    theme: root.theme
                    onClicked: root.togglePopup(networkPopup)
                }

                Bluetooth {
                    id: bluetooth
                    theme: root.theme
                    onClicked: root.togglePopup(bluetoothPopup)
                }

                Battery {
                    id: battery
                    theme: root.theme
                    hideWhenUnavailable: true
                    onClicked: root.togglePopup(batteryPopup)
                }

                Volume {
                    id: volume
                    theme: root.theme
                    onClicked: root.togglePopup(volumePopup)
                }

                Notifications {
                    id: notifications
                    theme: root.theme
                    count: root.notificationService.notificationCount
                    onClicked: root.togglePopup(notificationHistoryPopup)
                }

                Clock {
                    id: clock
                    format: "HH:mm"
                    theme: root.theme
                    onClicked: root.togglePopup(calendarPopup)
                }
            }
        }
    }

    VolumeOsd {
        theme: root.theme
    }

    Services.NotificationService {
        id: notificationServiceInstance
    }

    NotificationsOsd {
        theme: root.theme
        notificationService: root.notificationService
    }

    HyprlandFocusGrab {
        active: root.popups.some(popup => popup.visible)
        windows: [barWindow].concat(root.popups.filter(popup => popup.visible))
        onCleared: {
            if (!root.switchingPopup)
                root.closePopups(null);
        }
    }

    CalendarPopup {
        id: calendarPopup
        theme: root.theme
        anchorItem: clock
    }

    VolumePopup {
        id: volumePopup
        theme: root.theme
        anchorItem: volume
    }

    NetworkPopup {
        id: networkPopup
        theme: root.theme
        anchorItem: network
    }

    BluetoothPopup {
        id: bluetoothPopup
        theme: root.theme
        anchorItem: bluetooth
    }

    BatteryPopup {
        id: batteryPopup
        theme: root.theme
        anchorItem: battery
    }

    SystemTrayPopup {
        id: systemTrayPopup
        theme: root.theme
        anchorItem: systemTray
    }

    NotificationsPopup {
        id: notificationHistoryPopup
        theme: root.theme
        anchorItem: notifications
        notificationService: root.notificationService
    }
}
