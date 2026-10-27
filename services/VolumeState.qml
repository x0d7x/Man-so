import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Scope {
    id: root

    property bool visible: false
    property int step: 2
    property int osdTimeout: 1500
    property bool suppressOsd: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: root.sink ? root.sink.audio : null
    readonly property bool available: Pipewire.ready && root.audio !== null
    readonly property int level: root.audio ? Math.round(root.audio.volume * 100) : -1
    readonly property bool muted: root.audio ? root.audio.muted : false
    readonly property string deviceText: root.sink ? root.sink.description : ""
    readonly property string levelText: root.level < 0 ? "--" : (root.muted ? "MUTE" : root.level + "%")
    readonly property real progress: root.level < 0 ? 0 : root.level / 100
    readonly property string icon: {
        if (!root.available || root.muted || root.level <= 0)
            return "󰖁";
        if (root.level < 34)
            return "󰕿";
        if (root.level < 67)
            return "󰖀";
        return "󰕾";
    }

    function clamp(value) {
        return Math.max(0, Math.min(100, Math.round(value)));
    }

    function show() {
        if (!root.available)
            return;
        root.visible = true;
        hideTimer.restart();
    }

    function beginWrite() {
        root.suppressOsd = true;
        suppressTimer.restart();
    }

    function adjust(direction) {
        if (direction === 0 || !root.audio)
            return;
        root.setLevel(root.level + direction * root.step, true);
    }

    function toggleMute() {
        if (!root.audio)
            return;
        root.beginWrite();
        root.audio.muted = !root.audio.muted;
        root.show();
    }

    function setLevel(percent, showOsd) {
        if (!root.audio)
            return;

        root.beginWrite();
        const next = root.clamp(percent);
        root.audio.volume = next / 100;
        if (next > 0 && root.audio.muted)
            root.audio.muted = false;
        if (showOsd === undefined || showOsd)
            root.show();
    }

    Connections {
        target: root.audio

        function onVolumeChanged() {
            if (!root.suppressOsd)
                root.show();
        }

        function onMutedChanged() {
            if (!root.suppressOsd)
                root.show();
        }
    }

    onOsdTimeoutChanged: {
        if (root.visible)
            hideTimer.restart();
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Timer {
        id: suppressTimer
        interval: 120
        onTriggered: root.suppressOsd = false
    }

    Timer {
        id: hideTimer
        interval: root.osdTimeout
        onTriggered: root.visible = false
    }
}
