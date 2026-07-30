import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import qs.Common
import qs.DankCommon.Widgets

PopupWindow {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool hasAdapter: adapter !== null
    readonly property bool adapterEnabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    property var devicesBeingPaired: new Set()

    implicitWidth: 380
    implicitHeight: Math.min(600, contentColumn.implicitHeight + Theme.spacingL * 2)

    color: "transparent"

    onVisibleChanged: {
        if (!visible) closeTransientSurfaces();
    }

    Keys.onPressed: event => {
        if (event.key !== Qt.Key_Escape) return;
        if (contextMenu.visible) {
            contextMenu.close();
            event.accepted = true;
            return;
        }
        root.visible = false;
        event.accepted = true;
    }

    function closeTransientSurfaces() {
        if (contextMenu.visible) contextMenu.close();
    }

    function isDeviceBeingPaired(deviceAddress) {
        return devicesBeingPaired.has(deviceAddress);
    }

    function handlePairDevice(device) {
        if (!device) return;
        const addr = device.address;
        const set = devicesBeingPaired;
        set.add(addr);
        devicesBeingPairedChanged();
        device.pair();
        device.trusted = true;
        const checkInterval = setInterval(() => {
            if (device.paired || device.pairing === false) {
                clearInterval(checkInterval);
                set.delete(addr);
                devicesBeingPairedChanged();
            }
        }, 500);
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.spacingS
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainer, Theme.popupTransparency)
        border.color: Theme.outlineMedium
        border.width: Theme.layerOutlineWidth

        clip: true

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            Row {
                width: parent.width
                height: 40
                spacing: Theme.spacingS

                StyledText {
                    text: "Bluetooth"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 1; height: 1 }

                Rectangle {
                    id: toggleButton
                    width: 44
                    height: 26
                    radius: 13
                    color: adapterEnabled ? Theme.primary : Theme.surfaceContainerHighest
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: Theme.shortDuration } }

                    Rectangle {
                        x: adapterEnabled ? parent.width - width - 2 : 2
                        y: 2
                        width: 22
                        height: 22
                        radius: 11
                        color: Theme.surfaceText

                        Behavior on x { NumberAnimation { duration: Theme.shortDuration; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (adapter) adapter.enabled = !adapter.enabled;
                        }
                    }
                }

                Rectangle {
                    id: scanBtn
                    width: scanLabel.implicitWidth + Theme.spacingL
                    height: 32
                    radius: 16
                    color: scanMouse.containsMouse && adapterEnabled
                        ? Theme.primaryHover
                        : "transparent"
                    border.width: 0
                    visible: adapterEnabled
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: discovering ? "sync" : "bluetooth_searching"
                            size: 16
                            color: adapterEnabled ? Theme.primary : Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                            RotationAnimator on rotation {
                                running: discovering
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 1500
                            }
                        }

                        StyledText {
                            id: scanLabel
                            text: discovering ? "Scanning" : "Scan"
                            color: adapterEnabled ? Theme.primary : Theme.surfaceVariantText
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankRipple {
                        id: scanRipple
                        cornerRadius: scanBtn.radius
                    }

                    MouseArea {
                        id: scanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse => scanRipple.trigger(mouse.x, mouse.y)
                        onClicked: {
                            if (adapter) adapter.discovering = !adapter.discovering;
                        }
                    }
                }
            }

            Item { width: 1; height: Theme.spacingXS }

            ScriptModel {
                id: pairedDevicesModel
                values: {
                    if (!adapter?.devices) return [];
                    return Array.from(adapter.devices.values).filter(d => d && (d.paired || d.trusted))
                        .sort((a, b) => {
                            if (a.connected !== b.connected) return a.connected ? -1 : 1;
                            return (b.signalStrength || 0) - (a.signalStrength || 0);
                        });
                }
            }

            StyledText {
                text: "PAIRED DEVICES"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                font.weight: Font.Medium
                visible: pairedRepeater.count > 0
            }

            Repeater {
                id: pairedRepeater
                model: pairedDevicesModel

                delegate: Rectangle {
                    id: pairedDelegate
                    required property var modelData

                    readonly property bool isConnecting: modelData.state === BluetoothDeviceState.Connecting
                    readonly property bool isConnected: modelData.connected
                    readonly property string deviceName: modelData.name || modelData.deviceName || "Unknown"

                    width: parent.width
                    height: 48
                    radius: Theme.cornerRadius
                    color: {
                        if (isConnecting) return Theme.warningHover;
                        if (devMouse.containsMouse) return Theme.primaryHoverLight;
                        return Theme.surfaceLight;
                    }
                    border.color: {
                        if (isConnecting) return Theme.warning;
                        if (isConnected) return Theme.primary;
                        return Theme.outlineLight;
                    }
                    border.width: (isConnecting || isConnected) ? 2 : 1

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        DankIcon {
                            name: getDeviceIcon(modelData)
                            size: Theme.iconSize - 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: isConnecting ? Theme.warning : isConnected ? Theme.primary : Theme.surfaceText
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 180

                            StyledText {
                                text: pairedDelegate.deviceName
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: isConnected ? Font.Medium : Font.Normal
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            StyledText {
                                text: isConnecting ? "Connecting..." : isConnected ? "Connected" : "Paired"
                                font.pixelSize: Theme.fontSizeSmall
                                color: isConnecting ? Theme.warning : Theme.surfaceVariantText
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: optionsBtn.left
                        anchors.rightMargin: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter
                        width: infoRow.width + Theme.spacingS * 2
                        height: 24
                        radius: 12
                        color: Theme.withAlpha(Theme.surfaceText, 0.05)

                        Row {
                            id: infoRow
                            anchors.centerIn: parent
                            spacing: 2

                            StyledText {
                                text: modelData.signalStrength > 0 ? modelData.signalStrength + "%" : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                visible: text.length > 0
                            }
                        }
                    }

                    DankIcon {
                        id: optionsBtn
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        name: "more_horiz"
                        size: 20
                        color: Theme.surfaceText

                        Rectangle {
                            anchors.fill: parent
                            radius: 14
                            color: optMouse.containsMouse ? Theme.surfaceHover : "transparent"
                        }

                        MouseArea {
                            id: optMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                contextMenu.currentDevice = pairedDelegate.modelData;
                                contextMenu.popup(optionsBtn, -contextMenu.width + optionsBtn.width + 4, optionsBtn.height + Theme.spacingXS);
                            }
                        }
                    }

                    DankRipple {
                        id: deviceRipple
                        cornerRadius: pairedDelegate.radius
                    }

                    MouseArea {
                        id: devMouse
                        anchors.fill: parent
                        anchors.rightMargin: 60
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse => deviceRipple.trigger(mouse.x, mouse.y)
                        onClicked: {
                            if (isConnected) {
                                modelData.disconnect();
                            } else {
                                modelData.trusted = true;
                                modelData.connect();
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outlineStrong
                visible: pairedRepeater.count > 0 && availableRepeater.count > 0
            }

            StyledText {
                text: "AVAILABLE DEVICES"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                font.weight: Font.Medium
                visible: discovering && availableRepeater.count > 0
            }

            Item {
                width: parent.width
                height: 60
                visible: discovering && availableRepeater.count === 0 && hasAdapter

                DankIcon {
                    anchors.centerIn: parent
                    name: "sync"
                    size: 24
                    color: Theme.onSurface_38
                    RotationAnimator on rotation {
                        running: parent.visible
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1500
                    }
                }
            }

            ScriptModel {
                id: availableDevicesModel
                values: {
                    if (!adapter?.discovering) return [];
                    const devices = Bluetooth.devices;
                    if (!devices) return [];
                    return Array.from(devices.values).filter(d => d && !d.paired && !d.pairing && !d.blocked && (d.signalStrength === undefined || d.signalStrength > 0));
                }
            }

            Repeater {
                id: availableRepeater
                model: availableDevicesModel

                delegate: Rectangle {
                    id: availableDelegate
                    required property var modelData

                    readonly property bool isBusy: isDeviceBeingPaired(modelData.address)
                    readonly property bool isInteractive: !isBusy
                    readonly property string deviceName: modelData.name || modelData.deviceName || "Unknown"

                    width: parent.width
                    height: 48
                    radius: Theme.cornerRadius
                    color: availMouse.containsMouse && isInteractive ? Theme.primaryHoverLight : Theme.surfaceLight
                    border.color: Theme.outlineLight
                    border.width: 1
                    opacity: isInteractive ? 1 : 0.6

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        DankIcon {
                            name: getDeviceIcon(modelData)
                            size: Theme.iconSize - 4
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 180

                            StyledText {
                                text: availableDelegate.deviceName
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            StyledText {
                                text: {
                                    if (isBusy) return "Pairing...";
                                    if (modelData.blocked) return "Blocked";
                                    return getSignalStrengthLabel(modelData);
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    StyledText {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                        text: isBusy ? "Pairing..." : "Pair"
                        font.pixelSize: Theme.fontSizeSmall
                        color: isInteractive ? Theme.primary : Theme.surfaceVariantText
                        font.weight: Font.Medium
                    }

                    DankRipple {
                        id: availableRipple
                        cornerRadius: availableDelegate.radius
                    }

                    MouseArea {
                        id: availMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: isInteractive ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: isInteractive
                        onPressed: mouse => availableRipple.trigger(mouse.x, mouse.y)
                        onClicked: handlePairDevice(availableDelegate.modelData)
                    }
                }
            }

            Item {
                width: parent.width
                height: 40
                visible: !hasAdapter

                StyledText {
                    anchors.centerIn: parent
                    text: "No Bluetooth adapter found"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }
            }

            Item {
                width: parent.width
                height: 40
                visible: hasAdapter && !adapterEnabled

                StyledText {
                    anchors.centerIn: parent
                    text: "Bluetooth is off"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }
            }
        }
    }

    Menu {
        id: contextMenu
        width: 160
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        property var currentDevice: null
        readonly property bool hasDevice: currentDevice !== null
        readonly property bool deviceConnected: currentDevice?.connected ?? false

        background: Rectangle {
            color: Theme.withAlpha(Theme.surfaceContainer, Theme.popupTransparency)
            radius: Theme.cornerRadius
            border.color: Theme.outlineMedium
            border.width: Theme.layerOutlineWidth
        }

        MenuItem {
            height: 32
            contentItem: StyledText {
                text: contextMenu.deviceConnected ? "Disconnect" : "Connect"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                leftPadding: Theme.spacingS
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.hovered ? Theme.primaryHoverLight : "transparent"
                radius: Theme.cornerRadius / 2
            }
            onTriggered: {
                if (!contextMenu.hasDevice) return;
                if (contextMenu.deviceConnected) {
                    contextMenu.currentDevice.disconnect();
                } else {
                    contextMenu.currentDevice.trusted = true;
                    contextMenu.currentDevice.connect();
                }
            }
        }

        MenuItem {
            height: 32
            contentItem: StyledText {
                text: contextMenu.currentDevice?.trusted ? "Untrust" : "Trust"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                leftPadding: Theme.spacingS
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.hovered ? Theme.primaryHoverLight : "transparent"
                radius: Theme.cornerRadius / 2
            }
            onTriggered: {
                if (!contextMenu.hasDevice) return;
                contextMenu.currentDevice.trusted = !contextMenu.currentDevice.trusted;
            }
        }

        MenuItem {
            height: 32
            contentItem: StyledText {
                text: "Forget Device"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.error
                leftPadding: Theme.spacingS
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.hovered ? Theme.errorHover : "transparent"
                radius: Theme.cornerRadius / 2
            }
            onTriggered: {
                if (!contextMenu.hasDevice) return;
                contextMenu.currentDevice.forget();
            }
        }
    }

    function getDeviceIcon(device) {
        if (!device) return "bluetooth";
        const name = (device.name || device.deviceName || "").toLowerCase();
        const icon = (device.icon || "").toLowerCase();
        if (["headset","audio","headphone","airpod","arctis"].some(k => icon.includes(k) || name.includes(k))) return "headset";
        if (icon.includes("mouse") || name.includes("mouse")) return "mouse";
        if (icon.includes("keyboard") || name.includes("keyboard")) return "keyboard";
        if (["phone","iphone","android","samsung"].some(k => icon.includes(k) || name.includes(k))) return "smartphone";
        if (icon.includes("watch") || name.includes("watch")) return "watch";
        if (icon.includes("speaker") || name.includes("speaker")) return "speaker";
        if (icon.includes("display") || name.includes("tv")) return "tv";
        return "bluetooth";
    }

    function getSignalStrengthLabel(device) {
        if (!device || device.signalStrength === undefined || device.signalStrength <= 0) return "Unknown";
        const s = device.signalStrength;
        if (s >= 80) return "Excellent";
        if (s >= 60) return "Good";
        if (s >= 40) return "Fair";
        if (s >= 20) return "Poor";
        return "Very Poor";
    }
}
