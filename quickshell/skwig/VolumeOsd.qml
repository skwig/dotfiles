import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
    id: root

    required property Theme theme
    property ShellScreen targetScreen: null

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool outputMode: mode === "output"
    readonly property bool hasNode: outputMode ? !!sink?.audio : !!source?.audio
    readonly property real currentVolume: outputMode ? (sink?.audio?.volume ?? 0) : (source?.audio?.volume ?? 0)
    readonly property bool currentMuted: outputMode ? (sink?.audio?.muted ?? false) : (source?.audio?.muted ?? false)
    readonly property string currentName: outputMode ? nodeName(sink, "Unknown output") : nodeName(source, "Unknown input")
    readonly property string currentIcon: outputMode ? outputIcon() : inputIcon()
    readonly property real clampedVolume: Math.max(0, Math.min(1, currentVolume))

    property string mode: "output"
    property bool ready: false

    anchors.top: true
    anchors.left: true
    screen: targetScreen
    margins.top: 12
    margins.left: 12
    exclusiveZone: 0
    implicitWidth: 320
    implicitHeight: 72
    visible: false
    color: "transparent"
    mask: Region {}

    Component.onCompleted: ready = true

    PwObjectTracker {
        objects: [root.sink, root.source].filter(node => !!node)
    }

    Connections {
        target: root.sink?.audio ?? null

        function onVolumeChanged() {
            root.showFor("output");
        }

        function onMutedChanged() {
            root.showFor("output");
        }
    }

    Connections {
        target: root.source?.audio ?? null

        function onVolumeChanged() {
            root.showFor("input");
        }

        function onMutedChanged() {
            root.showFor("input");
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.visible = false
    }

    function showFor(nextMode) {
        if (!root.ready)
            return;
        root.mode = nextMode;
        root.visible = true;
        hideTimer.restart();
    }

    function nodeName(node, fallback) {
        return node?.nickname || node?.description || node?.name || fallback;
    }

    function outputIcon() {
        if (!root.sink?.audio)
            return "󰟎";
        if (root.currentMuted)
            return "󰖁";
        if (root.currentVolume >= 0.6)
            return "󰕾";
        if (root.currentVolume >= 0.3)
            return "󰖀";
        return "󰕿";
    }

    function inputIcon() {
        return root.currentMuted ? "󰍭" : "󰍬";
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: Qt.rgba(0, 0, 0, 0.8)

        Row {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Text {
                width: 36
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.currentIcon
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: 24
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                spacing: 6

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width - valueText.implicitWidth - parent.spacing
                        text: root.currentName
                        color: root.theme.fontColor
                        elide: Text.ElideRight
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 1
                    }

                    Text {
                        id: valueText
                        text: root.currentMuted ? "Muted" : Math.round(root.currentVolume * 100) + "%"
                        color: Qt.rgba(1, 1, 1, 0.65)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 3
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 8
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.18)

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * root.clampedVolume
                        radius: parent.radius
                        color: root.currentMuted ? Qt.rgba(1, 1, 1, 0.35) : root.theme.fontColor
                    }
                }
            }
        }
    }
}
