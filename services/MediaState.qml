import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Scope {
    id: root

    property bool visible: false
    property real displayPosition: 0
    property int hideDelay: 4000

    readonly property var players: Mpris.players.values.filter(candidate => candidate && candidate.canControl)
    readonly property var mprisPlayer: {
        const list = root.players;
        if (list.length === 0)
            return null;

        const playing = list.find(candidate => candidate.isPlaying);
        return playing ? playing : list[0];
    }
    readonly property var player: {
        if (root.mprisPlayer && root.mprisPlayer.isPlaying)
            return root.mprisPlayer;
        if (mpd.isPlaying)
            return mpd;
        if (root.mprisPlayer)
            return root.mprisPlayer;
        if (mpd.hasPlayer)
            return mpd;
        return null;
    }
    readonly property bool hasPlayer: root.player !== null
    readonly property bool isPlaying: root.player ? root.player.isPlaying : false
    readonly property bool canNext: root.player ? root.player.canGoNext : false
    readonly property bool canPrevious: root.player ? root.player.canGoPrevious : false
    readonly property bool canToggle: root.player ? root.player.canTogglePlaying : false
    readonly property bool canSeek: root.player ? root.player.canSeek : false
    readonly property string title: root.player && root.player.trackTitle.length > 0
        ? root.player.trackTitle
        : "Unknown track"
    readonly property string artist: {
        if (!root.player)
            return "";
        if (root.player.trackArtist.length > 0)
            return root.player.trackArtist;
        if (root.player.trackAlbumArtist.length > 0)
            return root.player.trackAlbumArtist;
        if (root.player.trackAlbum.length > 0)
            return root.player.trackAlbum;
        return root.player.identity;
    }
    readonly property string album: root.player ? root.player.trackAlbum : ""
    readonly property string appName: root.player ? root.player.identity : ""
    readonly property real length: root.player ? root.player.length : 0
    readonly property real progress: {
        if (root.length <= 0)
            return 0;
        return Math.max(0, Math.min(1, root.displayPosition / root.length));
    }
    readonly property string artwork: {
        if (!root.player)
            return "";
        const url = root.player.trackArtUrl;
        if (!url || url.length === 0)
            return "";
        if (url.indexOf("/") === 0)
            return "file://" + url;
        return url;
    }
    readonly property string positionText: root.formatTime(root.displayPosition)
    readonly property string lengthText: root.formatTime(root.length)

    function formatTime(seconds) {
        if (!Number.isFinite(seconds) || seconds < 0)
            return "0:00";
        const total = Math.floor(seconds);
        const minutes = Math.floor(total / 60);
        const remaining = total % 60;
        return minutes + ":" + (remaining < 10 ? "0" : "") + remaining;
    }

    function show() {
        if (!root.player)
            return;
        root.visible = true;
        hideTimer.restart();
    }

    function togglePlaying() {
        if (!root.player)
            return;
        if (root.player === mpd) {
            if (!mpd.canTogglePlaying)
                return;
            mpd.togglePlaying();
        } else {
            if (!root.player.canTogglePlaying)
                return;
            root.player.togglePlaying();
        }
        root.show();
    }

    function next() {
        if (!root.player)
            return;
        if (root.player === mpd) {
            if (!mpd.canGoNext)
                return;
            mpd.next();
        } else {
            if (!root.player.canGoNext)
                return;
            root.player.next();
        }
        root.show();
    }

    function previous() {
        if (!root.player)
            return;
        if (root.player === mpd) {
            if (!mpd.canGoPrevious)
                return;
            mpd.previous();
        } else {
            if (!root.player.canGoPrevious)
                return;
            root.player.previous();
        }
        root.show();
    }

    function seekTo(fraction) {
        if (!root.player || root.length <= 0)
            return;
        const target = Math.max(0, Math.min(1, fraction)) * root.length;
        if (root.player === mpd) {
            if (!mpd.canSeek)
                return;
            mpd.seekTo(fraction);
        } else {
            if (!root.player.canSeek)
                return;
            root.player.position = target;
        }
        root.displayPosition = target;
        root.show();
    }

    function syncPosition() {
        if (!root.player) {
            root.displayPosition = 0;
            return;
        }
        const position = root.player.position;
        root.displayPosition = Number.isFinite(position) ? Math.max(0, position) : 0;
    }

    onPlayerChanged: {
        if (!root.player) {
            root.visible = false;
            hideTimer.stop();
            root.displayPosition = 0;
            return;
        }

        root.syncPosition();
        if (root.player.isPlaying)
            root.show();
    }

    Connections {
        target: root.player

        function onTrackTitleChanged() {
            root.displayPosition = 0;
            root.show();
        }

        function onTrackArtUrlChanged() {
            root.show();
        }

        function onUniqueIdChanged() {
            root.syncPosition();
            root.show();
        }

        function onIsPlayingChanged() {
            root.syncPosition();
            root.show();
        }

        function onPositionChanged() {
            root.syncPosition();
        }

        function onLengthChanged() {
            if (root.displayPosition > root.length)
                root.displayPosition = root.length;
        }
    }

    MpdState {
        id: mpd
    }

    Timer {
        interval: 250
        repeat: true
        running: root.player && root.player.isPlaying && root.length > 0
        onTriggered: {
            if (!root.player)
                return;
            root.displayPosition = Math.min(root.length, root.displayPosition + 0.25);
        }
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: root.visible = false
    }
}
