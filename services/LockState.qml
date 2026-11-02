import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

import "../components"

// Session lock built on ext-session-lock-v1 via WlSessionLock.
// The compositor owns the lock: if maneso dies while locked the session stays
// locked (painted solid) rather than being exposed. Only a successful PAM
// authentication clears it.
Scope {
    id: root

    property bool locked: false
    property string errorText: ""
    property bool authenticating: false
    property string pending: ""

    // Overridable so tests can point at a stub PAM stack instead of the real one.
    property string pamConfig: "login"
    property string pamConfigDir: "/etc/pam.d"

    property var colors
    property var settings

    readonly property bool secure: lock.secure

    function lock() {
        root.errorText = "";
        root.pending = "";
        root.authenticating = false;
        root.locked = true;
    }

    function unlock() {
        if (pam.active)
            pam.abort();
        root.pending = "";
        root.authenticating = false;
        root.errorText = "";
        root.locked = false;
    }

    // Feed the typed password to PAM. The password is only kept until it is
    // handed over, and never stored anywhere else.
    function submit(response) {
        const value = String(response);
        if (value.length === 0)
            return;
        root.errorText = "";
        root.pending = value;
        if (pam.active) {
            if (pam.responseRequired)
                root.flushPending();
            return;
        }
        root.authenticating = true;
        if (!pam.start()) {
            root.authenticating = false;
            root.pending = "";
            root.errorText = "Could not start authentication";
            return;
        }
        if (pam.responseRequired)
            root.flushPending();
    }

    function flushPending() {
        if (root.pending.length === 0)
            return;
        const value = root.pending;
        root.pending = "";
        pam.respond(value);
    }

    function cancel() {
        if (pam.active)
            pam.abort();
        root.pending = "";
        root.authenticating = false;
        root.errorText = "";
    }

    onLockedChanged: {
        if (!root.locked) {
            root.pending = "";
            root.errorText = "";
            root.authenticating = false;
        }
    }

    WlSessionLock {
        id: lock

        locked: root.locked

        surface: Component {
            LockSurface {
                lockState: root
                colors: root.colors
                settings: root.settings
            }
        }
    }

    PamContext {
        id: pam

        config: root.pamConfig
        configDirectory: root.pamConfigDir

        onResponseRequiredChanged: {
            if (pam.responseRequired && root.pending.length > 0)
                root.flushPending();
        }

        onCompleted: result => {
            root.authenticating = false;
            root.pending = "";
            if (result === PamResult.Success) {
                root.unlock();
            } else if (result === PamResult.MaxTries) {
                root.errorText = "Too many attempts. Try again later.";
            } else if (result === PamResult.Failed) {
                root.errorText = "Authentication failed";
            } else {
                root.errorText = "Authentication error";
            }
        }

        onError: error => {
            root.authenticating = false;
            root.pending = "";
            root.errorText = error === PamError.StartFailed
                ? "Could not start authentication"
                : (error === PamError.TryAuthFailed ? "Authentication failed" : "Authentication error");
        }
    }
}
