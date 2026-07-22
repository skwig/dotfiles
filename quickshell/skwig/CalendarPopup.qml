import QtQuick
import QtQuick.Controls
import Quickshell

PopupWindow {
    id: root

    required property Theme theme
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

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: Qt.rgba(0, 0, 0, 0.8)
        radius: root.theme.radius

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "HH:mm:ss")
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "dddd, MMMM d yyyy")
                color: Qt.rgba(1, 1, 1, 0.5)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
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
                    color: root.theme.fontColor
                    font.family: root.theme.font.family
                    font.pixelSize: root.theme.font.pixelSize
                }

                Rectangle {
                    id: todayLabel
                    anchors.right: prevBtn.left
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    width: todayText.implicitWidth + 12
                    color: todayHover.hovered && todayLabel.enabled ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    radius: root.theme.radius
                    opacity: (root.currentDate.getMonth() !== new Date().getMonth() || root.currentDate.getFullYear() !== new Date().getFullYear()) ? 1 : 0
                    enabled: opacity > 0

                    Text {
                        id: todayText
                        anchors.centerIn: parent
                        text: "Today"
                        color: root.theme.fontColor
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize - 2
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
                    color: prevHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    radius: root.theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: "\u276E"
                        color: root.theme.fontColor
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize
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
                    color: nextHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    radius: root.theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: "\u276F"
                        color: root.theme.fontColor
                        font.family: root.theme.font.family
                        font.pixelSize: root.theme.font.pixelSize
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
                    color: Qt.rgba(1, 1, 1, 0.4)
                    font.family: root.theme.font.family
                    font.pixelSize: root.theme.font.pixelSize - 2
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
                        radius: root.theme.radius
                        color: isSelected ? root.theme.fontColor : dayHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: model.day
                            color: isSelected ? "#000000" : isCurrentMonth ? root.theme.fontColor : Qt.rgba(1, 1, 1, 0.2)
                            font.family: root.theme.font.family
                            font.pixelSize: root.theme.font.pixelSize - 2
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 8
                            height: 2
                            radius: 1
                            color: root.theme.fontColor
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
