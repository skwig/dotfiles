import QtQuick
import QtQuick.Layouts
import Quickshell
import ".." as Root
import "../components" as Components
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
    readonly property string currentIcon: outputMode ? audioService.volumeSymbol(currentVolume, currentMuted, !!sink?.audio) : audioService.inputSymbol(currentMuted)
    readonly property real clampedVolume: Math.max(0, Math.min(1, currentVolume))

    property string mode: "output"
    property bool ready: false
    property bool showing: false

    anchors.top: true
    anchors.left: true
    screen: targetScreen
    margins.top: 12
    margins.left: 12
    exclusiveZone: 0
    implicitWidth: 320
    implicitHeight: 72
    visible: showing || exitTimer.running
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
        onTriggered: {
            root.showing = false;
            exitTimer.restart();
        }
    }

    Timer {
        id: exitTimer
        interval: root.theme.shortDuration
    }

    function showFor(nextMode) {
        if (!root.ready)
            return;
        root.mode = nextMode;
        root.showing = true;
        exitTimer.stop();
        hideTimer.restart();
    }

    Rectangle {
        id: container

        anchors.fill: parent
        radius: root.theme.radiusLarge
        color: root.theme.surfaceContainerHighest
        border.width: 1
        border.color: root.theme.outlineVariant
        opacity: root.showing ? 1 : 0
        scale: root.showing ? 1 : 0.94

        Behavior on opacity {
            NumberAnimation { duration: root.theme.shortDuration; easing.type: root.theme.emphasizedEasing }
        }

        Behavior on scale {
            NumberAnimation { duration: root.theme.shortDuration; easing.type: root.theme.emphasizedEasing }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: root.theme.spacingL
            spacing: root.theme.spacingM

            Text {
                Layout.preferredWidth: root.theme.iconSizeLarge
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.currentIcon
                color: root.currentMuted ? root.theme.muted : root.theme.primary
                font.family: root.theme.iconFontFamily
                font.pixelSize: root.theme.iconSize
            }

            Components.MaterialProgressBar {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                theme: root.theme
                value: root.clampedVolume
                muted: root.currentMuted
            }

            Text {
                text: root.currentMuted ? "Muted" : Math.round(root.currentVolume * 100) + "%"
                color: root.theme.onSurface
                font: root.theme.fontSmall
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 44
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
