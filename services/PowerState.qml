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

    readonly property bool available: root.profile !== "unknown"
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile
    readonly property string degradationText: {
        if (PowerProfiles.degradationReason === PerformanceDegradationReason.LapDetected)
            return "Performance is limited: lap detected";
        if (PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature)
            return "Performance is limited: high temperature";
        return "";
    }
    readonly property var profiles: [
        {
            "id": "performance",
            "label": "Performance",
            "icon": "",
            "description": "Maximum clocks and responsiveness",
            "available": root.available && root.hasPerformance
        },
        {
            "id": "balanced",
            "label": "Balanced",
            "icon": "",
            "description": "Adapts clocks to the current workload",
            "available": root.available
        },
        {
            "id": "power-saver",
            "label": "Power Saver",
            "icon": "",
            "description": "Lower clocks for longer battery life",
            "available": root.available
        }
    ]

    function profileEntry(name) {
        for (let i = 0; i < root.profiles.length; ++i) {
            if (root.profiles[i].id === name)
                return root.profiles[i];
        }
        return null;
    }

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
