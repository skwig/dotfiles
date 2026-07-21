import QtQuick
import Quickshell.Services.UPower

Item {
    id: root

    required property Theme theme
    property bool hideWhenUnavailable: false

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryAvailable: battery && battery.ready && battery.isLaptopBattery
    readonly property int percentage: batteryAvailable ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: batteryAvailable && battery.state === UPowerDeviceState.Charging
    readonly property bool pendingCharge: batteryAvailable && battery.state === UPowerDeviceState.PendingCharge
    readonly property bool fullyCharged: batteryAvailable && battery.state === UPowerDeviceState.FullyCharged
    readonly property bool low: batteryAvailable && percentage <= 20 && !charging && !pendingCharge

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    visible: !hideWhenUnavailable || batteryAvailable
    implicitWidth: visible ? content.implicitWidth + 20 : 0
    implicitHeight: content.implicitHeight + 10

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

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryIcon()
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryAvailable ? root.percentage + "%" : "--%"
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
            }
        }
    }
}
