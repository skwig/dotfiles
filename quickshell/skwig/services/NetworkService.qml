import Quickshell
import Quickshell.Networking

Scope {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(device => device.type === DeviceType.Wifi) || null
    readonly property var wiredDevices: devices.filter(device => device.type === DeviceType.Wired)
    readonly property var wiredDevice: wiredDevices.find(device => device.connected) || wiredDevices.find(device => device.hasLink) || null
    readonly property var wiredNetwork: wiredDevice && wiredDevice.network ? wiredDevice.network : null
    readonly property var wifiNetworkObjects: wifiDevice ? wifiDevice.networks.values : []
    readonly property var networks: sortedNetworks()
    readonly property var connectedWifi: wifiNetworkObjects.find(network => network.connected) || null
    readonly property bool wifiAvailable: !!wifiDevice
    readonly property bool wifiEnabled: Networking.wifiEnabled && Networking.wifiHardwareEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool wifiConnected: !!connectedWifi
    readonly property bool ethernetConnected: !!wiredDevice && wiredDevice.connected
    readonly property bool scanning: !!wifiDevice && wifiDevice.scannerEnabled
    readonly property int signalStrength: connectedWifi ? Math.round(connectedWifi.signalStrength * 100) : 0
    readonly property string ssid: connectedWifi ? connectedWifi.name : ""
    readonly property string currentSsid: ssid
    readonly property string ethernetDevice: wiredDevice ? wiredDevice.name : ""
    readonly property string ethernetConnection: wiredNetwork ? wiredNetwork.name : ""
    readonly property string ethernetSpeed: wiredDevice && wiredDevice.linkSpeed > 0 ? wiredDevice.linkSpeed + " Mb/s" : ""

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled;
    }

    function sortedNetworks() {
        const byName = new Map();
        for (const network of root.wifiNetworkObjects) {
            if (!network.name || network.name.length === 0)
                continue;
            const existing = byName.get(network.name);
            if (!existing || network.connected || (!existing.connected && network.signalStrength > existing.signalStrength))
                byName.set(network.name, network);
        }
        return Array.from(byName.values()).sort((a, b) => {
            if (a.connected && !b.connected)
                return -1;
            if (!a.connected && b.connected)
                return 1;
            if (a.known && !b.known)
                return -1;
            if (!a.known && b.known)
                return 1;
            return b.signalStrength - a.signalStrength;
        });
    }

    function securityLabel(network) {
        if (!network || network.security === WifiSecurityType.Open)
            return "Open";
        return WifiSecurityType.toString(network.security);
    }

    function hasPasswordSecurity(network) {
        return !!network && (network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae);
    }

    function networkIcon(strength, secured) {
        if (secured) {
            if (strength >= 75)
                return "󰤪";
            if (strength >= 50)
                return "󰤧";
            if (strength >= 25)
                return "󰤤";
            return "󰤡";
        }
        if (strength >= 75)
            return "󰤨";
        if (strength >= 50)
            return "󰤥";
        if (strength >= 25)
            return "󰤢";
        return "󰤟";
    }

    function statusIcon() {
        if (root.ethernetConnected)
            return "󰈀";
        if (!root.wifiAvailable || !root.wifiEnabled)
            return "󰖪";
        if (root.wifiConnected)
            return root.networkIcon(root.signalStrength, false);
        return "󰤮";
    }

    function networkDetails(network) {
        if (!network)
            return "";
        const security = root.securityLabel(network);
        if (network.connected)
            return security + " - Connected";
        if (network.stateChanging)
            return security + " - Connecting";
        return network.known ? security + " - Saved" : security;
    }
}
