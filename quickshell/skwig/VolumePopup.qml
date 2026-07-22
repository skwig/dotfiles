import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

PopupWindow {
    id: root

    required property Theme theme
    property Item anchorItem: null

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool hasAudio: !!sink?.audio
    readonly property bool hasInput: !!source?.audio
    readonly property real volume: hasAudio ? sink.audio.volume : 0
    readonly property real inputVolume: hasInput ? source.audio.volume : 0
    readonly property bool muted: hasAudio && sink.audio.muted
    readonly property bool inputMuted: hasInput && source.audio.muted
    property double lastVolumeTestSound: 0
    readonly property int scrollbarWidth: 14
    readonly property var outputDevices: Pipewire.nodes.values.filter(node => {
        return node?.audio && node.isSink && !node.isStream;
    })
    readonly property var inputDevices: Pipewire.nodes.values.filter(node => {
        return node?.audio && !node.isSink && !node.isStream;
    })
    readonly property var appStreams: Pipewire.nodes.values.filter(node => {
        return node?.audio && node.isSink && node.isStream && !root.isVolumeTestStream(node);
    })
    readonly property var inputStreams: Pipewire.nodes.values.filter(node => {
        return node?.audio && !node.isSink && node.isStream && !root.isVolumeTestStream(node);
    })

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 340
    implicitHeight: content.implicitHeight + 20
    visible: false
    grabFocus: true
    color: "transparent"

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    PwObjectTracker {
        objects: root.source ? [root.source] : []
    }

    PwObjectTracker {
        objects: root.outputDevices.concat(root.inputDevices).concat(root.appStreams).concat(root.inputStreams)
    }

    function nodeName(node) {
        return node?.nickname || node?.description || node?.name || "Unknown";
    }

    function streamName(node) {
        var app = node && node.properties ? node.properties["application.name"] : "";
        var media = node && node.properties ? node.properties["media.name"] : "";
        app = app || node?.description || node?.name || "Unknown app";
        return media ? app + " - " + media : app;
    }

    function volumeIcon(value, muted) {
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

    Rectangle {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        implicitHeight: column.implicitHeight + 24
        color: Qt.rgba(0, 0, 0, 0.8)
        radius: root.theme.radius

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: root.hasAudio ? "Volume " + Math.round(root.volume * 100) + "%" : "No audio output"
                color: root.theme.fontColor
                font: root.theme.font
                elide: Text.ElideRight
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10
                enabled: root.hasAudio
                opacity: root.hasAudio ? 1 : 0.4

                Rectangle {
                    width: 34
                    height: 34
                    radius: root.theme.radius
                    color: muteHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: root.volumeIcon(root.volume, root.muted)
                        color: root.theme.fontColor
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize
                    }

                    HoverHandler {
                        id: muteHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.hasAudio)
                            root.sink.audio.muted = !root.sink.audio.muted
                    }
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

            ComboBox {
                anchors.left: parent.left
                anchors.right: parent.right
                model: root.outputDevices.map(node => {
                    return root.nodeName(node);
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

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: root.hasInput ? "Microphone " + Math.round(root.inputVolume * 100) + "%" : "No audio input"
                color: root.theme.fontColor
                font: root.theme.font
                elide: Text.ElideRight
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10
                enabled: root.hasInput
                opacity: root.hasInput ? 1 : 0.4

                Rectangle {
                    width: 34
                    height: 34
                    radius: root.theme.radius
                    color: inputMuteHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: root.inputIcon(root.inputMuted)
                        color: root.theme.fontColor
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize
                    }

                    HoverHandler {
                        id: inputMuteHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.hasInput)
                            root.source.audio.muted = !root.source.audio.muted
                    }
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

            ComboBox {
                anchors.left: parent.left
                anchors.right: parent.right
                model: root.inputDevices.map(node => {
                    return root.nodeName(node);
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

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: "Applications"
                color: Qt.rgba(1, 1, 1, 0.6)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
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
                        color: Qt.rgba(1, 1, 1, 0.45)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                    }

                    Row {
                        anchors.fill: parent
                        visible: streamRow.hasStream
                        spacing: 8

                        Rectangle {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            radius: root.theme.radius
                            color: streamMuteHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: root.volumeIcon(streamRow.modelData?.audio?.volume ?? 0, streamRow.modelData?.audio?.muted ?? false)
                                color: root.theme.fontColor
                                font.family: root.theme.font.family
                                font.pixelSize: root.theme.font.pixelSize - 2
                            }

                            HoverHandler {
                                id: streamMuteHover
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: streamRow.modelData.audio.muted = !streamRow.modelData.audio.muted
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 36
                            spacing: 2

                            Row {
                                width: parent.width

                                Text {
                                    width: parent.width - percentText.width - 8
                                    text: root.streamName(streamRow.modelData)
                                    color: root.theme.fontColor
                                    font.family: root.theme.font.family
                                    font.pixelSize: root.theme.font.pixelSize - 2
                                    elide: Text.ElideRight
                                }

                                Text {
                                    id: percentText
                                    text: Math.round((streamRow.modelData?.audio?.volume ?? 0) * 100) + "%"
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.family: root.theme.font.family
                                    font.pixelSize: root.theme.font.pixelSize - 2
                                }
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

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: "Input applications"
                color: Qt.rgba(1, 1, 1, 0.6)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
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
                        color: Qt.rgba(1, 1, 1, 0.45)
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
                    }

                    Row {
                        anchors.fill: parent
                        visible: inputStreamRow.hasStream
                        spacing: 8

                        Rectangle {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            radius: root.theme.radius
                            color: inputStreamMuteHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: root.inputIcon(inputStreamRow.modelData?.audio?.muted ?? false)
                                color: root.theme.fontColor
                                font.family: root.theme.font.family
                                font.pixelSize: root.theme.font.pixelSize - 2
                            }

                            HoverHandler {
                                id: inputStreamMuteHover
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: inputStreamRow.modelData.audio.muted = !inputStreamRow.modelData.audio.muted
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 36
                            spacing: 2

                            Row {
                                width: parent.width

                                Text {
                                    width: parent.width - inputPercentText.width - 8
                                    text: root.streamName(inputStreamRow.modelData)
                                    color: root.theme.fontColor
                                    font.family: root.theme.font.family
                                    font.pixelSize: root.theme.font.pixelSize - 2
                                    elide: Text.ElideRight
                                }

                                Text {
                                    id: inputPercentText
                                    text: Math.round((inputStreamRow.modelData?.audio?.volume ?? 0) * 100) + "%"
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.family: root.theme.font.family
                                    font.pixelSize: root.theme.font.pixelSize - 2
                                }
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
