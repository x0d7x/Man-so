import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    id: root

    property var active: null
    property var queue: []
    property var history: []
    property int unreadCount: 0
    property bool visible: false
    property bool centerOpen: false
    property int defaultTimeout: 6000
    property int minTimeout: 2200
    property int maxTimeout: 12000
    property int maxHistory: 50

    readonly property bool hasActive: root.active !== null
    readonly property bool activeCritical: root.active
        && root.active.urgency === NotificationUrgency.Critical
    readonly property bool activeLow: root.active
        && root.active.urgency === NotificationUrgency.Low
    readonly property var activeActions: {
        if (!root.active || !root.active.actions)
            return [];
        return root.active.actions.filter(action => action && action.identifier !== "default");
    }
    readonly property bool activeHasDefault: {
        if (!root.active || !root.active.actions)
            return false;
        return root.active.actions.some(action => action && action.identifier === "default");
    }
    readonly property string activeAppIcon: root.active ? root.active.appIcon : ""
    readonly property string activeImage: root.imageSource(root.active)

    function isCritical(notification) {
        return notification && notification.urgency === NotificationUrgency.Critical;
    }

    function isPersistent(notification) {
        return root.isCritical(notification)
            || notification.resident
            || notification.expireTimeout === 0;
    }

    function resolveIcon(name) {
        if (!name || name.length === 0)
            return Quickshell.iconPath("application-x-executable", true);

        if (name.indexOf("/") === 0
            || name.indexOf("file:") === 0
            || name.indexOf("image:") === 0
            || name.indexOf("qrc:") === 0
            || name.indexOf("data:") === 0)
            return name;

        const path = Quickshell.iconPath(name, true);
        return path && path.length > 0 ? path : Quickshell.iconPath("application-x-executable", true);
    }

    function imageSource(notification) {
        if (!notification)
            return "";

        const hints = notification.hints || {};
        const rawPath = hints["image-path"] || hints["image_path"] || "";
        if (rawPath.length > 0) {
            if (rawPath.indexOf("http://") === 0 || rawPath.indexOf("https://") === 0)
                return rawPath;
            if (rawPath.indexOf("file:") === 0 || rawPath.indexOf("image:") === 0)
                return rawPath;
            if (rawPath.indexOf("/") === 0)
                return "file://" + rawPath;
        }

        return notification.image || "";
    }

    function makeSnapshot(notification) {
        return {
            "id": notification.id,
            "appName": notification.appName || "",
            "appIcon": notification.appIcon || "",
            "summary": notification.summary || "",
            "body": notification.body || "",
            "image": root.imageSource(notification),
            "urgency": notification.urgency,
            "timestamp": Date.now()
        };
    }

    function addToHistory(notification) {
        if (notification.transient)
            return;

        root.history = [root.makeSnapshot(notification)].concat(root.history).slice(0, root.maxHistory);
        if (!root.centerOpen)
            root.unreadCount += 1;
    }

    function setActive(notification) {
        root.active = notification;
        root.visible = true;
        root.startDisplayTimer();
    }

    function startDisplayTimer() {
        displayTimer.stop();
        if (!root.active || root.isPersistent(root.active))
            return;

        let timeout = root.active.expireTimeout > 0
            ? root.active.expireTimeout
            : root.defaultTimeout;
        timeout = Math.max(root.minTimeout, Math.min(root.maxTimeout, timeout));
        displayTimer.interval = timeout;
        displayTimer.restart();
    }

    function advance() {
        if (root.queue.length === 0) {
            root.active = null;
            root.visible = false;
            return;
        }

        const next = root.queue[0];
        root.queue = root.queue.slice(1);
        root.setActive(next);
    }

    function dropActive(notification) {
        if (root.active !== notification)
            return;

        root.active = null;
        displayTimer.stop();
        root.advance();
    }

    function enqueue(notification) {
        if (!notification)
            return;

        notification.tracked = true;
        root.addToHistory(notification);

        if (!root.active) {
            root.setActive(notification);
            return;
        }

        if (root.isCritical(notification) && !root.isCritical(root.active)) {
            const previous = root.active;
            root.queue = [previous].concat(root.queue);
            root.setActive(notification);
            return;
        }

        root.queue = root.queue.concat([notification]);
    }

    function dismissActive() {
        if (!root.active)
            return;

        const notification = root.active;
        root.active = null;
        displayTimer.stop();
        notification.dismiss();
        root.advance();
    }

    function timeoutActive() {
        if (!root.active)
            return;

        const notification = root.active;
        root.active = null;
        displayTimer.stop();
        notification.dismiss();
        root.advance();
    }

    function invokeAction(action) {
        if (!root.active || !action)
            return;

        const notification = root.active;
        const resident = notification.resident;
        action.invoke();

        if (!resident)
            root.dropActive(notification);
    }

    function invokeDefault() {
        if (!root.active || !root.active.actions)
            return;

        for (let i = 0; i < root.active.actions.length; ++i) {
            const action = root.active.actions[i];
            if (action && action.identifier === "default") {
                root.invokeAction(action);
                return;
            }
        }
    }

    function clearAll() {
        const current = root.active;
        const pending = root.queue;

        root.active = null;
        root.queue = [];
        root.history = [];
        root.unreadCount = 0;
        root.visible = false;
        root.centerOpen = false;
        displayTimer.stop();

        if (current)
            current.dismiss();
        for (let i = 0; i < pending.length; ++i) {
            if (pending[i])
                pending[i].dismiss();
        }
    }

    function markAllRead() {
        root.unreadCount = 0;
    }

    function openCenter() {
        root.centerOpen = true;
        root.markAllRead();
    }

    function closeCenter() {
        root.centerOpen = false;
    }

    Connections {
        target: root.active

        function onClosed(reason) {
            if (!root.active)
                return;
            root.active = null;
            displayTimer.stop();
            root.advance();
        }
    }

    NotificationServer {
        id: server

        keepOnReload: false
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
        imageSupported: true
        inlineReplySupported: false

        onNotification: notification => root.enqueue(notification)
    }

    Timer {
        id: displayTimer
        onTriggered: root.timeoutActive()
    }
}
