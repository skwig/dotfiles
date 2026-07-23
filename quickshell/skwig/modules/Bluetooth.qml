import QtQuick
import ".." as Root
import "../services" as Services

Item {
    id: root

    required property Root.Theme theme
    required property Services.BluetoothService bluetoothService

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 10

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

        Text {
            id: label
            anchors.centerIn: parent
            text: root.bluetoothService.bluetoothSymbol()
            color: root.theme.onSurface
            font.family: root.theme.iconFontFamily
            font.pixelSize: root.theme.iconSizeSmall
        }
    }
}
