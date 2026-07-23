import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".." as Root
import "../components" as Components
import "../services" as Services

PopupWindow {
    id: root

    required property Root.Theme theme
    required property Services.AudioService audioService
    property Item anchorItem: null

    readonly property var sink: audioService.sink
    readonly property var source: audioService.source
    readonly property bool hasAudio: audioService.hasAudio
    readonly property bool hasInput: audioService.hasInput
    readonly property real volume: audioService.volume
    readonly property real inputVolume: audioService.inputVolume
    readonly property bool muted: audioService.muted
    readonly property bool inputMuted: audioService.inputMuted
    property double lastVolumeTestSound: 0
    readonly property int scrollbarWidth: 14
    readonly property var outputDevices: audioService.outputDevices
    readonly property var inputDevices: audioService.inputDevices
    readonly property var appStreams: audioService.appStreams
    readonly property var inputStreams: audioService.inputStreams

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 340
    implicitHeight: content.implicitHeight + 20
    visible: false
    grabFocus: true
    color: "transparent"

    function playVolumeTestSound() {
        var now = Date.now();
        if (now - root.lastVolumeTestSound < 50)
            return;
        root.lastVolumeTestSound = now;

        if (!volumeTestProcess.running)
            volumeTestProcess.running = true;
    }

    Process {
        id: volumeTestProcess
        running: false
        command: ["pw-play", "/run/current-system/sw/share/sounds/freedesktop/stereo/audio-volume-change.oga"]
    }

    Components.MaterialPopupSurface {
        id: content
        theme: root.theme
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        contentPadding: root.theme.spacingM
        implicitHeight: column.implicitHeight + contentPadding * 2

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 10

            Components.MaterialSectionLabel {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                text: root.hasAudio ? "Volume " + Math.round(root.volume * 100) + "%" : "No audio output"
                elide: Text.ElideRight
            }

            Components.MaterialCard {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                highlighted: root.hasAudio && !root.muted
                opacity: root.hasAudio ? 1 : 0.4
                implicitHeight: outputColumn.implicitHeight + contentPadding * 2
                enabled: root.hasAudio

                Column {
                    id: outputColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.theme.spacingS

                    Row {
                        width: parent.width
                        spacing: root.theme.spacingS

                        Components.MaterialIconButton {
                            theme: root.theme
                            iconName: root.muted || !root.hasAudio ? "volume_off" : "volume_up"
                            selected: root.hasAudio && !root.muted
                            onClicked: if (root.hasAudio)
                                root.sink.audio.muted = !root.sink.audio.muted
                        }

                        Slider {
                            width: parent.width - 44
                            from: 0
                            to: 1
                            value: root.volume
                            enabled: root.hasAudio
                            onMoved: if (root.hasAudio) {
                                root.sink.audio.volume = value;
                                root.playVolumeTestSound();
                            }
                        }
                    }

                    Components.MaterialProgressBar {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        theme: root.theme
                        value: root.volume
                        muted: root.muted || !root.hasAudio
                    }
                }
            }

            ComboBox {
                anchors.left: parent.left
                anchors.right: parent.right
                model: root.outputDevices.map(node => {
                    return root.audioService.nodeName(node);
                })
                currentIndex: root.outputDevices.findIndex(node => {
                    return node?.id === root.sink?.id;
                })
                enabled: root.outputDevices.length > 0
                onActivated: index => {
                    if (index >= 0 && index < root.outputDevices.length)
                        Pipewire.preferredDefaultAudioSink = root.outputDevices[index];
                }
            }

            Components.MaterialSectionLabel {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                text: root.hasInput ? "Microphone " + Math.round(root.inputVolume * 100) + "%" : "No audio input"
                elide: Text.ElideRight
            }

            Components.MaterialCard {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                highlighted: root.hasInput && !root.inputMuted
                opacity: root.hasInput ? 1 : 0.4
                implicitHeight: inputColumn.implicitHeight + contentPadding * 2
                enabled: root.hasInput

                Column {
                    id: inputColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.theme.spacingS

                    Row {
                        width: parent.width
                        spacing: root.theme.spacingS

                        Components.MaterialIconButton {
                            theme: root.theme
                            iconName: root.inputMuted || !root.hasInput ? "mic_off" : "mic"
                            selected: root.hasInput && !root.inputMuted
                            onClicked: if (root.hasInput)
                                root.source.audio.muted = !root.source.audio.muted
                        }

                        Slider {
                            width: parent.width - 44
                            from: 0
                            to: 1
                            value: root.inputVolume
                            enabled: root.hasInput
                            onMoved: if (root.hasInput)
                                root.source.audio.volume = value
                        }
                    }

                    Components.MaterialProgressBar {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        theme: root.theme
                        value: root.inputVolume
                        muted: root.inputMuted || !root.hasInput
                    }
                }
            }

            ComboBox {
                anchors.left: parent.left
                anchors.right: parent.right
                model: root.inputDevices.map(node => {
                    return root.audioService.nodeName(node);
                })
                currentIndex: root.inputDevices.findIndex(node => {
                    return node?.id === root.source?.id;
                })
                enabled: root.inputDevices.length > 0
                onActivated: index => {
                    if (index >= 0 && index < root.inputDevices.length)
                        Pipewire.preferredDefaultAudioSource = root.inputDevices[index];
                }
            }

            Components.MaterialSectionLabel {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                text: "Applications"
            }

            ListView {
                id: appStreamList
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.min(contentHeight, 160)
                clip: true
                spacing: 6
                model: root.appStreams.length > 0 ? root.appStreams : [null]
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: appStreamList.contentHeight > appStreamList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: Item {
                    id: streamRow

                    required property var modelData
                    readonly property bool hasStream: !!modelData?.audio

                    width: appStreamList.width - root.scrollbarWidth
                    implicitHeight: hasStream ? 48 : 24

                    PwObjectTracker {
                        objects: streamRow.hasStream ? [streamRow.modelData] : []
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !streamRow.hasStream
                        text: "No apps playing audio"
                        color: root.theme.muted
                        font: root.theme.fontSmall
                    }

                    Components.MaterialCard {
                        anchors.fill: parent
                        visible: streamRow.hasStream
                        theme: root.theme
                        interactive: true
                        contentPadding: root.theme.spacingS

                        Row {
                            anchors.fill: parent
                            spacing: root.theme.spacingS

                            Components.MaterialIconButton {
                                theme: root.theme
                                iconName: streamRow.modelData?.audio?.muted ?? false ? "volume_off" : "speaker"
                                onClicked: streamRow.modelData.audio.muted = !streamRow.modelData.audio.muted
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 44
                                spacing: 2

                                Row {
                                    width: parent.width

                                    Text {
                                        width: parent.width - percentText.width - 8
                                        text: root.audioService.streamName(streamRow.modelData)
                                        color: root.theme.onSurface
                                        font: root.theme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: percentText
                                        text: Math.round((streamRow.modelData?.audio?.volume ?? 0) * 100) + "%"
                                        color: root.theme.muted
                                        font: root.theme.fontSmall
                                    }
                                }

                                Components.MaterialProgressBar {
                                    width: parent.width
                                    theme: root.theme
                                    value: streamRow.modelData?.audio?.volume ?? 0
                                    muted: streamRow.modelData?.audio?.muted ?? true
                                }

                                Slider {
                                    width: parent.width
                                    from: 0
                                    to: 1
                                    value: streamRow.modelData?.audio?.volume ?? 0
                                    enabled: !(streamRow.modelData?.audio?.muted ?? true)
                                    onMoved: streamRow.modelData.audio.volume = value
                                }
                            }
                        }
                    }
                }
            }

            Components.MaterialSectionLabel {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                text: "Input applications"
            }

            ListView {
                id: inputStreamList
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.min(contentHeight, 160)
                clip: true
                spacing: 6
                model: root.inputStreams.length > 0 ? root.inputStreams : [null]
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: inputStreamList.contentHeight > inputStreamList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: Item {
                    id: inputStreamRow

                    required property var modelData
                    readonly property bool hasStream: !!modelData?.audio

                    width: inputStreamList.width - root.scrollbarWidth
                    implicitHeight: hasStream ? 48 : 24

                    PwObjectTracker {
                        objects: inputStreamRow.hasStream ? [inputStreamRow.modelData] : []
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !inputStreamRow.hasStream
                        text: "No apps recording audio"
                        color: root.theme.muted
                        font: root.theme.fontSmall
                    }

                    Components.MaterialCard {
                        anchors.fill: parent
                        visible: inputStreamRow.hasStream
                        theme: root.theme
                        interactive: true
                        contentPadding: root.theme.spacingS

                        Row {
                            anchors.fill: parent
                            spacing: root.theme.spacingS

                            Components.MaterialIconButton {
                                theme: root.theme
                                iconName: inputStreamRow.modelData?.audio?.muted ?? false ? "mic_off" : "graphic_eq"
                                onClicked: inputStreamRow.modelData.audio.muted = !inputStreamRow.modelData.audio.muted
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 44
                                spacing: 2

                                Row {
                                    width: parent.width

                                    Text {
                                        width: parent.width - inputPercentText.width - 8
                                        text: root.audioService.streamName(inputStreamRow.modelData)
                                        color: root.theme.onSurface
                                        font: root.theme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: inputPercentText
                                        text: Math.round((inputStreamRow.modelData?.audio?.volume ?? 0) * 100) + "%"
                                        color: root.theme.muted
                                        font: root.theme.fontSmall
                                    }
                                }

                                Components.MaterialProgressBar {
                                    width: parent.width
                                    theme: root.theme
                                    value: inputStreamRow.modelData?.audio?.volume ?? 0
                                    muted: inputStreamRow.modelData?.audio?.muted ?? true
                                }

                                Slider {
                                    width: parent.width
                                    from: 0
                                    to: 1
                                    value: inputStreamRow.modelData?.audio?.volume ?? 0
                                    enabled: !(inputStreamRow.modelData?.audio?.muted ?? true)
                                    onMoved: inputStreamRow.modelData.audio.volume = value
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
