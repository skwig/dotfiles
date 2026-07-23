import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Networking
import ".." as Root
import "../components" as Components
import "../services" as Services

PopupWindow {
    id: root

    required property Root.Theme theme
    required property Services.NetworkService networkService
    property Item anchorItem: null

    readonly property var wifiDevice: networkService.wifiDevice
    readonly property var networks: networkService.networks
    readonly property var connectedWifi: networkService.connectedWifi
    readonly property bool wifiEnabled: networkService.wifiEnabled
    readonly property bool scanning: networkService.scanning
    readonly property string currentSsid: networkService.currentSsid
    readonly property string ethernetDevice: networkService.ethernetDevice
    readonly property string ethernetConnection: networkService.ethernetConnection
    readonly property string ethernetSpeed: networkService.ethernetSpeed
    property var passwordNetwork: null
    property string failureMessage: ""
    readonly property int scrollbarWidth: 14

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    visible: false
    grabFocus: true
    color: "transparent"

    Connections {
        target: root.passwordNetwork

        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets && root.networkService.hasPasswordSecurity(root.passwordNetwork)) {
                root.failureMessage = "Password required";
            } else {
                root.passwordNetwork = null;
                root.failureMessage = ConnectionFailReason.toString(reason);
            }
        }
    }

    function connectNetwork(network, password) {
        if (!network || !root.wifiEnabled)
            return;

        root.failureMessage = "";
        root.passwordNetwork = network;

        if (password && password.length > 0 && root.networkService.hasPasswordSecurity(network)) {
            network.connectWithPsk(password);
        } else {
            network.connect();
        }
    }

    function disconnectNetwork(network) {
        if (network) {
            network.disconnect();
            root.passwordNetwork = null;
            root.failureMessage = "";
        }
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

            Components.MaterialCard {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                highlighted: root.wifiEnabled
                implicitHeight: headerRow.implicitHeight + contentPadding * 2

                Row {
                    id: headerRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.theme.spacingS

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        text: root.wifiEnabled ? "wifi" : "wifi_off"
                        color: root.wifiEnabled ? root.theme.primary : root.theme.muted
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.iconSize
                    }

                    Column {
                        width: parent.width - 112
                        spacing: 2

                        Text {
                            width: parent.width
                            text: root.currentSsid.length > 0 ? root.currentSsid : root.wifiEnabled ? "No internet" : "Wi-Fi off"
                            color: root.theme.onSurface
                            font: root.theme.font
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: root.scanning ? "Scanning" : "Network"
                            color: root.theme.muted
                            font: root.theme.fontSmall
                        }
                    }

                    Components.MaterialIconButton {
                        theme: root.theme
                        iconName: root.wifiEnabled ? "wifi_off" : "wifi"
                        label: root.wifiEnabled ? "Off" : "On"
                        selected: root.wifiEnabled
                        opacity: root.networkService.wifiHardwareEnabled ? 1 : 0.38
                        enabled: root.networkService.wifiHardwareEnabled
                        onClicked: root.networkService.setWifiEnabled(!root.networkService.wifiEnabled)
                    }

                    Components.MaterialIconButton {
                        theme: root.theme
                        iconName: "refresh"
                        label: root.scanning ? "..." : "Scan"
                        opacity: root.wifiEnabled && !!root.wifiDevice && !root.scanning ? 1 : 0.38
                        enabled: root.wifiEnabled && !!root.wifiDevice && !root.scanning
                        onClicked: root.wifiDevice.scannerEnabled = true
                    }
                }
            }

            Components.MaterialCard {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.ethernetDevice.length > 0
                height: visible ? 54 : 0
                theme: root.theme
                contentPadding: root.theme.spacingS

                Row {
                    anchors.fill: parent
                    spacing: root.theme.spacingS

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        text: "lan"
                        color: root.theme.primary
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.iconSize
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 32
                        spacing: 1

                        Text {
                            width: parent.width
                            text: root.ethernetConnection.length > 0 ? root.ethernetConnection : root.ethernetDevice
                            color: root.theme.onSurface
                            font: root.theme.fontSmall
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: root.ethernetSpeed.length > 0 ? root.ethernetDevice + " - " + root.ethernetSpeed : root.ethernetDevice
                            color: root.theme.muted
                            font: root.theme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            ListView {
                id: networkList
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.min(contentHeight, 280)
                clip: true
                spacing: 6
                model: root.wifiEnabled && root.networks.length > 0 ? root.networks : [null]
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: networkList.contentHeight > networkList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: Item {
                    id: networkRow

                    required property var modelData
                    readonly property bool hasNetwork: !!modelData
                    readonly property bool saved: hasNetwork && modelData.known
                    readonly property bool needsPassword: hasNetwork && root.networkService.hasPasswordSecurity(modelData) && root.passwordNetwork === modelData && !modelData.connected

                    width: networkList.width - root.scrollbarWidth
                    implicitHeight: hasNetwork ? needsPassword ? 98 : 58 : 24

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !networkRow.hasNetwork
                        text: root.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                        color: root.theme.muted
                        font: root.theme.fontSmall
                    }

                    Components.MaterialCard {
                        anchors.fill: parent
                        visible: networkRow.hasNetwork
                        theme: root.theme
                        highlighted: networkRow.hasNetwork && networkRow.modelData.connected
                        interactive: true
                        contentPadding: root.theme.spacingS

                        Column {
                            anchors.fill: parent
                            spacing: 6

                            Row {
                                width: parent.width
                                height: 42
                                spacing: 8

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 24
                                    text: networkRow.hasNetwork && networkRow.modelData.security !== WifiSecurityType.Open ? "wifi_lock" : "wifi"
                                    color: networkRow.hasNetwork && networkRow.modelData.connected ? root.theme.primary : root.theme.onSurface
                                    font.family: root.theme.iconFontFamily
                                    font.pixelSize: root.theme.iconSize
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 80
                                    spacing: 1

                                    Text {
                                        width: parent.width
                                        text: networkRow.hasNetwork ? networkRow.modelData.name : ""
                                        color: root.theme.onSurface
                                        font: root.theme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: networkRow.hasNetwork ? root.networkService.networkDetails(networkRow.modelData) : ""
                                        color: root.theme.muted
                                        font: root.theme.fontTiny
                                    }
                                }

                                Components.MaterialIconButton {
                                    theme: root.theme
                                    iconName: networkRow.hasNetwork && networkRow.modelData.connected ? "link_off" : "login"
                                    label: networkRow.hasNetwork && networkRow.modelData.connected ? "Drop" : "Join"
                                    filled: networkRow.hasNetwork && !networkRow.modelData.connected
                                    opacity: networkRow.hasNetwork && root.wifiEnabled ? 1 : 0.38
                                    enabled: networkRow.hasNetwork && root.wifiEnabled
                                    onClicked: {
                                        if (networkRow.modelData.connected) {
                                            root.disconnectNetwork(networkRow.modelData);
                                        } else if (root.networkService.hasPasswordSecurity(networkRow.modelData) && !networkRow.modelData.known) {
                                            root.passwordNetwork = root.passwordNetwork === networkRow.modelData ? null : networkRow.modelData;
                                            passwordField.forceActiveFocus();
                                        } else {
                                            root.connectNetwork(networkRow.modelData, "");
                                        }
                                    }
                                }
                            }

                            Row {
                                width: parent.width
                                height: 32
                                spacing: 8
                                visible: networkRow.needsPassword

                                TextField {
                                    id: passwordField
                                    width: parent.width - 68
                                    placeholderText: "Password"
                                    echoMode: TextInput.Password
                                    focus: networkRow.needsPassword
                                    selectByMouse: true
                                    onVisibleChanged: if (visible)
                                        forceActiveFocus()
                                    onAccepted: root.connectNetwork(networkRow.modelData, text)
                                }

                                Components.MaterialIconButton {
                                    theme: root.theme
                                    iconName: "login"
                                    label: "OK"
                                    filled: true
                                    onClicked: root.connectNetwork(networkRow.modelData, passwordField.text)
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.failureMessage.length > 0
                height: visible ? implicitHeight : 0
                text: root.failureMessage
                color: root.theme.error
                font: root.theme.fontTiny
                elide: Text.ElideRight
            }
        }
    }
}
