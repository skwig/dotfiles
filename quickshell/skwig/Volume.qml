import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    required property Theme theme

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasAudio: !!sink?.audio
    readonly property bool isMuted: hasAudio && sink.audio.muted
    readonly property real volume: hasAudio ? sink.audio.volume : 0

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 10

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    function volumeIcon() {
        if (!root.hasAudio)
            return "󰟎";
        if (root.isMuted)
            return "󰖁";
        if (root.volume >= 0.6)
            return "󰕾";
        if (root.volume >= 0.3)
            return "󰖀";
        return "󰕿";
    }

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
            text: root.volumeIcon()
            color: root.theme.fontColor
            font.family: root.theme.font.family
            font.pixelSize: root.theme.font.pixelSize
        }
    }
}
