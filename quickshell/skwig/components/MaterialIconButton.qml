import QtQuick
import QtQuick.Layouts
import ".." as Root

Rectangle {
    id: root

    required property Root.Theme theme
    property string iconName: ""
    property string label: ""
    property bool selected: false
    property bool filled: false
    property color foreground: selected || filled ? theme.onPrimary : theme.onSurface
    signal clicked

    implicitWidth: label.length > 0 ? icon.implicitWidth + labelText.implicitWidth + theme.spacingL * 2 : 36
    implicitHeight: 36
    radius: theme.radiusFull
    color: selected || filled ? theme.primary : hover.hovered ? theme.surfaceContainerHighest : theme.surfaceVariant
    border.width: selected || filled ? 0 : 1
    border.color: theme.outlineVariant

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.theme.spacingM
        anchors.rightMargin: root.theme.spacingM
        spacing: root.label.length > 0 ? root.theme.spacingS : 0

        Item {
            Layout.fillWidth: true
        }

        Text {
            id: icon
            text: root.iconName
            color: root.foreground
            font.family: root.theme.iconFontFamily
            font.pixelSize: root.theme.iconSizeSmall
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            id: labelText
            visible: root.label.length > 0
            text: root.label
            color: root.foreground
            font: root.theme.fontSmall
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
