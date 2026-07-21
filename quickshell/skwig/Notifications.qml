import QtQuick

Item {
    id: root

    required property Theme theme
    property int count: 0

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: count > 0 ? icon.implicitWidth + countLabel.implicitWidth + 24 : icon.implicitWidth + 20
    implicitHeight: Math.max(icon.implicitHeight, countLabel.implicitHeight) + 10

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
            anchors.centerIn: parent
            spacing: 4

            Text {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                text: root.count > 0 ? "󰂚" : "󰂜"
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize
            }

            Text {
                id: countLabel
                anchors.verticalCenter: parent.verticalCenter
                visible: root.count > 0
                text: root.count > 99 ? "99+" : root.count.toString()
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 3
            }
        }
    }
}
