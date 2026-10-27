import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

Scope {
    id: root

    property var pulseEvents: null
    property bool enabled: true
    property bool microphoneEnabled: true
    property bool screenEnabled: true
    property bool microphoneKnown: false
    property bool microphoneActive: false
    property int microphoneSessionCount: 0
    property var microphoneApps: []
    property string lastError: ""
    property bool pendingQuery: false

    readonly property var screenNodes: {
        if (!root.enabled || !root.screenEnabled || !Pipewire.ready)
            return [];
        return Pipewire.nodes.values.filter(node => {
            if (!node || !node.ready)
                return false;
            const properties = node.properties || {};
            return properties["media.class"] === "Stream/Input/Video"
                && String(properties["media.role"] || "").toLowerCase() === "screen";
        });
    }
    readonly property var screenApps: {
        const applications = [];
        const seen = {};
        for (let i = 0; i < root.screenNodes.length; ++i) {
            const node = root.screenNodes[i];
            const properties = node.properties || {};
            const appName = properties["application.name"]
                || properties["media.name"]
                || node.name
                || "Unknown application";
            const key = String(appName).toLowerCase();
            if (!seen[key]) {
                seen[key] = true;
                applications.push(String(appName));
            }
        }
        return applications;
    }
    readonly property bool screenKnown: root.enabled && root.screenEnabled ? Pipewire.ready : false
    readonly property bool screenActive: root.screenNodes.length > 0
    readonly property int screenSessionCount: root.screenNodes.length
    readonly property string screenError: (root.enabled && root.screenEnabled && !Pipewire.ready)
        ? "PipeWire service is not ready"
        : ""

    PwObjectTracker {
        objects: (root.enabled && root.screenEnabled) ? Pipewire.nodes.values : []
    }

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

    function clearMicrophoneState() {
        root.microphoneActive = false;
        root.microphoneSessionCount = 0;
        root.microphoneApps = [];
        root.microphoneKnown = false;
    }

    function clearState() {
        root.clearMicrophoneState();
    }

    function refresh() {
        if (!root.enabled || !root.microphoneEnabled)
            return;
        if (queryProcess.running) {
            root.pendingQuery = true;
            return;
        }
        root.pendingQuery = false;
        queryProcess.running = true;
    }

    function evaluate(text) {
        if (!root.enabled || !root.microphoneEnabled)
            return;
        const marker = "__OUTPUTS__";
        const index = text.indexOf(marker);
        if (index < 0) {
            root.microphoneKnown = false;
            root.lastError = "Audio stream query returned no data";
            return;
        }

        const sourcesText = text.substring(0, index).replace("__SOURCES__", "").trim();
        const outputsText = text.substring(index + marker.length).trim();
        let sources = [];
        let outputs = [];
        try {
            sources = JSON.parse(sourcesText);
            outputs = JSON.parse(outputsText);
        } catch (error) {
            root.microphoneKnown = false;
            root.lastError = "Cannot parse audio stream data";
            return;
        }

        if (!Array.isArray(sources) || !Array.isArray(outputs)) {
            root.microphoneKnown = false;
            root.lastError = "Cannot parse audio stream data";
            return;
        }

        const sourceByIndex = {};
        for (let i = 0; i < sources.length; ++i) {
            const source = sources[i];
            if (source && source.index !== undefined)
                sourceByIndex[source.index] = source;
        }

        const applications = [];
        const seen = {};
        let sessions = 0;

        for (let i = 0; i < outputs.length; ++i) {
            const output = outputs[i];
            if (!output || output.corked)
                continue;

            const source = sourceByIndex[output.source];
            if (!source)
                continue;

            const sourceName = source.name || "";
            if (source.monitor_source || sourceName.endsWith(".monitor"))
                continue;

            const properties = output.properties || {};
            if (String(properties["stream.capture.sink"]).toLowerCase() === "true")
                continue;

            const appName = properties["application.name"]
                || properties["application.process.binary"]
                || properties["node.name"]
                || "Unknown application";
            const key = String(appName).toLowerCase();
            ++sessions;
            if (!seen[key]) {
                seen[key] = true;
                applications.push(String(appName));
            }
        }

        root.microphoneKnown = true;
        root.microphoneActive = sessions > 0;
        root.microphoneSessionCount = sessions;
        root.microphoneApps = applications;
        root.lastError = "";
    }

    function handlePulseEvent(line) {
        if (!root.enabled || !root.microphoneEnabled)
            return;
        if (line.indexOf("source-output") !== -1
            || line.indexOf("on source #") !== -1
            || line.indexOf("on client #") !== -1
            || line.indexOf("on server") !== -1)
            refreshTimer.restart();
    }

    onEnabledChanged: {
        if (!root.enabled) {
            refreshTimer.stop();
            root.clearState();
            root.lastError = "";
            return;
        }
        if (root.microphoneEnabled)
            root.refresh();
    }

    onMicrophoneEnabledChanged: {
        if (!root.microphoneEnabled) {
            refreshTimer.stop();
            root.clearMicrophoneState();
            root.lastError = "";
            return;
        }
        root.refresh();
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: root.pulseEvents ? root.pulseEvents : null

        function onEvent(line) {
            root.handlePulseEvent(line);
        }

        function onConnectedChanged() {
            if (root.enabled && root.microphoneEnabled
                && root.pulseEvents && root.pulseEvents.connected)
                root.refresh();
        }
    }

    Process {
        id: queryProcess
        command: [
            "sh", "-c",
            "printf '__SOURCES__\\n'; pactl -f json list sources; printf '\\n__OUTPUTS__\\n'; pactl -f json list source-outputs"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.evaluate(this.text)
        }

        onExited: {
            if (root.pendingQuery) {
                root.pendingQuery = false;
                refreshTimer.restart();
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 120
        onTriggered: root.refresh()
    }
}
