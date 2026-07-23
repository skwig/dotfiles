import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".." as Root
import "../components" as Components
import "../services" as Services

PanelWindow {
    id: root

    required property Root.Theme theme
    required property Services.NotificationService notificationService
    property ShellScreen targetScreen: null
    readonly property bool showing: notificationService.osdNotifications.length > 0
    property real exitSurfaceHeight: 0

    anchors.top: true
    anchors.right: true
    screen: targetScreen
    margins.top: 12
    margins.right: 12
    exclusiveZone: 0
    implicitWidth: 360
    implicitHeight: surface.implicitHeight
    visible: showing || exitTimer.running
    color: "transparent"

    onShowingChanged: {
        if (showing)
            exitTimer.stop();
        else
            exitTimer.restart();
    }

    Timer {
        id: exitTimer
        interval: root.theme.shortDuration
    }

    Rectangle {
        id: surface

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        implicitHeight: root.showing || root.exitSurfaceHeight <= 0 ? stack.implicitHeight + root.theme.spacingM * 2 : root.exitSurfaceHeight
        radius: root.theme.radiusLarge
        color: root.theme.surfaceContainerHigh
        border.width: 1
        border.color: root.theme.outlineVariant
        opacity: root.showing ? 1 : 0
        scale: root.showing ? 1 : 0.94

        onImplicitHeightChanged: {
            if (root.showing)
                root.exitSurfaceHeight = implicitHeight;
        }

        Behavior on opacity {
            NumberAnimation { duration: root.theme.shortDuration; easing.type: root.theme.emphasizedEasing }
        }

        Behavior on scale {
            NumberAnimation { duration: root.theme.shortDuration; easing.type: root.theme.emphasizedEasing }
        }

        Column {
            id: stack
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: root.theme.spacingM
            spacing: root.theme.spacingS

            Repeater {
                model: root.notificationService.osdNotifications

                delegate: Components.MaterialCard {
                    id: card

                    required property Notification modelData
                    readonly property string appIcon: modelData.appIcon
                    readonly property bool hasAppIcon: appIcon.length > 0
                    property Timer removalTimer: Timer {
                        interval: 5000
                        onTriggered: root.notificationService.removeFromOsd(card.modelData)
                    }

                    width: root.implicitWidth - root.theme.spacingM * 2
                    implicitHeight: Math.max(content.implicitHeight + root.theme.spacingM * 2, 72)
                    theme: root.theme
                    interactive: true
                    contentPadding: root.theme.spacingM

                    Component.onCompleted: removalTimer.restart()

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.modelData.dismiss()
                    }

                    RowLayout {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: root.theme.spacingM

                        Item {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: root.theme.radiusFull
                                color: root.theme.withAlpha(root.theme.primary, 0.14)
                                visible: !card.hasAppIcon
                            }

                            IconImage {
                                anchors.fill: parent
                                visible: card.hasAppIcon
                                source: Quickshell.iconPath(card.appIcon)
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !card.hasAppIcon
                                text: "notifications"
                                color: root.theme.primary
                                font.family: root.theme.iconFontFamily
                                font.pixelSize: root.theme.iconSize
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: root.theme.spacingXS

                            Text {
                                Layout.fillWidth: true
                                text: root.notificationService.appName(card.modelData)
                                color: root.theme.primary
                                elide: Text.ElideRight
                                font: root.theme.fontSmall
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.notificationService.notificationTitle(card.modelData)
                                color: root.theme.onSurface
                                elide: Text.ElideRight
                                font: root.theme.font
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: card.modelData.body.length > 0 && card.modelData.summary.length > 0
                                text: card.modelData.body
                                textFormat: Text.PlainText
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                color: root.theme.onSurfaceVariant
                                font: root.theme.fontSmall
                            }
                        }
                    }
                }
            }
        }
    }
}
