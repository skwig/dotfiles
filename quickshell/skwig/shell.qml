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

        delegate: Bar {
            required property ShellScreen modelData

            screen: modelData
            theme: root.theme
            notificationService: root.notificationService

            onSystemTrayClicked: anchorItem => root.openPopup(systemTrayPopup, anchorItem)
            onNetworkClicked: anchorItem => root.openPopup(networkPopup, anchorItem)
            onBluetoothClicked: anchorItem => root.openPopup(bluetoothPopup, anchorItem)
            onBatteryClicked: anchorItem => root.openPopup(batteryPopup, anchorItem)
            onVolumeClicked: anchorItem => root.openPopup(volumePopup, anchorItem)
            onNotificationsClicked: anchorItem => root.openPopup(notificationHistoryPopup, anchorItem)
            onClockClicked: anchorItem => root.openPopup(calendarPopup, anchorItem)
        }
    }

    VolumeOsd {
        theme: root.theme
        targetScreen: root.focusedScreen()
    }

    Services.NotificationService {
        id: notificationServiceInstance
    }

    NotificationsOsd {
        theme: root.theme
        notificationService: root.notificationService
        targetScreen: root.focusedScreen()
    }

    CalendarPopup {
        id: calendarPopup
        theme: root.theme
    }

    VolumePopup {
        id: volumePopup
        theme: root.theme
    }

    NetworkPopup {
        id: networkPopup
        theme: root.theme
    }

    BluetoothPopup {
        id: bluetoothPopup
        theme: root.theme
    }

    BatteryPopup {
        id: batteryPopup
        theme: root.theme
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
