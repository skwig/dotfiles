import QtQuick
import Quickshell
import ".." as Root
import "../services" as Services

PanelWindow {
    id: root

    required property Root.Theme theme
    required property Services.AudioService audioService
    property ShellScreen targetScreen: null

    readonly property var sink: audioService.sink
    readonly property var source: audioService.source
    readonly property bool outputMode: mode === "output"
    readonly property bool hasNode: outputMode ? !!sink?.audio : !!source?.audio
    readonly property real currentVolume: outputMode ? (sink?.audio?.volume ?? 0) : (source?.audio?.volume ?? 0)
    readonly property bool currentMuted: outputMode ? (sink?.audio?.muted ?? false) : (source?.audio?.muted ?? false)
    readonly property string currentName: outputMode ? audioService.nodeName(sink, "Unknown output") : audioService.nodeName(source, "Unknown input")
    readonly property string currentIcon: outputMode ? audioService.volumeIcon(currentVolume, currentMuted, !!sink?.audio) : audioService.inputIcon(currentMuted)
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
