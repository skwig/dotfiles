import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".." as Root
import "../components" as Components
import "../services" as Services

PopupWindow {
    id: root

    required property Root.Theme theme
    property Item anchorItem: null
    required property Services.NotificationService notificationService

    readonly property int notificationCount: notificationService.notificationCount
    readonly property var groups: notificationService.groupedNotifications()

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 420
    implicitHeight: Math.min(520, content.implicitHeight + 20)
    visible: false
    grabFocus: true
    color: "transparent"

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

            Components.MaterialCard {
                anchors.left: parent.left
                anchors.right: parent.right
                theme: root.theme
                highlighted: root.notificationCount > 0
                implicitHeight: headerRow.implicitHeight + contentPadding * 2

                Row {
                    id: headerRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.theme.spacingS

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        text: "notifications"
                        color: root.theme.primary
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.iconSize
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36
                        text: "Notifications"
                        color: root.theme.onSurface
                        font: root.theme.font
                    }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.notificationCount === 0
                text: "No notifications"
                color: root.theme.muted
                font: root.theme.fontSmall
            }

            Flickable {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.notificationCount > 0
                implicitHeight: Math.min(430, notificationGroups.implicitHeight)
                contentHeight: notificationGroups.implicitHeight
                clip: true

                Column {
                    id: notificationGroups
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10

                    Repeater {
                        model: root.groups

                        delegate: Column {
                            id: groupColumn

                            required property var modelData

                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 6

                            Components.MaterialSectionLabel {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                theme: root.theme
                                text: groupColumn.modelData.name + " (" + groupColumn.modelData.notifications.length + ")"
                                elide: Text.ElideRight
                            }

                            Repeater {
                                model: groupColumn.modelData.notifications

                                delegate: Components.MaterialCard {
                                    id: notificationRow

                                    required property Notification modelData

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    theme: root.theme
                                    interactive: true
                                    contentPadding: root.theme.spacingS
                                    implicitHeight: Math.max(rowContent.implicitHeight, 32) + 14
                                    color: notificationRow.modelData.urgency === NotificationUrgency.Critical ? root.theme.withAlpha(root.theme.error, 0.18) : notificationRow.modelData.urgency === NotificationUrgency.Low ? root.theme.surfaceVariant : root.theme.surfaceContainerHigh
                                    border.width: notificationRow.modelData.urgency === NotificationUrgency.Critical ? 1 : 0
                                    border.color: root.theme.withAlpha(root.theme.error, 0.45)

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: notificationRow.modelData.dismiss()
                                    }

                                    Row {
                                        id: rowContent
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 8
                                        spacing: 8

                                        Item {
                                            width: 32
                                            height: 32
                                            anchors.verticalCenter: parent.verticalCenter

                                            IconImage {
                                                anchors.fill: parent
                                                visible: notificationRow.modelData.appIcon.length > 0
                                                source: Quickshell.iconPath(notificationRow.modelData.appIcon)
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: notificationRow.modelData.appIcon.length === 0
                                                text: "notifications"
                                                color: root.theme.primary
                                                font.family: root.theme.iconFontFamily
                                                font.pixelSize: root.theme.iconSize
                                            }
                                        }

                                        Column {
                                            id: rowColumn
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 40
                                            spacing: 4

                                            Row {
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                spacing: 8

                                                Text {
                                                    width: parent.width - timeText.implicitWidth - parent.spacing
                                                    text: root.notificationService.notificationTitle(notificationRow.modelData)
                                                    color: root.theme.onSurface
                                                    elide: Text.ElideRight
                                                    font: root.theme.fontSmall
                                                }

                                                Text {
                                                    id: timeText
                                                    text: root.notificationService.relativeTime(notificationRow.modelData)
                                                    color: root.theme.muted
                                                    font: root.theme.fontTiny
                                                }
                                            }

                                            Text {
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                visible: notificationRow.modelData.body.length > 0 && notificationRow.modelData.summary.length > 0
                                                text: notificationRow.modelData.body
                                                textFormat: Text.PlainText
                                                maximumLineCount: 3
                                                wrapMode: Text.WordWrap
                                                elide: Text.ElideRight
                                                color: root.theme.muted
                                                font: root.theme.fontTiny
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
