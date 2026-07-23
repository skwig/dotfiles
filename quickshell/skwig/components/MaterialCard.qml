import QtQuick
import ".." as Root

Rectangle {
    id: root

    required property Root.Theme theme
    default property alias content: contentItem.data
    property alias contentItem: contentItem
    property bool highlighted: false
    property bool interactive: false
    property real contentPadding: theme.spacingM

    color: highlighted ? theme.surfaceContainerHighest : interactive && hover.hovered ? theme.surfaceContainerHigh : theme.surfaceVariant
    radius: theme.radius
    border.width: highlighted ? 1 : 0
    border.color: theme.withAlpha(theme.primary, 0.35)
    implicitWidth: contentItem.implicitWidth + contentPadding * 2
    implicitHeight: contentItem.implicitHeight + contentPadding * 2

    HoverHandler { id: hover; enabled: root.interactive }

    Behavior on color {
        ColorAnimation { duration: root.theme.shortDuration }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.contentPadding
    }
}
