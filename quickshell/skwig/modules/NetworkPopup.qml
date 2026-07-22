import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Networking
import ".."

PopupWindow {
    id: root

    required property Theme theme
    required property var networkService
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

                Column {
                    width: parent.width - 108
                    spacing: 2

                    Text {
                        width: parent.width
                        text: root.currentSsid.length > 0 ? root.currentSsid : root.wifiEnabled ? "No internet" : "Wi-Fi off"
                        color: root.theme.fontColor
                        font: root.theme.font
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.scanning ? "Scanning" : "Network"
                        color: Qt.rgba(1, 1, 1, 0.55)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                    }
                }

                Button {
                    width: 48
                    text: root.wifiEnabled ? "Off" : "On"
                    enabled: root.networkService.wifiHardwareEnabled
                    onClicked: root.networkService.setWifiEnabled(!root.networkService.wifiEnabled)
                }

                Button {
                    width: 50
                    text: root.scanning ? "..." : "Scan"
                    enabled: root.wifiEnabled && !!root.wifiDevice && !root.scanning
                    onClicked: root.wifiDevice.scannerEnabled = true
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.ethernetDevice.length > 0
                height: visible ? 40 : 0
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    text: "󰈀"
                    color: root.theme.fontColor
                    font.family: root.theme.font.family
                    font.pixelSize: root.theme.font.pixelSize
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 32
                    spacing: 1

                    Text {
                        width: parent.width
                        text: root.ethernetConnection.length > 0 ? root.ethernetConnection : root.ethernetDevice
                        color: root.theme.fontColor
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.ethernetSpeed.length > 0 ? root.ethernetDevice + " - " + root.ethernetSpeed : root.ethernetDevice
                        color: Qt.rgba(1, 1, 1, 0.55)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 3
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.ethernetDevice.length > 0
                height: visible ? 1 : 0
                color: Qt.rgba(1, 1, 1, 0.15)
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
                    implicitHeight: hasNetwork ? needsPassword ? 82 : 44 : 24

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !networkRow.hasNetwork
                        text: root.wifiEnabled ? "No networks found" : "Wi-Fi is off"
                        color: Qt.rgba(1, 1, 1, 0.45)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                    }

                    Column {
                        anchors.fill: parent
                        visible: networkRow.hasNetwork
                        spacing: 6

                        Row {
                            width: parent.width
                            height: 38
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 24
                                text: networkRow.hasNetwork ? root.networkService.networkIcon(Math.round(networkRow.modelData.signalStrength * 100), networkRow.modelData.security !== WifiSecurityType.Open) : ""
                                color: root.theme.fontColor
                                font.family: root.theme.font.family
                                font.pixelSize: root.theme.font.pixelSize
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 92
                                spacing: 1

                                Text {
                                    width: parent.width
                                    text: networkRow.hasNetwork ? networkRow.modelData.name : ""
                                    color: root.theme.fontColor
                                    font.family: root.theme.font.family
                                    font.pixelSize: root.theme.font.pixelSize - 2
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: networkRow.hasNetwork ? root.networkService.networkDetails(networkRow.modelData) : ""
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.family: root.theme.font.family
                                    font.pixelSize: root.theme.font.pixelSize - 3
                                }
                            }

                            Button {
                                width: 60
                                text: networkRow.hasNetwork && networkRow.modelData.connected ? "Drop" : "Join"
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

                            Button {
                                width: 60
                                text: "OK"
                                onClicked: root.connectNetwork(networkRow.modelData, passwordField.text)
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
                color: Qt.rgba(1, 1, 1, 0.55)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
                elide: Text.ElideRight
            }
        }
    }
}
