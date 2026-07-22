import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import ".." as Root
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

    Rectangle {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        implicitHeight: column.implicitHeight + 24
        color: Qt.rgba(0, 0, 0, 0.8)
        radius: root.theme.radius

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    text: !root.hasAdapter || root.adapterBlocked || !root.adapterEnabled ? "󰂲" : "󰂯"
                    color: root.theme.fontColor
                    font.family: root.theme.font.family
                    font.pixelSize: root.theme.font.pixelSize
                }

                Column {
                    width: parent.width - 152
                    spacing: 2

                    Text {
                        width: parent.width
                        text: "Bluetooth"
                        color: root.theme.fontColor
                        font: root.theme.font
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.scanning ? "Scanning" : root.statusText
                        color: Qt.rgba(1, 1, 1, 0.55)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                        elide: Text.ElideRight
                    }
                }

                Button {
                    width: 48
                    text: root.adapterEnabled ? "Off" : "On"
                    enabled: root.hasAdapter && !root.adapterBusy && !root.adapterBlocked
                    onClicked: root.adapter.enabled = !root.adapter.enabled
                }

                Button {
                    width: 50
                    text: root.scanning ? "..." : "Scan"
                    enabled: root.adapterEnabled && !root.adapterBusy
                    onClicked: root.adapter.discovering = !root.adapter.discovering
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: "My Devices"
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                font.bold: true
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
                    deviceIcon: root.bluetoothService.deviceIcon(modelData)
                    deviceStatus: root.bluetoothService.deviceStatus(modelData)
                    primaryActionLabel: root.bluetoothService.primaryActionLabel(modelData)
                    primaryActionEnabled: root.bluetoothService.primaryActionEnabled(modelData)
                    showForget: !!modelData && (modelData.paired || modelData.bonded)
                    onPrimaryAction: root.runPrimaryAction(modelData)
                    onForget: modelData.forget()
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: "Available Devices"
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                font.bold: true
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
                    deviceIcon: root.bluetoothService.deviceIcon(modelData)
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

        signal primaryAction()
        signal forget()

        implicitHeight: device ? 48 : 24

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: !row.device
            text: row.emptyText
            color: Qt.rgba(1, 1, 1, 0.45)
            font.family: row.theme.font.family
            font.pixelSize: row.theme.font.pixelSize - 2
            elide: Text.ElideRight
        }

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: !!row.device
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                text: row.deviceIcon
                color: row.theme.fontColor
                font.family: row.theme.font.family
                font.pixelSize: row.theme.font.pixelSize
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - (row.showForget ? 158 : 92)
                spacing: 1

                Text {
                    width: parent.width
                    text: row.deviceName
                    color: row.theme.fontColor
                    font.family: row.theme.font.family
                    font.pixelSize: row.theme.font.pixelSize - 2
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: row.deviceStatus
                    color: Qt.rgba(1, 1, 1, 0.55)
                    font.family: row.theme.font.family
                    font.pixelSize: row.theme.font.pixelSize - 3
                    elide: Text.ElideRight
                }
            }

            Button {
                width: 60
                text: row.primaryActionLabel
                enabled: row.primaryActionEnabled
                onClicked: row.primaryAction()
            }

            Button {
                width: 58
                visible: row.showForget
                text: "Forget"
                enabled: !!row.device
                onClicked: row.forget()
            }
        }
    }
}
