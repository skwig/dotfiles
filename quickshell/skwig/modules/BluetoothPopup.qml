import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import ".." as Root
import "../components" as Components
import "../services" as Services

PopupWindow {
    id: root

    required property Root.Theme theme
    required property Services.BluetoothService bluetoothService
    property Item anchorItem: null

    readonly property var adapter: bluetoothService.adapter
    readonly property bool hasAdapter: bluetoothService.hasAdapter
    readonly property bool adapterBlocked: bluetoothService.adapterBlocked
    readonly property bool adapterEnabled: bluetoothService.adapterEnabled
    readonly property bool adapterBusy: bluetoothService.adapterBusy
    readonly property bool scanning: bluetoothService.scanning
    readonly property var allDevices: bluetoothService.allDevices
    readonly property var myDevices: bluetoothService.myDevices
    readonly property var availableDevices: bluetoothService.availableDevices
    readonly property var connectedDevice: bluetoothService.connectedDevice
    readonly property string statusText: bluetoothService.statusText
    readonly property int scrollbarWidth: 14

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 380
    implicitHeight: content.implicitHeight + 20
    visible: false
    grabFocus: true
    color: "transparent"

    function runPrimaryAction(device) {
        if (!root.bluetoothService.primaryActionEnabled(device))
            return;
        if (device.connected) {
            device.disconnect();
        } else if (device.pairing) {
            device.cancelPair();
        } else if (device.paired || device.bonded) {
            device.connect();
        } else {
            device.pair();
        }
    }

    function deviceSymbol(device) {
        const icon = device && device.icon ? device.icon : "";
        if (icon.includes("audio") || icon.includes("headset") || icon.includes("headphone"))
            return "headphones";
        if (icon.includes("phone"))
            return "phone_android";
        if (icon.includes("keyboard"))
            return "keyboard";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("computer") || icon.includes("display") || icon.includes("video"))
            return "desktop_windows";
        return "bluetooth";
    }

    Components.MaterialPopupSurface {
        id: content
        theme: root.theme
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        contentPadding: root.theme.spacingM
        implicitHeight: column.implicitHeight + contentPadding * 2

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 10

            Components.MaterialCard {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                highlighted: root.adapterEnabled
                implicitHeight: headerRow.implicitHeight + contentPadding * 2

                Row {
                    id: headerRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.theme.spacingS

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        text: !root.hasAdapter || root.adapterBlocked || !root.adapterEnabled ? "bluetooth_disabled" : root.connectedDevice ? "bluetooth_connected" : "bluetooth"
                        color: root.connectedDevice ? root.theme.primary : root.adapterEnabled ? root.theme.onSurface : root.theme.muted
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.iconSize
                    }

                    Column {
                        width: parent.width - 114
                        spacing: 2

                        Text {
                            width: parent.width
                            text: "Bluetooth"
                            color: root.theme.onSurface
                            font: root.theme.font
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: root.scanning ? "Scanning" : root.statusText
                            color: root.theme.muted
                            font: root.theme.fontSmall
                            elide: Text.ElideRight
                        }
                    }

                    Components.MaterialIconButton {
                        theme: root.theme
                        iconName: root.adapterEnabled ? "bluetooth_disabled" : "bluetooth"
                        label: root.adapterEnabled ? "Off" : "On"
                        selected: root.adapterEnabled
                        opacity: root.hasAdapter && !root.adapterBusy && !root.adapterBlocked ? 1 : 0.38
                        enabled: root.hasAdapter && !root.adapterBusy && !root.adapterBlocked
                        onClicked: root.adapter.enabled = !root.adapter.enabled
                    }

                    Components.MaterialIconButton {
                        theme: root.theme
                        iconName: "refresh"
                        label: root.scanning ? "..." : "Scan"
                        opacity: root.adapterEnabled && !root.adapterBusy ? 1 : 0.38
                        enabled: root.adapterEnabled && !root.adapterBusy
                        onClicked: root.adapter.discovering = !root.adapter.discovering
                    }
                }
            }

            Components.MaterialSectionLabel {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                text: "My Devices"
            }

            ListView {
                id: myDeviceList
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.min(contentHeight, 170)
                clip: true
                spacing: 6
                model: root.adapterEnabled && root.myDevices.length > 0 ? root.myDevices : [null]
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: myDeviceList.contentHeight > myDeviceList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: BluetoothDeviceRow {
                    required property var modelData

                    width: myDeviceList.width - root.scrollbarWidth
                    theme: root.theme
                    device: modelData
                    emptyText: !root.hasAdapter ? "No Bluetooth adapter found" : !root.adapterEnabled ? "Bluetooth is off" : "No paired devices"
                    deviceName: root.bluetoothService.deviceName(modelData)
                    deviceIcon: root.deviceSymbol(modelData)
                    deviceStatus: root.bluetoothService.deviceStatus(modelData)
                    primaryActionLabel: root.bluetoothService.primaryActionLabel(modelData)
                    primaryActionEnabled: root.bluetoothService.primaryActionEnabled(modelData)
                    showForget: !!modelData && (modelData.paired || modelData.bonded)
                    onPrimaryAction: root.runPrimaryAction(modelData)
                    onForget: modelData.forget()
                }
            }

            Components.MaterialSectionLabel {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                text: "Available Devices"
            }

            ListView {
                id: availableDeviceList
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.min(contentHeight, 220)
                clip: true
                spacing: 6
                model: root.adapterEnabled && root.availableDevices.length > 0 ? root.availableDevices : [null]
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: availableDeviceList.contentHeight > availableDeviceList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: BluetoothDeviceRow {
                    required property var modelData

                    width: availableDeviceList.width - root.scrollbarWidth
                    theme: root.theme
                    device: modelData
                    emptyText: !root.hasAdapter ? "No Bluetooth adapter found" : !root.adapterEnabled ? "Bluetooth is off" : root.scanning ? "No devices found" : "Start scanning to find devices"
                    deviceName: root.bluetoothService.deviceName(modelData)
                    deviceIcon: root.deviceSymbol(modelData)
                    deviceStatus: root.bluetoothService.deviceStatus(modelData)
                    primaryActionLabel: root.bluetoothService.primaryActionLabel(modelData)
                    primaryActionEnabled: root.bluetoothService.primaryActionEnabled(modelData)
                    showForget: false
                    onPrimaryAction: root.runPrimaryAction(modelData)
                    onForget: {}
                }
            }
        }
    }

    component BluetoothDeviceRow: Item {
        id: row

        required property Root.Theme theme
        property var device: null
        property string emptyText: ""
        property string deviceName: ""
        property string deviceIcon: ""
        property string deviceStatus: ""
        property string primaryActionLabel: ""
        property bool primaryActionEnabled: false
        property bool showForget: false

        signal primaryAction
        signal forget

        implicitHeight: device ? 48 : 24

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: !row.device
            text: row.emptyText
            color: row.theme.muted
            font: row.theme.fontSmall
            elide: Text.ElideRight
        }

        Components.MaterialCard {
            anchors.fill: parent
            visible: !!row.device
            theme: row.theme
            highlighted: row.device && row.device.connected
            interactive: true
            contentPadding: row.theme.spacingS

            Row {
                anchors.fill: parent
                spacing: row.theme.spacingS

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    text: row.device && row.device.connected ? "bluetooth_connected" : row.deviceIcon
                    color: row.device && row.device.connected ? row.theme.primary : row.theme.onSurface
                    font.family: row.theme.iconFontFamily
                    font.pixelSize: row.theme.iconSize
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (row.showForget ? 166 : 100)
                    spacing: 1

                    Text {
                        width: parent.width
                        text: row.deviceName
                        color: row.theme.onSurface
                        font: row.theme.fontSmall
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: row.deviceStatus
                        color: row.theme.muted
                        font: row.theme.fontTiny
                        elide: Text.ElideRight
                    }
                }

                Components.MaterialIconButton {
                    theme: row.theme
                    iconName: row.device && row.device.connected ? "link_off" : row.device && (row.device.paired || row.device.bonded) ? "bluetooth_connected" : "login"
                    label: row.primaryActionLabel
                    filled: row.primaryActionEnabled && !(row.device && row.device.connected)
                    opacity: row.primaryActionEnabled ? 1 : 0.38
                    enabled: row.primaryActionEnabled
                    onClicked: row.primaryAction()
                }

                Components.MaterialIconButton {
                    theme: row.theme
                    iconName: "delete"
                    label: "Forget"
                    visible: row.showForget
                    enabled: !!row.device
                    onClicked: row.forget()
                }
            }
        }
    }
}
