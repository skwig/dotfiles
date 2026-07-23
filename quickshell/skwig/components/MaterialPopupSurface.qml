import QtQuick
import ".." as Root

Rectangle {
    id: root

    required property Root.Theme theme
    default property alias content: contentItem.data
    property alias contentItem: contentItem
    property real contentPadding: theme.spacingL

    color: theme.surfaceContainer
    radius: theme.radiusLarge
    border.width: 1
    border.color: theme.outlineVariant
    implicitWidth: contentItem.implicitWidth + contentPadding * 2
    implicitHeight: contentItem.implicitHeight + contentPadding * 2

    Behavior on opacity {
        NumberAnimation { duration: root.theme.shortDuration; easing.type: root.theme.emphasizedEasing }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.contentPadding
    }
}
