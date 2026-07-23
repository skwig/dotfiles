import Quickshell
import Quickshell.Services.UPower

Scope {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryReady: !!battery && battery.ready
    readonly property bool batteryAvailable: batteryReady && battery.isLaptopBattery
    readonly property int percentage: batteryAvailable ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: batteryAvailable && battery.state === UPowerDeviceState.Charging
    readonly property bool pendingCharge: batteryAvailable && battery.state === UPowerDeviceState.PendingCharge
    readonly property bool fullyCharged: batteryAvailable && battery.state === UPowerDeviceState.FullyCharged
    readonly property bool low: batteryAvailable && percentage <= 20 && !charging && !pendingCharge

    function batterySymbol() {
        if (!root.batteryAvailable)
            return "battery_unknown";
        if (root.charging || root.pendingCharge)
            return "battery_charging_full";
        if (root.low)
            return "battery_alert";
        return root.percentage >= 95 ? "battery_full" : "battery_std";
    }

    function stateLabel(state) {
        switch (state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.PendingCharge:
            return "Pending charge";
        case UPowerDeviceState.PendingDischarge:
            return "Pending discharge";
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.Empty:
            return "Empty";
        default:
            return "Unknown";
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (hours > 0)
            return hours + "h " + minutes + "m";
        return minutes + "m";
    }

    function formatRate(rate) {
        if (!rate || rate <= 0.01)
            return "";
        return rate.toFixed(2) + " W";
    }

    function formatCapacity() {
        if (!root.batteryAvailable || root.battery.energy <= 0 || root.battery.energyCapacity <= 0)
            return "";
        return root.battery.energy.toFixed(1) + " / " + root.battery.energyCapacity.toFixed(1) + " Wh";
    }
}
