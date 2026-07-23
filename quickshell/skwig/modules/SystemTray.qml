import QtQuick
import Quickshell.Services.SystemTray as Tray
import ".." as Root

Item {
    id: root

    required property Root.Theme theme
    property bool hideWhenEmpty: false

    readonly property var items: Tray.SystemTray.items.values
    readonly property bool hasItems: items.length > 0

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    visible: !hideWhenEmpty || hasItems
    implicitWidth: visible ? label.implicitWidth + 20 : 0
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
            text: "apps"
            color: root.theme.onSurface
            font.family: root.theme.iconFontFamily
            font.pixelSize: root.theme.iconSizeSmall
        }
    }
}
