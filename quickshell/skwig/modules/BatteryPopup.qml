import QtQuick
import Quickshell
import Quickshell.Services.UPower
import ".." as Root
import "../components" as Components
import "../services" as Services

PopupWindow {
    id: root

    required property Root.Theme theme
    required property Services.BatteryService batteryService
    property Item anchorItem: null
    readonly property var battery: batteryService.battery
    readonly property bool batteryReady: batteryService.batteryReady
    readonly property bool batteryAvailable: batteryService.batteryAvailable
    readonly property int percentage: batteryService.percentage
    readonly property bool charging: batteryService.charging
    readonly property bool pendingCharge: batteryService.pendingCharge
    readonly property bool fullyCharged: batteryService.fullyCharged
    readonly property bool low: batteryService.low

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0
    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    visible: false
    grabFocus: true
    color: "transparent"

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
            return "battery_saver";
        case PowerProfile.Performance:
            return "bolt";
        default:
            return "balance";
        }
    }

    function profileSelected(profile) {
        return PowerProfiles.profile === profile;
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

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    text: root.batteryService.batterySymbol()
                    color: root.theme.primary
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: root.theme.iconSize
                }

                Column {
                    width: parent.width - 34
                    spacing: 2

                    Text {
                        width: parent.width
                        text: "Battery"
                        color: root.theme.onSurface
                        font: root.theme.font
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.batteryAvailable ? root.percentage + "% - " + root.batteryService.stateLabel(root.battery.state) : root.batteryReady ? "No battery found" : "Battery unavailable"
                        color: root.theme.muted
                        font: root.theme.fontSmall
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.outlineVariant
            }

            Components.MaterialSectionLabel {
                theme: root.theme
                text: "Details"
                width: parent.width
            }

            DetailRow {
                theme: root.theme
                rowIcon: "battery_full"
                label: "Charge"
                value: root.batteryAvailable ? root.percentage + "%" : root.batteryReady ? "No battery found" : "Unavailable"
            }

            DetailRow {
                theme: root.theme
                rowIcon: "info"
                label: "State"
                value: root.batteryAvailable ? root.batteryService.stateLabel(root.battery.state) : "Unavailable"
            }

            DetailRow {
                visible: root.batteryAvailable && (root.charging || root.pendingCharge) && root.battery.timeToFull > 0
                theme: root.theme
                rowIcon: "schedule"
                label: "Time to full"
                value: root.batteryService.formatTime(root.battery.timeToFull)
            }

            DetailRow {
                visible: root.batteryAvailable && !root.charging && !root.pendingCharge && root.battery.timeToEmpty > 0
                theme: root.theme
                rowIcon: "schedule"
                label: "Time to empty"
                value: root.batteryService.formatTime(root.battery.timeToEmpty)
            }

            DetailRow {
                visible: root.batteryAvailable && root.batteryService.formatRate(root.battery.changeRate).length > 0
                theme: root.theme
                rowIcon: "bolt"
                label: root.charging || root.pendingCharge ? "Charging" : "Discharging"
                value: root.batteryService.formatRate(root.battery.changeRate)
            }

            DetailRow {
                visible: root.batteryAvailable && root.battery.healthSupported
                theme: root.theme
                rowIcon: "health_and_safety"
                label: "Health"
                value: Math.round(root.battery.healthPercentage) + "%"
            }

            DetailRow {
                visible: root.batteryService.formatCapacity().length > 0
                theme: root.theme
                rowIcon: "battery_full"
                label: "Capacity"
                value: root.batteryService.formatCapacity()
            }

            DetailRow {
                visible: root.batteryAvailable && ((root.battery.model || root.battery.nativePath || "").length > 0)
                theme: root.theme
                rowIcon: "devices"
                label: "Device"
                value: root.battery.model || root.battery.nativePath
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.outlineVariant
            }

            Components.MaterialSectionLabel {
                theme: root.theme
                text: "Power Profile"
                width: parent.width
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
                color: root.theme.muted
                font: root.theme.fontSmall
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: PowerProfiles.holds.length > 0
                text: PowerProfiles.holds.length + " active profile hold" + (PowerProfiles.holds.length === 1 ? "" : "s")
                color: root.theme.muted
                font: root.theme.fontTiny
                elide: Text.ElideRight
            }
        }
    }

    component DetailRow: Item {
        required property Root.Theme theme
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
            color: theme.primary
            font.family: theme.iconFontFamily
            font.pixelSize: theme.iconSizeSmall
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            width: 126
            text: label
            color: theme.muted
            font: theme.fontSmall
            elide: Text.ElideRight
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 166
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: value
            color: theme.onSurface
            font: theme.fontSmall
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }

    component ProfileButton: Rectangle {
        required property Root.Theme theme
        property int profile
        property bool selected: false
        property string label: ""
        property string profileIconText: ""

        signal selectedProfile

        height: 34
        radius: theme.radiusFull
        color: selected ? theme.primary : hover.hovered ? theme.surfaceContainerHighest : theme.surfaceVariant
        opacity: enabled ? 1 : 0.45

        Row {
            anchors.centerIn: parent
            spacing: theme.spacingS

            Text {
                text: profileIconText
                color: selected ? theme.onPrimary : theme.onSurface
                font.family: theme.iconFontFamily
                font.pixelSize: theme.iconSizeSmall
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: label
                color: selected ? theme.onPrimary : theme.onSurface
                font: theme.fontSmall
                verticalAlignment: Text.AlignVCenter
            }
        }

        HoverHandler {
            id: hover
            enabled: parent.enabled
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: selectedProfile()
        }
    }
}
