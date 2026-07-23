import QtQuick
import QtQuick.Controls
import Quickshell
import ".." as Root
import "../components" as Components
import "../services" as Services

PopupWindow {
    id: root

    required property Root.Theme theme
    required property Services.TimeService timeService
    property Item anchorItem: null

    property date currentDate: new Date()
    property var selectedDate: null

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 280
    implicitHeight: 360

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
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.timeService.calendarTimeText
                color: root.theme.onSurface
                font: root.theme.font
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.timeService.calendarDateText
                color: root.theme.muted
                font: root.theme.fontSmall
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.outlineVariant
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 30

                Text {
                    id: monthLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDate(root.currentDate, "MMM yyyy")
                    color: root.theme.onSurface
                    font: root.theme.font
                }

                Rectangle {
                    id: todayLabel
                    anchors.right: prevBtn.left
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    width: todayText.implicitWidth + 12
                    color: todayHover.hovered && todayLabel.enabled ? root.theme.surfaceContainerHighest : "transparent"
                    radius: root.theme.radiusFull
                    opacity: (root.currentDate.getMonth() !== new Date().getMonth() || root.currentDate.getFullYear() !== new Date().getFullYear()) ? 1 : 0
                    enabled: opacity > 0

                    Text {
                        id: todayText
                        anchors.centerIn: parent
                        text: "Today"
                        color: root.theme.onSurface
                        font: root.theme.fontSmall
                    }

                    HoverHandler {
                        id: todayHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentDate = new Date()
                    }
                }

                Rectangle {
                    id: prevBtn
                    anchors.right: nextBtn.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: parent.height
                    color: prevHover.hovered ? root.theme.surfaceContainerHighest : "transparent"
                    radius: root.theme.radiusFull

                    Text {
                        anchors.centerIn: parent
                        text: "chevron_left"
                        color: root.theme.onSurface
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.iconSize
                    }

                    HoverHandler {
                        id: prevHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var d = new Date(root.currentDate);
                            d.setMonth(d.getMonth() - 1);
                            root.currentDate = d;
                        }
                    }
                }

                Rectangle {
                    id: nextBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: parent.height
                    color: nextHover.hovered ? root.theme.surfaceContainerHighest : "transparent"
                    radius: root.theme.radiusFull

                    Text {
                        anchors.centerIn: parent
                        text: "chevron_right"
                        color: root.theme.onSurface
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.iconSize
                    }

                    HoverHandler {
                        id: nextHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var d = new Date(root.currentDate);
                            d.setMonth(d.getMonth() + 1);
                            root.currentDate = d;
                        }
                    }
                }
            }

            DayOfWeekRow {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 24

                delegate: Text {
                    required property string shortName
                    text: shortName
                    color: root.theme.muted
                    font: root.theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MonthGrid {
                id: grid
                anchors.left: parent.left
                anchors.right: parent.right

                month: root.currentDate.getMonth()
                year: root.currentDate.getFullYear()

                delegate: Item {
                    implicitWidth: 32
                    implicitHeight: 32

                    property bool isCurrentMonth: model.month === grid.month
                    property bool isToday: model.today
                    property bool isSelected: root.selectedDate !== null && model.date.getFullYear() === root.selectedDate.getFullYear() && model.date.getMonth() === root.selectedDate.getMonth() && model.date.getDate() === root.selectedDate.getDate()

                    Rectangle {
                        anchors.fill: parent
                        radius: root.theme.radiusFull
                        color: isSelected ? root.theme.primary : dayHover.hovered ? root.theme.surfaceContainerHighest : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: model.day
                            color: isSelected ? root.theme.onPrimary : isCurrentMonth ? root.theme.onSurface : root.theme.muted
                            opacity: isSelected || isCurrentMonth ? 1 : 0.62
                            font: root.theme.fontSmall
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 8
                            height: 2
                            radius: 1
                            color: root.theme.primary
                            visible: isToday
                        }
                    }

                    HoverHandler {
                        id: dayHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (isSelected)
                                root.selectedDate = null;
                            else
                                root.selectedDate = model.date;
                        }
                    }
                }
            }
        }
    }
}
