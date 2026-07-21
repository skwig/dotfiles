import QtQuick
import Quickshell.Bluetooth

Item {
    id: root

    required property Theme theme

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values
    readonly property var connectedDevice: connectedDevices.find(device => device.connected) || null
    readonly property bool hasAdapter: !!adapter
    readonly property bool adapterBlocked: hasAdapter && adapter.state === BluetoothAdapterState.Blocked
    readonly property bool adapterEnabled: hasAdapter && adapter.enabled && !adapterBlocked
    readonly property bool hasConnectedDevice: !!connectedDevice
    readonly property string connectedDeviceName: connectedDevice ? deviceName(connectedDevice) : ""

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 10

    function deviceName(device) {
        if (!device)
            return "";
        return device.name || device.deviceName || device.address || "Unknown device";
    }

    function bluetoothIcon() {
        if (!root.hasAdapter || root.adapterBlocked || !root.adapterEnabled)
            return "󰂲";
        if (root.hasConnectedDevice)
            return "󰂱";
        return "󰂯";
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: hoverHandler.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        HoverHandler {
            id: hoverHandler
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: root.bluetoothIcon()
            color: root.theme.fontColor
            font.family: root.theme.font.family
            font.pixelSize: root.theme.font.pixelSize
        }
    }
}
