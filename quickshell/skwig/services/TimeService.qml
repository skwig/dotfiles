import Quickshell
import QtQuick

Scope {
    id: root

    readonly property date date: clock.date
    readonly property string calendarTimeText: Qt.formatDateTime(clock.date, "HH:mm:ss")
    readonly property string calendarDateText: Qt.formatDateTime(clock.date, "dddd, MMMM d yyyy")

    function timeText(format) {
        return Qt.formatDateTime(clock.date, format);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
