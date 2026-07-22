import Quickshell
import Quickshell.Hyprland
import QtQuick
import ".."

Row {
    id: workspaces

    required property int minCount
    required property Theme theme

    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Repeater {
        model: Math.max(workspaces.minCount, Hyprland.workspaces.values.length)

        Rectangle {
            id: workspace

            property int wsIndex: index + 1
            property var ws: {
                var vals = Hyprland.workspaces.values;
                for (var i = 0; i < vals.length; i++) {
                    if (vals[i].id === wsIndex)
                        return vals[i];
                }
                return null;
            }
            property bool isActive: ws && Hyprland.focusedWorkspace === ws
            property bool isOccupied: ws && ws.lastIpcObject && ws.lastIpcObject.windows > 0

            width: 22
            height: 38
            radius: workspaces.theme.radius
            color: hoverHandler.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

            Text {
                anchors.centerIn: parent
                text: workspace.wsIndex.toString()
                color: workspace.isActive ? workspaces.theme.fontColor : Qt.rgba(1, 1, 1, 0.4)
                font: workspaces.theme.font
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 2
                radius: 1
                color: workspaces.theme.fontColor
                visible: workspace.isActive
            }

            HoverHandler {
                id: hoverHandler
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (ws)
                        ws.activate();
                    else
                        Hyprland.dispatch("workspace " + wsIndex);
                }
            }
        }
    }
}
