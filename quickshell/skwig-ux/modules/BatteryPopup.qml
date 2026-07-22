import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import ".." as Root
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
            return "󰌪";
        case PowerProfile.Performance:
            return "󰓅";
        default:
            return "󰾅";
        }
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
                    text: root.batteryService.batteryIcon()
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
                        text: root.batteryAvailable ? root.percentage + "% - " + root.batteryService.stateLabel(root.battery.state) : root.batteryReady ? "No battery found" : "Battery unavailable"
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
                rowIcon: root.batteryService.batteryIcon()
                label: "Charge"
                value: root.batteryAvailable ? root.percentage + "%" : root.batteryReady ? "No battery found" : "Unavailable"
            }

            DetailRow {
                theme: root.theme
                rowIcon: "󰔟"
                label: "State"
                value: root.batteryAvailable ? root.batteryService.stateLabel(root.battery.state) : "Unavailable"
            }

            DetailRow {
                visible: root.batteryAvailable && (root.charging || root.pendingCharge) && root.battery.timeToFull > 0
                theme: root.theme
                rowIcon: "󰥔"
                label: "Time to full"
                value: root.batteryService.formatTime(root.battery.timeToFull)
            }

            DetailRow {
                visible: root.batteryAvailable && !root.charging && !root.pendingCharge && root.battery.timeToEmpty > 0
                theme: root.theme
                rowIcon: "󰥔"
                label: "Time to empty"
                value: root.batteryService.formatTime(root.battery.timeToEmpty)
            }

            DetailRow {
                visible: root.batteryAvailable && root.batteryService.formatRate(root.battery.changeRate).length > 0
                theme: root.theme
                rowIcon: "󰚥"
                label: root.charging || root.pendingCharge ? "Charging" : "Discharging"
                value: root.batteryService.formatRate(root.battery.changeRate)
            }

            DetailRow {
                visible: root.batteryAvailable && root.battery.healthSupported
                theme: root.theme
                rowIcon: "󰓎"
                label: "Health"
                value: Math.round(root.battery.healthPercentage) + "%"
            }

            DetailRow {
                visible: root.batteryService.formatCapacity().length > 0
                theme: root.theme
                rowIcon: "󰁹"
                label: "Capacity"
                value: root.batteryService.formatCapacity()
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
        required property Root.Theme theme
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
