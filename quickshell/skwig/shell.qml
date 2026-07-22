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
    readonly property var timeService: timeServiceInstance
    readonly property var audioService: audioServiceInstance
    readonly property var batteryService: batteryServiceInstance
    readonly property var networkService: networkServiceInstance
    readonly property var bluetoothService: bluetoothServiceInstance
    readonly property var notificationService: notificationServiceInstance

    function focusedScreen() {
        return Quickshell.screens.find(screen => Hyprland.monitorFor(screen) === Hyprland.focusedMonitor) ?? Quickshell.screens[0] ?? null;
    }

    function openPopup(popup, anchorItem) {
        popup.anchorItem = anchorItem;
        popup.visible = !popup.visible;
    }

    Variants {
        id: bars
        model: Quickshell.screens

        delegate: Scope {
            id: bar

            required property ShellScreen modelData

            PanelWindow {
                screen: bar.modelData

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
                            onClicked: root.openPopup(systemTrayPopup, systemTray)
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
                            networkService: root.networkService
                            onClicked: root.openPopup(networkPopup, network)
                        }

                        Bluetooth {
                            id: bluetooth
                            theme: root.theme
                            bluetoothService: root.bluetoothService
                            onClicked: root.openPopup(bluetoothPopup, bluetooth)
                        }

                        Battery {
                            id: battery
                            theme: root.theme
                            batteryService: root.batteryService
                            hideWhenUnavailable: true
                            onClicked: root.openPopup(batteryPopup, battery)
                        }

                        Volume {
                            id: volume
                            theme: root.theme
                            audioService: root.audioService
                            onClicked: root.openPopup(volumePopup, volume)
                        }

                        Notifications {
                            id: notifications
                            theme: root.theme
                            count: root.notificationService.notificationCount
                            onClicked: root.openPopup(notificationHistoryPopup, notifications)
                        }

                        Clock {
                            id: clock
                            format: "HH:mm"
                            theme: root.theme
                            timeService: root.timeService
                            onClicked: root.openPopup(calendarPopup, clock)
                        }
                    }
                }
            }
        }
    }

    VolumeOsd {
        theme: root.theme
        audioService: root.audioService
        targetScreen: root.focusedScreen()
    }

    Services.TimeService {
        id: timeServiceInstance
    }

    Services.AudioService {
        id: audioServiceInstance
    }

    Services.BatteryService {
        id: batteryServiceInstance
    }

    Services.NetworkService {
        id: networkServiceInstance
    }

    Services.BluetoothService {
        id: bluetoothServiceInstance
    }

    Services.NotificationService {
        id: notificationServiceInstance
        timeService: root.timeService
    }

    NotificationsOsd {
        theme: root.theme
        notificationService: root.notificationService
        targetScreen: root.focusedScreen()
    }

    CalendarPopup {
        id: calendarPopup
        theme: root.theme
        timeService: root.timeService
    }

    VolumePopup {
        id: volumePopup
        theme: root.theme
        audioService: root.audioService
    }

    NetworkPopup {
        id: networkPopup
        theme: root.theme
        networkService: root.networkService
    }

    BluetoothPopup {
        id: bluetoothPopup
        theme: root.theme
        bluetoothService: root.bluetoothService
    }

    BatteryPopup {
        id: batteryPopup
        theme: root.theme
        batteryService: root.batteryService
    }

    SystemTrayPopup {
        id: systemTrayPopup
        theme: root.theme
    }

    NotificationsPopup {
        id: notificationHistoryPopup
        theme: root.theme
        notificationService: root.notificationService
    }
}
