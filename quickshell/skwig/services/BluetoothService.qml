import Quickshell
import Quickshell.Bluetooth

Scope {
    id: root

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
    readonly property bool hasConnectedDevice: !!connectedDevice
    readonly property string connectedDeviceName: connectedDevice ? deviceName(connectedDevice) : ""
    readonly property string statusText: !hasAdapter ? "Bluetooth unavailable" : adapterBlocked ? "Bluetooth blocked" : adapterEnabled ? connectedDevice ? deviceName(connectedDevice) : "Bluetooth on" : "Bluetooth off"

    function deviceName(device) {
        if (!device)
            return "";
        return device.name || device.deviceName || device.address || "Unknown device";
    }

    function bluetoothSymbol() {
        if (!root.hasAdapter || root.adapterBlocked || !root.adapterEnabled)
            return "bluetooth_disabled";
        if (root.hasConnectedDevice)
            return "bluetooth_connected";
        return "bluetooth";
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
}
