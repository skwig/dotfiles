import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

PopupWindow {
    id: root

    required property Theme theme
    required property Item anchorItem

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool hasAdapter: !!adapter
    readonly property bool adapterBlocked: hasAdapter && adapter.state === BluetoothAdapterState.Blocked
    readonly property bool adapterEnabled: hasAdapter && adapter.enabled && !adapterBlocked
    readonly property bool adapterBusy: hasAdapter && (adapter.state === BluetoothAdapterState.Enabling || adapter.state === BluetoothAdapterState.Disabling)
    readonly property bool scanning: hasAdapter && adapter.discovering
    readonly property var allDevices: sortedDevices(mergedDevices())
    readonly property var myDevices: allDevices.filter(device => device.connected || device.paired || device.bonded)
    readonly property var availableDevices: allDevices.filter(device => !device.connected && !device.paired && !device.bonded)
    readonly property var connectedDevice: allDevices.find(device => device.connected) || null
    readonly property string statusText: !hasAdapter ? "Bluetooth unavailable" : adapterBlocked ? "Bluetooth blocked" : adapterEnabled ? connectedDevice ? deviceName(connectedDevice) : "Bluetooth on" : "Bluetooth off"
    readonly property int scrollbarWidth: 14

    anchor.item: anchorItem
    anchor.rect.x: anchorItem.width / 2 - implicitWidth / 2
    anchor.rect.y: anchorItem.height + 4

    implicitWidth: 380
    implicitHeight: content.implicitHeight + 20
    visible: false
    color: "transparent"

    function deviceName(device) {
        if (!device)
            return "";
        return device.name || device.deviceName || device.address || "Unknown device";
    }

    function sortedDevices(devices) {
        return Array.from(devices).sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            const aBusy = a.pairing || a.state === BluetoothDeviceState.Connecting || a.state === BluetoothDeviceState.Disconnecting;
            const bBusy = b.pairing || b.state === BluetoothDeviceState.Connecting || b.state === BluetoothDeviceState.Disconnecting;
            if (aBusy !== bBusy)
                return aBusy ? -1 : 1;
            const aKnown = a.paired || a.bonded;
            const bKnown = b.paired || b.bonded;
            if (aKnown !== bKnown)
                return aKnown ? -1 : 1;
            return root.deviceName(a).localeCompare(root.deviceName(b));
        });
    }

    function mergedDevices() {
        const devices = new Map();
        for (const device of Bluetooth.devices.values)
            devices.set(deviceKey(device), device);
        if (root.hasAdapter) {
            for (const device of root.adapter.devices.values)
                devices.set(deviceKey(device), device);
        }
        return Array.from(devices.values());
    }

    function deviceKey(device) {
        return device.dbusPath || device.address || root.deviceName(device);
    }

    function deviceIcon(device) {
        const icon = device && device.icon ? device.icon : "";
        if (icon.includes("audio") || icon.includes("headset") || icon.includes("headphone"))
            return "󰋋";
        if (icon.includes("phone"))
            return "󰄜";
        if (icon.includes("computer"))
            return "󰌢";
        if (icon.includes("mouse"))
            return "󰍽";
        if (icon.includes("keyboard"))
            return "󰌌";
        if (icon.includes("display") || icon.includes("video"))
            return "󰍹";
        return "󰂯";
    }

    function deviceStatus(device) {
        if (!device)
            return "";
        if (device.pairing)
            return "Pairing";
        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting";
        if (device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting";
        if (device.connected)
            return device.batteryAvailable ? "Connected - " + Math.round(device.battery * 100) + "%" : "Connected";
        if (device.paired || device.bonded)
            return "Paired";
        return device.deviceName || "Available";
    }

    function primaryActionLabel(device) {
        if (!device)
            return "";
        if (device.connected)
            return "Drop";
        if (device.pairing)
            return "Cancel";
        if (device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting)
            return "...";
        if (device.paired || device.bonded)
            return "Join";
        return "Pair";
    }

    function primaryActionEnabled(device) {
        return root.adapterEnabled && !!device && device.state !== BluetoothDeviceState.Connecting && device.state !== BluetoothDeviceState.Disconnecting;
    }

    function runPrimaryAction(device) {
        if (!root.primaryActionEnabled(device))
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
                    deviceName: root.deviceName(modelData)
                    deviceIcon: root.deviceIcon(modelData)
                    deviceStatus: root.deviceStatus(modelData)
                    primaryActionLabel: root.primaryActionLabel(modelData)
                    primaryActionEnabled: root.primaryActionEnabled(modelData)
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
                    deviceName: root.deviceName(modelData)
                    deviceIcon: root.deviceIcon(modelData)
                    deviceStatus: root.deviceStatus(modelData)
                    primaryActionLabel: root.primaryActionLabel(modelData)
                    primaryActionEnabled: root.primaryActionEnabled(modelData)
                    showForget: false
                    onPrimaryAction: root.runPrimaryAction(modelData)
                    onForget: {}
                }
            }
        }
    }

    component BluetoothDeviceRow: Item {
        id: row

        required property Theme theme
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
