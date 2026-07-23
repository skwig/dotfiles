import QtQuick
import ".." as Root

Rectangle {
    id: root

    required property Root.Theme theme
    property real value: 0
    property bool muted: false
    property color fillColor: muted ? theme.muted : theme.primary

    implicitHeight: 8
    radius: height / 2
    color: theme.surfaceVariant
    clip: true

    Rectangle {
        height: parent.height
        width: Math.max(parent.height, parent.width * Math.max(0, Math.min(1, root.value)))
        radius: height / 2
        color: root.fillColor

        Behavior on width {
            NumberAnimation { duration: root.theme.shortDuration; easing.type: root.theme.emphasizedEasing }
        }

        Behavior on color {
            ColorAnimation { duration: root.theme.shortDuration }
        }
    }
}
