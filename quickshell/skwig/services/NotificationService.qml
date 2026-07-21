import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: root

    readonly property var notifications: server.trackedNotifications.values
    readonly property int notificationCount: notifications.length

    property var receivedTimes: ({})
    property var osdNotifications: []

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            root.receivedTimes[root.notificationKey(notification)] = Date.now();
            notification.tracked = true;
            root.addToOsd(notification);
            notification.closed.connect(() => root.removeFromOsd(notification));
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    function notificationKey(notification) {
        return [notification.appName, notification.id, notification.summary, notification.body].join("|");
    }

    function receivedTime(notification) {
        const key = notificationKey(notification);
        if (!root.receivedTimes[key])
            root.receivedTimes[key] = Date.now();
        return root.receivedTimes[key];
    }

    function appName(notification) {
        return notification.appName || notification.desktopEntry || "Unknown";
    }

    function relativeTime(notification) {
        const seconds = Math.max(0, Math.floor((clock.date.getTime() - receivedTime(notification)) / 1000));
        if (seconds < 60)
            return "now";
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60)
            return minutes + "m";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h";
        return Math.floor(hours / 24) + "d";
    }

    function notificationTitle(notification) {
        return notification.summary || notification.body || "Notification";
    }

    function addToOsd(notification) {
        root.removeFromOsd(notification);
        root.osdNotifications = [notification].concat(root.osdNotifications);
    }

    function removeFromOsd(notification) {
        root.osdNotifications = root.osdNotifications.filter(item => item !== notification);
    }

    function groupedNotifications() {
        const map = new Map();
        for (const notification of root.notifications) {
            const name = root.appName(notification);
            if (!map.has(name))
                map.set(name, []);
            map.get(name).push(notification);
        }

        const groups = [];
        for (const [name, items] of map.entries()) {
            const sortedItems = items.sort((a, b) => root.receivedTime(b) - root.receivedTime(a));
            groups.push({
                name: name,
                notifications: sortedItems,
                newest: sortedItems.length > 0 ? root.receivedTime(sortedItems[0]) : 0
            });
        }

        return groups.sort((a, b) => b.newest - a.newest);
    }
}
