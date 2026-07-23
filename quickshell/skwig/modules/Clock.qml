import QtQuick
import ".." as Root
import "../services" as Services

Item {
    id: clock

    required property string format
    required property Root.Theme theme
    required property Services.TimeService timeService

    signal clicked()

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 10

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: clock.theme.radius
        color: hoverHandler.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        HoverHandler {
            id: hoverHandler
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: clock.clicked()
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: clock.timeService.timeText(clock.format)
            color: clock.theme.onSurface
            font: clock.theme.fontSmall
        }
    }
}
