import Quickshell
import Quickshell.Wayland
import QtQuick

// Full-screen wallpaper picker overlay. Only instantiated while pickerOpen is set,
// so it costs nothing when closed.
Scope {
    id: root

    property var wallpaper
    property var settings
    property var thumbnails
    property var colors

    readonly property string monoFont: root.settings && root.settings.fontFamily.length > 0
        ? root.settings.fontFamily
        : "JetBrainsMono Nerd Font Mono"
    readonly property color bgColor: root.colors ? root.colors.surface : "#282828"
    readonly property color surfaceHighColor: root.colors ? root.colors.surfaceHigh : "#504945"
    readonly property color fgColor: root.colors ? root.colors.fg : "#ebdbb2"
    readonly property color mutedColor: root.colors ? root.colors.fgMuted : "#bdae93"
    readonly property color accentColor: root.colors ? root.colors.accent : "#fabd2f"
    readonly property color onAccentColor: root.colors ? root.colors.onAccent : "#282828"
    readonly property string layoutName: root.settings ? root.settings.wallpaperPickerLayout : "carousel"
    readonly property bool vimKeys: root.settings ? root.settings.wallpaperPickerVimKeys : false
    readonly property real panelOpacity: root.settings ? root.settings.wallpaperPickerOpacity / 100 : 0.97
    readonly property int tileRadius: root.settings ? root.settings.wallpaperTileRadius : 18
    readonly property int tileBorderWidth: root.settings ? root.settings.wallpaperTileBorderWidth : 2
    readonly property color tileBorderColor: root.settings && root.settings.wallpaperTileBorderColor.length > 0
        ? root.settings.wallpaperTileBorderColor
        : root.accentColor
    readonly property int zoomPercent: root.settings ? root.settings.wallpaperZoomPercent : 8

    Variants {
        model: root.wallpaper && root.wallpaper.pickerOpen ? [1] : []

        delegate: Component {
            PanelWindow {
                id: overlay

                readonly property var targetScreen: {
                    const screens = Quickshell.screens;
                    if (!screens || screens.length === 0)
                        return null;
                    const focused = root.wallpaper ? root.wallpaper.focusedMonitor : "";
                    for (let i = 0; i < screens.length; ++i) {
                        if (screens[i].name === focused)
                            return screens[i];
                    }
                    return screens[0];
                }

                readonly property int panelWidth: Math.round(Math.min(width - 120, 1180))
                readonly property int panelHeight: Math.round(Math.min(height - 100, 760))
                readonly property int columns: Math.max(2, Math.floor(overlay.panelWidth / 250))
                readonly property string layoutName: root.layoutName
                readonly property bool vimKeys: root.vimKeys

                screen: overlay.targetScreen
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                color: Qt.rgba(0, 0, 0, 0.55)
                exclusiveZone: -1
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "maneso-wallpaper-picker"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                function move(delta) {
                    if (!root.wallpaper)
                        return;
                    const count = root.wallpaper.files.length;
                    if (count === 0)
                        return;
                    root.wallpaper.pickerIndex = (root.wallpaper.pickerIndex + delta + count) % count;
                }

                function applySelection() {
                    if (!root.wallpaper)
                        return;
                    const files = root.wallpaper.files;
                    const index = root.wallpaper.pickerIndex;
                    if (index < 0 || index >= files.length)
                        return;
                    root.wallpaper.setPath(files[index]);
                    root.wallpaper.pickerOpen = false;
                }

                function jumpFirst() {
                    if (root.wallpaper)
                        root.wallpaper.pickerIndex = 0;
                }

                function jumpLast() {
                    if (root.wallpaper)
                        root.wallpaper.pickerIndex = Math.max(0, root.wallpaper.files.length - 1);
                }

                function verticalStep() {
                    return overlay.layoutName === "grid" ? overlay.columns : 1;
                }

                // Keys must live on an Item; a layer surface is not one.
                FocusScope {
                    anchors.fill: parent
                    focus: true
                    Keys.onEscapePressed: root.wallpaper.pickerOpen = false
                    Keys.onReturnPressed: overlay.applySelection()
                    Keys.onEnterPressed: overlay.applySelection()
                    Keys.onLeftPressed: overlay.move(-1)
                    Keys.onRightPressed: overlay.move(1)
                    Keys.onUpPressed: overlay.move(overlay.layoutName === "grid" ? -overlay.columns : -1)
                    Keys.onDownPressed: overlay.move(overlay.layoutName === "grid" ? overlay.columns : 1)
                    // Optional vim bindings: h/l step, j/k move a row, g/G jump to the ends.
                    Keys.onPressed: event => {
                        if (!overlay.vimKeys)
                            return;
                        if (event.key === Qt.Key_H) {
                            overlay.move(-1);
                        } else if (event.key === Qt.Key_L) {
                            overlay.move(1);
                        } else if (event.key === Qt.Key_J) {
                            overlay.move(overlay.verticalStep());
                        } else if (event.key === Qt.Key_K) {
                            overlay.move(-overlay.verticalStep());
                        } else if (event.key === Qt.Key_G) {
                            if (event.modifiers & Qt.ShiftModifier)
                                overlay.jumpLast();
                            else
                                overlay.jumpFirst();
                        } else if (event.key === Qt.Key_Q) {
                            root.wallpaper.pickerOpen = false;
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }

                // Clicking the dim area closes the picker.
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.wallpaper.pickerOpen = false
                }

                Rectangle {
                    id: panel

                    anchors.centerIn: parent
                    width: overlay.panelWidth
                    height: overlay.panelHeight
                    radius: 20
                    color: Qt.rgba(root.bgColor.r, root.bgColor.g, root.bgColor.b, root.panelOpacity)
                    border.width: 1
                    border.color: Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.9)

                    // Swallow clicks so they do not reach the dim area.
                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Item {
                            id: header

                            width: parent.width
                            height: 34

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Wallpaper"
                                color: root.fgColor
                                font.family: root.monoFont
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 96
                                anchors.verticalCenter: parent.verticalCenter
                                text: (root.wallpaper ? root.wallpaper.files.length : 0) + " images"
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: 9
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: overlay.layoutName.toUpperCase()
                                    + (overlay.vimKeys ? "  ·  hjkl move  ·  g/G ends  ·  enter apply  ·  esc close"
                                                       : "  ·  ←/→ select  ·  enter apply  ·  esc close")
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: 8
                            }
                        }

                        Loader {
                            id: layoutLoader

                            width: parent.width
                            height: parent.height - header.height - footer.height - 24
                            sourceComponent: root.layoutName === "grid"
                                ? gridComponent
                                : (root.layoutName === "spotlight" ? spotlightComponent : carouselComponent)

                            onLoaded: root.syncLayout()

                            Component {
                                id: carouselComponent

                                WallpaperLayoutCarousel {
                                    tileRadius: root.tileRadius
                                    tileBorderWidth: root.tileBorderWidth
                                    tileBorderColor: root.tileBorderColor
                                    zoomPercent: root.zoomPercent
                                    files: root.wallpaper ? root.wallpaper.files : []
                                    index: root.wallpaper ? root.wallpaper.pickerIndex : 0
                                    currentPath: root.wallpaper ? root.wallpaper.currentPath : ""
                                    thumbnails: root.thumbnails
                                    monoFont: root.monoFont
                                    fgColor: root.fgColor
                                    mutedColor: root.mutedColor
                                    accentColor: root.accentColor
                                    onAccentColor: root.onAccentColor
                                    surfaceHighColor: root.surfaceHighColor
                                    onSelected: path => root.selectPath(path)
                                    onActivated: path => root.applyPath(path)
                                }
                            }

                            Component {
                                id: gridComponent

                                WallpaperLayoutGrid {
                                    tileRadius: root.tileRadius
                                    tileBorderWidth: root.tileBorderWidth
                                    tileBorderColor: root.tileBorderColor
                                    files: root.wallpaper ? root.wallpaper.files : []
                                    index: root.wallpaper ? root.wallpaper.pickerIndex : 0
                                    currentPath: root.wallpaper ? root.wallpaper.currentPath : ""
                                    thumbnails: root.thumbnails
                                    monoFont: root.monoFont
                                    fgColor: root.fgColor
                                    mutedColor: root.mutedColor
                                    accentColor: root.accentColor
                                    onAccentColor: root.onAccentColor
                                    surfaceHighColor: root.surfaceHighColor
                                    onSelected: path => root.selectPath(path)
                                    onActivated: path => root.applyPath(path)
                                }
                            }

                            Component {
                                id: spotlightComponent

                                WallpaperLayoutSpotlight {
                                    tileRadius: root.tileRadius
                                    tileBorderWidth: root.tileBorderWidth
                                    tileBorderColor: root.tileBorderColor
                                    files: root.wallpaper ? root.wallpaper.files : []
                                    index: root.wallpaper ? root.wallpaper.pickerIndex : 0
                                    currentPath: root.wallpaper ? root.wallpaper.currentPath : ""
                                    thumbnails: root.thumbnails
                                    monoFont: root.monoFont
                                    fgColor: root.fgColor
                                    mutedColor: root.mutedColor
                                    accentColor: root.accentColor
                                    onAccentColor: root.onAccentColor
                                    surfaceHighColor: root.surfaceHighColor
                                    onSelected: path => root.selectPath(path)
                                    onActivated: path => root.applyPath(path)
                                }
                            }
                        }

                        Item {
                            id: footer

                            width: parent.width
                            height: 26

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.wallpaper && root.wallpaper.currentPath.length > 0
                                    ? "Showing " + root.wallpaper.currentPath.slice(root.wallpaper.currentPath.lastIndexOf("/") + 1)
                                    : "No wallpaper applied yet"
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: 8
                                elide: Text.ElideMiddle
                                width: parent.width - 260
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8

                                Repeater {
                                    model: [
                                        { "key": "carousel", "label": "Carousel" },
                                        { "key": "grid", "label": "Grid" },
                                        { "key": "spotlight", "label": "Spotlight" }
                                    ]

                                    delegate: Rectangle {
                                        id: layoutChip

                                        required property var modelData

                                        width: 74
                                        height: 22
                                        radius: 6
                                        color: overlay.layoutName === layoutChip.modelData.key
                                            ? root.accentColor
                                            : Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.6)

                                        Text {
                                            anchors.centerIn: parent
                                            text: layoutChip.modelData.label
                                            color: overlay.layoutName === layoutChip.modelData.key ? root.onAccentColor : root.mutedColor
                                            font.family: root.monoFont
                                            font.pixelSize: 8
                                            font.weight: Font.DemiBold
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.settings)
                                                    root.settings.wallpaperPickerLayout = root.settings.clampWallpaperPickerLayout(layoutChip.modelData.key);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function selectPath(path) {
        if (!root.wallpaper)
            return;
        const index = root.wallpaper.files.indexOf(path);
        if (index >= 0)
            root.wallpaper.pickerIndex = index;
    }

    function applyPath(path) {
        if (!root.wallpaper)
            return;
        root.wallpaper.setPath(path);
        root.wallpaper.pickerOpen = false;
    }

    function syncLayout() {
        if (root.wallpaper && root.wallpaper.pickerIndex < 0)
            root.wallpaper.pickerIndex = 0;
    }
}
