import QtQuick

Item {
    id: root

    required property Theme theme
    required property var bluetoothService

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
            text: root.bluetoothService.bluetoothIcon()
            color: root.theme.fontColor
            font.family: root.theme.font.family
            font.pixelSize: root.theme.font.pixelSize
        }
    }
}
