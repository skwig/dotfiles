import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: windowTitle

    required property Theme theme

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: label.implicitWidth + 20

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: {
            var toplevel = Hyprland.activeToplevel;
            if (toplevel && toplevel.workspace && toplevel.workspace === Hyprland.focusedWorkspace)
                return toplevel.title;
            return "Desktop";
        }
        color: theme.fontColor
        font: theme.font
        elide: Text.ElideRight
        width: 200
    }
}
