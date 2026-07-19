import Quickshell
import Quickshell.Hyprland
import QtQuick

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

            width: 20
            height: 20
            radius: 4
            color: isActive ? "#ffffff" : isOccupied ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.15)

            Text {
                anchors.centerIn: parent
                text: workspace.wsIndex.toString()
                color: workspace.isActive ? "#000000" : Qt.rgba(1, 1, 1, 0.5)
                font: workspaces.theme.font
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

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }
}
