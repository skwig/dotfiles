//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Common
import qs.DankCommon.Widgets

ShellRoot {
    id: root

    readonly property real barHeight: 44

    readonly property var adapter: Bluetooth.defaultAdapter

    readonly property bool btAvailable: adapter !== null
    readonly property bool btEnabled: adapter?.enabled ?? false
    readonly property bool btConnected: {
        if (!adapter?.devices) return false;
        return Array.from(adapter.devices.values).some(d => d.connected);
    }

    property bool popupVisible: false
    property var popupAnchor: null
    property var popupScreen: null

    function togglePopup() {
        popupVisible = !popupVisible;
    }

    function closePopup() {
        popupVisible = false;
    }

    Variants {
        id: bars
        model: Quickshell.screens

        delegate: PanelWindow {
            required property ShellScreen modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: root.barHeight
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.withAlpha(Theme.surfaceContainer, 0.92)
                radius: 0

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height

                    Item {
                        id: btWidget
                        width: 40
                        height: parent.height

                        readonly property bool hovered: btHoverHandler.hovered

                        Rectangle {
                            anchors.centerIn: parent
                            width: 34
                            height: 34
                            radius: Theme.cornerRadius
                            color: btWidget.hovered
                                ? Theme.primaryHover
                                : "transparent"
                        }

                        DankIcon {
                            anchors.centerIn: parent
                            name: {
                                if (!root.btAvailable) return "bluetooth_disabled";
                                if (root.btConnected) return "bluetooth_connected";
                                if (root.btEnabled) return "bluetooth";
                                return "bluetooth_disabled";
                            }
                            size: 22
                            color: {
                                if (!root.btAvailable) return Theme.surfaceVariantText;
                                if (root.btConnected) return Theme.primary;
                                if (root.btEnabled) return Theme.surfaceText;
                                return Theme.surfaceVariantText;
                            }
                        }

                        HoverHandler { id: btHoverHandler }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.popupAnchor = btWidget;
                                root.popupScreen = modelData;
                                root.togglePopup();
                            }
                        }
                    }
                }
            }
        }
    }

    BluetoothPopout {
        id: bluetoothPopout
        visible: root.popupVisible
        screen: root.popupScreen
        anchor.item: root.popupAnchor
        anchor.rect.x: root.popupAnchor
            ? root.popupAnchor.width - bluetoothPopout.implicitWidth - Theme.spacingM
            : 0
        anchor.rect.y: root.barHeight + 4
    }

    Keys.onEscapePressed: root.closePopup()
}
