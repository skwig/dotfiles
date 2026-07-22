import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool hasAudio: !!sink?.audio
    readonly property bool hasInput: !!source?.audio
    readonly property real volume: hasAudio ? sink.audio.volume : 0
    readonly property real inputVolume: hasInput ? source.audio.volume : 0
    readonly property bool muted: hasAudio && sink.audio.muted
    readonly property bool inputMuted: hasInput && source.audio.muted
    readonly property var outputDevices: Pipewire.nodes.values.filter(node => node?.audio && node.isSink && !node.isStream)
    readonly property var inputDevices: Pipewire.nodes.values.filter(node => node?.audio && !node.isSink && !node.isStream)
    readonly property var appStreams: Pipewire.nodes.values.filter(node => node?.audio && node.isSink && node.isStream && !root.isVolumeTestStream(node))
    readonly property var inputStreams: Pipewire.nodes.values.filter(node => node?.audio && !node.isSink && node.isStream && !root.isVolumeTestStream(node))

    PwObjectTracker {
        objects: [root.sink, root.source].filter(node => !!node)
    }

    PwObjectTracker {
        objects: root.outputDevices.concat(root.inputDevices).concat(root.appStreams).concat(root.inputStreams)
    }

    function nodeName(node, fallback) {
        return node?.nickname || node?.description || node?.name || fallback || "Unknown";
    }

    function streamName(node) {
        var app = node && node.properties ? node.properties["application.name"] : "";
        var media = node && node.properties ? node.properties["media.name"] : "";
        app = app || node?.description || node?.name || "Unknown app";
        return media ? app + " - " + media : app;
    }

    function volumeIcon(value, muted, available) {
        if (available === false)
            return "󰟎";
        if (muted)
            return "󰖁";
        if (value >= 0.6)
            return "󰕾";
        if (value >= 0.3)
            return "󰖀";
        return "󰕿";
    }

    function inputIcon(muted) {
        return muted ? "󰍭" : "󰍬";
    }

    function isVolumeTestStream(node) {
        return node?.name === "pw-play" || node?.description === "pw-play";
    }
}
