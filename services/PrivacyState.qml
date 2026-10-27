import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Scope {
    id: root

    property bool enabled: true
    property bool microphoneEnabled: true
    property bool screenEnabled: true

    readonly property bool monitoringActive: root.enabled && (root.microphoneEnabled || root.screenEnabled)
    readonly property var links: Pipewire.links.values

    PwObjectTracker {
        objects: root.monitoringActive
            ? Pipewire.nodes.values.concat(Pipewire.links.values)
            : []
    }

    function nodeProperties(node) {
        return node && node.properties ? node.properties : ({});
    }

    function applicationName(node) {
        const properties = root.nodeProperties(node);
        return properties["application.name"]
            || properties["media.name"]
            || (node ? node.name : "")
            || "Unknown application";
    }

    function uniqueApps(nodes) {
        const applications = [];
        const seen = {};
        for (let i = 0; i < nodes.length; ++i) {
            const name = root.applicationName(nodes[i]);
            const key = String(name).toLowerCase();
            if (!seen[key]) {
                seen[key] = true;
                applications.push(String(name));
            }
        }
        return applications;
    }

    readonly property var microphoneNodes: {
        if (!root.enabled || !root.microphoneEnabled || !Pipewire.ready)
            return [];

        return Pipewire.nodes.values.filter(node => {
            if (!node || !node.ready)
                return false;
            const properties = root.nodeProperties(node);
            if (properties["media.class"] !== "Stream/Input/Audio")
                return false;

            const activeLinks = root.links.filter(link =>
                link && link.target === node && link.state === PwLinkState.Active);
            return activeLinks.some(link => {
                const source = link.source;
                if (!source)
                    return false;
                const sourceName = source.name || "";
                if (sourceName.endsWith(".monitor"))
                    return false;
                if (String(root.nodeProperties(source)["stream.capture.sink"]).toLowerCase() === "true")
                    return false;
                return true;
            });
        });
    }

    readonly property bool microphoneKnown: root.enabled && root.microphoneEnabled ? Pipewire.ready : false
    readonly property bool microphoneActive: root.microphoneNodes.length > 0
    readonly property int microphoneSessionCount: root.microphoneNodes.length
    readonly property var microphoneApps: root.uniqueApps(root.microphoneNodes)
    readonly property string lastError: (root.enabled && root.microphoneEnabled && !Pipewire.ready)
        ? "PipeWire service is not ready"
        : ""

    readonly property var screenNodes: {
        if (!root.enabled || !root.screenEnabled || !Pipewire.ready)
            return [];
        return Pipewire.nodes.values.filter(node => {
            if (!node || !node.ready)
                return false;
            const properties = root.nodeProperties(node);
            return properties["media.class"] === "Stream/Input/Video"
                && String(properties["media.role"] || "").toLowerCase() === "screen";
        });
    }

    readonly property bool screenKnown: root.enabled && root.screenEnabled ? Pipewire.ready : false
    readonly property bool screenActive: root.screenNodes.length > 0
    readonly property int screenSessionCount: root.screenNodes.length
    readonly property var screenApps: root.uniqueApps(root.screenNodes)
    readonly property string screenError: (root.enabled && root.screenEnabled && !Pipewire.ready)
        ? "PipeWire service is not ready"
        : ""

    readonly property string summary: {
        if (!root.enabled)
            return "Monitoring disabled";
        const parts = [];
        if (root.microphoneEnabled)
            parts.push(root.microphoneActive ? "Microphone: " + root.microphoneApps.join(", ") : "Microphone: inactive");
        if (root.screenEnabled)
            parts.push(root.screenActive ? "Screen: " + root.screenApps.join(", ") : "Screen: inactive");
        return parts.join(" · ") || "No privacy monitoring";
    }
}
