import QtQuick
import Quickshell.Networking

Item {
    id: root

    required property Theme theme

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(device => device.type === DeviceType.Wifi) || null
    readonly property var wiredDevice: devices.find(device => device.type === DeviceType.Wired && device.connected) || devices.find(device => device.type === DeviceType.Wired && device.hasLink) || null
    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var connectedWifi: wifiNetworks.find(network => network.connected) || null
    readonly property bool wifiAvailable: !!wifiDevice
    readonly property bool wifiEnabled: Networking.wifiEnabled && Networking.wifiHardwareEnabled
    readonly property bool wifiConnected: !!connectedWifi
    readonly property bool ethernetConnected: !!wiredDevice && wiredDevice.connected
    readonly property int signalStrength: connectedWifi ? Math.round(connectedWifi.signalStrength * 100) : 0
    readonly property string ssid: connectedWifi ? connectedWifi.name : ""

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 10

    function networkIcon() {
        if (root.ethernetConnected)
            return "󰈀";
        if (!root.wifiAvailable || !root.wifiEnabled)
            return "󰖪";
        if (root.wifiConnected) {
            if (root.signalStrength >= 75)
                return "󰤨";
            if (root.signalStrength >= 50)
                return "󰤥";
            if (root.signalStrength >= 25)
                return "󰤢";
            return "󰤟";
        }
        return "󰤮";
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
            text: root.networkIcon()
            color: root.theme.fontColor
            font.family: root.theme.font.family
            font.pixelSize: root.theme.font.pixelSize
        }
    }

}
