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

    function togglePopup(popup) {
        const nextVisible = !popup.visible;
        calendarPopup.visible = false;
        volumePopup.visible = false;
        networkPopup.visible = false;
        bluetoothPopup.visible = false;
        batteryPopup.visible = false;
        popup.visible = nextVisible;
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

                Clock {
                    id: clock
                    format: "HH:mm"
                    theme: root.theme
                    onClicked: root.togglePopup(calendarPopup)
                }
            }
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
}
