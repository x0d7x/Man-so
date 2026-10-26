import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var data: ({
        "surface": "#282828",
        "surface_container_low": "#282828",
        "surface_container": "#3c3836",
        "surface_container_high": "#504945",
        "surface_container_highest": "#665c54",
        "surface_variant": "#504945",
        "on_surface": "#ebdbb2",
        "on_surface_variant": "#bdae93",
        "primary": "#fabd2f",
        "on_primary": "#282828",
        "primary_container": "#504945",
        "on_primary_container": "#fbf1c7",
        "secondary": "#8ec07c",
        "secondary_container": "#3c3836",
        "tertiary": "#83a598",
        "outline": "#928374",
        "outline_variant": "#665c54",
        "error": "#fb4934"
    })

    readonly property color surface: root.data.surface
    readonly property color surfaceLow: root.data.surface_container_low
    readonly property color surfaceContainer: root.data.surface_container
    readonly property color surfaceHigh: root.data.surface_container_high
    readonly property color surfaceHighest: root.data.surface_container_highest
    readonly property color surfaceVariant: root.data.surface_variant
    readonly property color fg: root.data.on_surface
    readonly property color fgMuted: root.data.on_surface_variant
    readonly property color accent: root.data.primary
    readonly property color onAccent: root.data.on_primary
    readonly property color accentContainer: root.data.primary_container
    readonly property color onAccentContainer: root.data.on_primary_container
    readonly property color secondary: root.data.secondary
    readonly property color secondaryContainer: root.data.secondary_container
    readonly property color tertiary: root.data.tertiary
    readonly property color border: root.data.outline
    readonly property color borderMuted: root.data.outline_variant
    readonly property color error: root.data.error

    function parseColors(text) {
        if (!text || text.trim().length === 0)
            return;

        try {
            const parsed = JSON.parse(text);
            if (!parsed || typeof parsed !== "object")
                return;

            root.data = Object.assign({}, root.data, parsed);
        } catch (error) {
        }
    }

    FileView {
        id: colorFile

        path: Quickshell.env("HOME") + "/.config/matugen/quickshell.json"
        watchChanges: true
        onTextChanged: root.parseColors(colorFile.text())
    }
}
