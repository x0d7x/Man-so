import Quickshell
import Quickshell.Services.UPower
import QtQuick

Scope {
    id: root

    readonly property int profileValue: PowerProfiles.profile
    readonly property string profile: {
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "performance";
        if (PowerProfiles.profile === PowerProfile.Balanced)
            return "balanced";
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "power-saver";
        return "unknown";
    }
    readonly property bool changing: false
    readonly property bool busy: false
    readonly property string pendingProfile: ""
    readonly property string lastError: ""

    readonly property string label: {
        if (root.profile === "performance")
            return "PERF";
        if (root.profile === "balanced")
            return "BAL";
        if (root.profile === "power-saver")
            return "SAVE";
        return "TLP";
    }
    readonly property string icon: {
        if (root.profile === "performance")
            return "";
        if (root.profile === "balanced")
            return "";
        if (root.profile === "power-saver")
            return "";
        return "󰓅";
    }

    function cycle() {
        const order = ["performance", "balanced", "power-saver"];
        const index = order.indexOf(root.profile);
        root.setProfile(order[(index + 1 + order.length) % order.length]);
    }

    function setProfile(name) {
        if (name === "performance")
            PowerProfiles.profile = PowerProfile.Performance;
        else if (name === "balanced")
            PowerProfiles.profile = PowerProfile.Balanced;
        else if (name === "power-saver")
            PowerProfiles.profile = PowerProfile.PowerSaver;
    }
}
