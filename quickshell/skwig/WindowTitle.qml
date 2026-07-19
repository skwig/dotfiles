import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: windowTitle

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: label.implicitWidth + 20

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
        color: Qt.rgba(1, 1, 1, 0.7)
        font.pixelSize: 12
        elide: Text.ElideRight
        width: 200
    }
}
