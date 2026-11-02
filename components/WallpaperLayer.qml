import Quickshell
import Quickshell.Wayland
import QtQuick

// Background surfaces for the "quickshell" wallpaper backend: one click-through
// layer surface per screen, drawing the current image with a crossfade.
// Nothing here runs unless the backend is "quickshell".
Scope {
    id: root

    property var wallpaper
    property var settings

    readonly property string source: root.wallpaper ? root.wallpaper.currentPath : ""
    readonly property string fit: root.settings ? root.settings.wallpaperFit : "fill"
    readonly property bool bottomLayer: root.settings ? root.settings.wallpaperLayer === "bottom" : false
    readonly property int fadeDuration: root.settings ? Math.max(0, root.settings.wallpaperTransitionDuration) * 1000 : 0
    readonly property bool enabled: root.wallpaper ? root.wallpaper.usesQuickshell : false

    function fillModeFor(value) {
        if (value === "fit")
            return Image.PreserveAspectFit;
        if (value === "stretch")
            return Image.Stretch;
        if (value === "center")
            return Image.Pad;
        if (value === "tile")
            return Image.Tile;
        return Image.PreserveAspectCrop;
    }

    // Center and tile need native pixels; the scaling modes can be decoded small.
    function scalesSource(value) {
        return value !== "center" && value !== "tile";
    }

    Variants {
        model: root.enabled ? Quickshell.screens : []

        delegate: Component {
            PanelWindow {
                id: surface

                required property var modelData

                property string shownSource: ""
                property string underSource: ""

                screen: surface.modelData
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                color: "black"
                // -1 asks wlr-layer-shell to ignore other surfaces' exclusive zones,
                // otherwise the island's reserved strip stays unpainted.
                exclusiveZone: -1
                aboveWindows: false
                WlrLayershell.layer: root.bottomLayer ? WlrLayer.Bottom : WlrLayer.Background
                WlrLayershell.namespace: "maneso-wallpaper"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                // No part of this surface accepts input.
                mask: Region {}

                function show(next) {
                    if (next === surface.shownSource)
                        return;
                    fade.stop();
                    over.opacity = 0;
                    surface.underSource = surface.shownSource;
                    surface.shownSource = next;
                    if (root.fadeDuration > 0) {
                        fade.restart();
                    } else {
                        // No fade: nothing may show through the transparent parts of
                        // modes like Pad or Fit, so drop the outgoing image entirely.
                        surface.underSource = "";
                        over.opacity = 1;
                    }
                }

                Component.onCompleted: surface.show(root.source)

                Connections {
                    target: root

                    function onSourceChanged() {
                        surface.show(root.source);
                    }
                }

                Image {
                    id: under

                    anchors.fill: parent
                    // Only a fade needs the outgoing image; otherwise it would show
                    // through the transparent area of Pad/Fit.
                    visible: fade.running
                    source: surface.underSource
                    fillMode: root.fillModeFor(root.fit)
                    sourceSize: root.scalesSource(root.fit)
                        ? Qt.size(Math.round(surface.width * surface.devicePixelRatio),
                                  Math.round(surface.height * surface.devicePixelRatio))
                        : undefined
                    asynchronous: true
                    cache: false
                    smooth: true
                }

                Image {
                    id: over

                    anchors.fill: parent
                    source: surface.shownSource
                    fillMode: root.fillModeFor(root.fit)
                    sourceSize: root.scalesSource(root.fit)
                        ? Qt.size(Math.round(surface.width * surface.devicePixelRatio),
                                  Math.round(surface.height * surface.devicePixelRatio))
                        : undefined
                    asynchronous: true
                    cache: false
                    smooth: true
                    opacity: 0
                }

                NumberAnimation {
                    id: fade

                    target: over
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.fadeDuration
                    easing.type: Easing.InOutQuad

                    // Free the outgoing image once the crossfade is done.
                    onFinished: surface.underSource = ""
                }
            }
        }
    }
}
