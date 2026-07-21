import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower

PopupWindow {
    id: root

    required property Theme theme
    required property Item anchorItem
    readonly property var battery: UPower.displayDevice
    readonly property bool batteryReady: !!battery && battery.ready
    readonly property bool batteryAvailable: batteryReady && battery.isLaptopBattery
    readonly property int percentage: batteryAvailable ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: batteryAvailable && battery.state === UPowerDeviceState.Charging
    readonly property bool pendingCharge: batteryAvailable && battery.state === UPowerDeviceState.PendingCharge
    readonly property bool fullyCharged: batteryAvailable && battery.state === UPowerDeviceState.FullyCharged
    readonly property bool low: batteryAvailable && percentage <= 20 && !charging && !pendingCharge

    anchor.item: anchorItem
    anchor.rect.x: anchorItem.width / 2 - implicitWidth / 2
    anchor.rect.y: anchorItem.height + 4
    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    visible: false
    color: "transparent"

    function batteryIcon() {
        if (!root.batteryAvailable)
            return "󰂑";
        if (root.charging || root.pendingCharge)
            return "󰂄";
        if (root.fullyCharged || root.percentage >= 95)
            return "󰁹";
        if (root.low)
            return "󰂃";
        if (root.percentage >= 80)
            return "󰂂";
        if (root.percentage >= 60)
            return "󰂀";
        if (root.percentage >= 40)
            return "󰁾";
        if (root.percentage >= 20)
            return "󰁻";
        return "󰁺";
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

    function profileLabel(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "Power Saver";
        case PowerProfile.Performance:
            return "Performance";
        default:
            return "Balanced";
        }
    }

    function profileIcon(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "󰌪";
        case PowerProfile.Performance:
            return "󰓅";
        default:
            return "󰾅";
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

    function profileSelected(profile) {
        return PowerProfiles.profile === profile;
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
                    text: root.batteryIcon()
                    color: root.theme.fontColor
                    font.family: root.theme.font.family
                    font.pixelSize: root.theme.font.pixelSize
                }

                Column {
                    width: parent.width - 34
                    spacing: 2

                    Text {
                        width: parent.width
                        text: "Battery"
                        color: root.theme.fontColor
                        font: root.theme.font
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.batteryAvailable ? root.percentage + "% - " + root.stateLabel(root.battery.state) : root.batteryReady ? "No battery found" : "Battery unavailable"
                        color: Qt.rgba(1, 1, 1, 0.55)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                        elide: Text.ElideRight
                    }
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
                text: "Details"
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                font.bold: true
            }

            DetailRow {
                theme: root.theme
                rowIcon: root.batteryIcon()
                label: "Charge"
                value: root.batteryAvailable ? root.percentage + "%" : root.batteryReady ? "No battery found" : "Unavailable"
            }

            DetailRow {
                theme: root.theme
                rowIcon: "󰔟"
                label: "State"
                value: root.batteryAvailable ? root.stateLabel(root.battery.state) : "Unavailable"
            }

            DetailRow {
                visible: root.batteryAvailable && (root.charging || root.pendingCharge) && root.battery.timeToFull > 0
                theme: root.theme
                rowIcon: "󰥔"
                label: "Time to full"
                value: root.formatTime(root.battery.timeToFull)
            }

            DetailRow {
                visible: root.batteryAvailable && !root.charging && !root.pendingCharge && root.battery.timeToEmpty > 0
                theme: root.theme
                rowIcon: "󰥔"
                label: "Time to empty"
                value: root.formatTime(root.battery.timeToEmpty)
            }

            DetailRow {
                visible: root.batteryAvailable && root.formatRate(root.battery.changeRate).length > 0
                theme: root.theme
                rowIcon: "󰚥"
                label: root.charging || root.pendingCharge ? "Charging" : "Discharging"
                value: root.formatRate(root.battery.changeRate)
            }

            DetailRow {
                visible: root.batteryAvailable && root.battery.healthSupported
                theme: root.theme
                rowIcon: "󰓎"
                label: "Health"
                value: Math.round(root.battery.healthPercentage) + "%"
            }

            DetailRow {
                visible: root.formatCapacity().length > 0
                theme: root.theme
                rowIcon: "󰁹"
                label: "Capacity"
                value: root.formatCapacity()
            }

            DetailRow {
                visible: root.batteryAvailable && ((root.battery.model || root.battery.nativePath || "").length > 0)
                theme: root.theme
                rowIcon: "󰋊"
                label: "Device"
                value: root.battery.model || root.battery.nativePath
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
                text: "Power Profile"
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                font.bold: true
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                ProfileButton {
                    width: (parent.width - 16) / 3
                    theme: root.theme
                    profile: PowerProfile.PowerSaver
                    selected: root.profileSelected(PowerProfile.PowerSaver)
                    label: "Power Saver"
                    profileIconText: root.profileIcon(PowerProfile.PowerSaver)
                    enabled: true
                    onSelectedProfile: PowerProfiles.profile = PowerProfile.PowerSaver
                }

                ProfileButton {
                    width: (parent.width - 16) / 3
                    theme: root.theme
                    profile: PowerProfile.Balanced
                    selected: root.profileSelected(PowerProfile.Balanced)
                    label: "Balanced"
                    profileIconText: root.profileIcon(PowerProfile.Balanced)
                    enabled: true
                    onSelectedProfile: PowerProfiles.profile = PowerProfile.Balanced
                }

                ProfileButton {
                    width: (parent.width - 16) / 3
                    theme: root.theme
                    profile: PowerProfile.Performance
                    selected: root.profileSelected(PowerProfile.Performance)
                    label: "Performance"
                    profileIconText: root.profileIcon(PowerProfile.Performance)
                    enabled: PowerProfiles.hasPerformanceProfile
                    onSelectedProfile: PowerProfiles.profile = PowerProfile.Performance
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: "Current: " + root.profileLabel(PowerProfiles.profile)
                color: Qt.rgba(1, 1, 1, 0.55)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: PowerProfiles.holds.length > 0
                text: PowerProfiles.holds.length + " active profile hold" + (PowerProfiles.holds.length === 1 ? "" : "s")
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                elide: Text.ElideRight
            }
        }
    }

    component DetailRow: Item {
        required property Theme theme
        property string rowIcon: ""
        property string label: ""
        property string value: ""

        anchors.left: parent.left
        anchors.right: parent.right
        height: 24

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            text: rowIcon
            color: theme.fontColor
            font.family: theme.font.family
            font.pixelSize: theme.font.pixelSize - 2
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            width: 126
            text: label
            color: Qt.rgba(1, 1, 1, 0.55)
            font.family: theme.font.family
            font.pixelSize: theme.font.pixelSize - 2
            elide: Text.ElideRight
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 166
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: value
            color: theme.fontColor
            font.family: theme.font.family
            font.pixelSize: theme.font.pixelSize - 2
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }

    component ProfileButton: Button {
        required property Theme theme
        property int profile
        property bool selected: false
        property string label: ""
        property string profileIconText: ""

        signal selectedProfile

        height: 34
        text: profileIconText + " " + label
        highlighted: selected
        onClicked: selectedProfile()
    }
}
