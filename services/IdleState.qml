import Quickshell
import Quickshell.Wayland._IdleNotify
import QtQuick

// Idle handling: auto-lock and display power-off.
// Uses ext-idle-notify-v1 through IdleMonitor with respectInhibitors, so fullscreen
// video and anything holding an idle inhibitor keep the session awake.
Scope {
    id: root

    property var settings
    property var lockScreen
    property var mangoIpc
    property var media

    readonly property int lockMinutes: root.settings ? root.settings.idleLockMinutes : 0
    readonly property int displayOffMinutes: root.settings ? root.settings.idleDisplayOffMinutes : 0
    readonly property bool suppressOnMedia: root.settings ? root.settings.idleSuppressOnMedia : true
    readonly property bool mediaPlaying: root.media ? root.media.isPlaying : false
    readonly property bool suppressed: root.suppressOnMedia && root.mediaPlaying

    readonly property bool masterEnabled: root.settings ? root.settings.idleEnabled : true
    readonly property bool lockArmed: root.masterEnabled && root.lockMinutes > 0 && !root.suppressed
    readonly property bool displayOffArmed: root.masterEnabled && root.displayOffMinutes > 0 && !root.suppressed

    property bool displaysOff: false



    function screenNames() {
        const names = [];
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; ++i) {
            if (screens[i] && screens[i].name)
                names.push(screens[i].name);
        }
        return names;
    }

    function sleepDisplays() {
        if (root.displaysOff || !root.mangoIpc)
            return;
        root.displaysOff = true;
        const names = root.screenNames();
        for (let i = 0; i < names.length; ++i)
            root.mangoIpc.sendCommand("dispatch sleep_monitor," + names[i]);
    }

    function wakeDisplays() {
        if (!root.displaysOff || !root.mangoIpc)
            return;
        root.displaysOff = false;
        const names = root.screenNames();
        for (let i = 0; i < names.length; ++i)
            root.mangoIpc.sendCommand("dispatch wakeup_monitor," + names[i]);
    }

    // IdleMonitor instances live in shell.qml: created inside this reloadable
    // service scope they never receive idle notifications.
    function onLockIdle() {
        if (root.lockScreen && !root.lockScreen.locked)
            root.lockScreen.lock();
    }

    // Playing media, or turning suppression on, must not leave the screens dark.
    onSuppressedChanged: {
        if (root.suppressed)
            root.wakeDisplays();
    }
}
