import QtQuick
import QtQuick.Layouts

Item {
    id: page

    property var settings
    property var wallpaper
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor

    readonly property string backend: page.settings ? page.settings.wallpaperBackend : "awww"
    readonly property bool isAwww: page.backend === "awww"
    readonly property bool isCommand: page.backend === "command"
    readonly property var hooks: page.settings && page.settings.wallpaperHooks ? page.settings.wallpaperHooks : []

    readonly property var backendOptions: [
        { "key": "awww", "label": "awww" },
        { "key": "command", "label": "command" }
    ]
    readonly property var fitOptions: [
        { "key": "fill", "label": "Fill" },
        { "key": "fit", "label": "Fit" },
        { "key": "stretch", "label": "Stretch" },
        { "key": "center", "label": "Center" },
        { "key": "tile", "label": "Tile" }
    ]
    readonly property var targetOptions: [
        { "key": "all", "label": "All" },
        { "key": "focused", "label": "Focused" }
    ]
    readonly property var transitionOptions: [
        { "key": "none", "label": "None" },
        { "key": "fade", "label": "Fade" },
        { "key": "wipe", "label": "Wipe" },
        { "key": "grow", "label": "Grow" },
        { "key": "random", "label": "Random" }
    ]

    readonly property string currentName: {
        if (!page.wallpaper || !page.wallpaper.currentPath)
            return "none yet";
        const path = String(page.wallpaper.currentPath);
        const slash = path.lastIndexOf("/");
        return slash >= 0 ? path.slice(slash + 1) : path;
    }

    function addHook(text) {
        if (!page.settings)
            return;
        const hook = String(text).trim();
        if (hook.length === 0)
            return;
        const list = page.hooks.slice();
        list.push(hook);
        page.settings.wallpaperHooks = page.settings.sanitizeWallpaperHooks(list);
    }

    function removeHook(index) {
        if (!page.settings)
            return;
        const list = page.hooks.slice();
        list.splice(index, 1);
        page.settings.wallpaperHooks = page.settings.sanitizeWallpaperHooks(list);
    }

    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 7

            Text {
                text: "Wallpaper"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Backend, layout and rotation. Matugen and the Veila lock image follow the applied wallpaper."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Text {
                text: "BACKEND"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsChoiceRow {
                Layout.fillWidth: true
                label: "Render with"
                options: page.backendOptions
                value: page.backend
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onSelected: key => {
                    if (page.settings)
                        page.settings.wallpaperBackend = page.settings.clampWallpaperBackend(key);
                }
            }

            Text {
                Layout.fillWidth: true
                text: page.isCommand
                    ? "Runs your command with {path} replaced by the selected image."
                    : "awww draws the wallpaper in the background layer and keeps it across maneso restarts."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            SettingsTextRow {
                Layout.fillWidth: true
                label: "Wallpaper folder"
                description: "Absolute path or ~/... path. Scanned on demand, never polled."
                value: page.settings ? page.settings.wallpaperDirectory : ""
                placeholder: "~/Documents/wallpaper"
                maximumLength: 255
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onCommitted: text => {
                    if (page.settings)
                        page.settings.wallpaperDirectory = page.settings.clampWallpaperDirectory(text);
                }
            }

            SettingsChoiceRow {
                Layout.fillWidth: true
                label: "Layout"
                options: page.fitOptions
                value: page.settings ? page.settings.wallpaperFit : "fill"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onSelected: key => {
                    if (page.settings)
                        page.settings.wallpaperFit = page.settings.clampWallpaperFit(key);
                }
            }

            SettingsChoiceRow {
                Layout.fillWidth: true
                label: "Apply to"
                options: page.targetOptions
                value: page.settings ? page.settings.wallpaperTarget : "all"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onSelected: key => {
                    if (page.settings)
                        page.settings.wallpaperTarget = page.settings.clampWallpaperTarget(key);
                }
            }

            SettingsTextRow {
                Layout.fillWidth: true
                visible: page.isCommand
                label: "Command"
                description: "{path} is replaced with the quoted image path. Exit code 0 means success."
                value: page.settings ? page.settings.wallpaperCommand : ""
                placeholder: "swaybg -i {path}"
                maximumLength: 500
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onCommitted: text => {
                    if (page.settings)
                        page.settings.wallpaperCommand = page.settings.clampWallpaperCommand(text);
                }
            }

            Text {
                visible: page.isAwww
                text: "TRANSITION"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsChoiceRow {
                Layout.fillWidth: true
                visible: page.isAwww
                label: "Effect"
                options: page.transitionOptions
                value: page.settings ? page.settings.wallpaperTransition : "fade"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onSelected: key => {
                    if (page.settings)
                        page.settings.wallpaperTransition = page.settings.clampWallpaperTransition(key);
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                visible: page.isAwww
                label: "Transition duration"
                value: page.settings ? page.settings.wallpaperTransitionDuration : 1
                from: 0
                to: 5
                step: 1
                suffix: " s"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.wallpaperTransitionDuration = page.settings.clampWallpaperTransitionDuration(value);
                }
            }

            Text {
                text: "ROTATION"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Shuffle every"
                value: page.settings ? page.settings.wallpaperRotateMinutes : 0
                from: 0
                to: 120
                step: 5
                suffix: page.settings && page.settings.wallpaperRotateMinutes === 0 ? " (off)" : " min"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.wallpaperRotateMinutes = page.settings.clampWallpaperRotateMinutes(value);
                }
            }

            Text {
                text: "HOOKS"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Generate colors"
                description: "Run matugen on the new image so maneso and the other templates follow it."
                checked: page.settings ? page.settings.wallpaperMatugen : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.wallpaperMatugen = !page.settings.wallpaperMatugen;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Sync Veila lock image"
                description: "Copy the wallpaper to ~/.cache/veila/wallpaper.jpg so the lock screen matches."
                checked: page.settings ? page.settings.wallpaperVeilaSync : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.wallpaperVeilaSync = !page.settings.wallpaperVeilaSync;
                }
            }

            Repeater {
                model: page.hooks

                delegate: Rectangle {
                    id: hookRow

                    required property int index
                    required property string modelData

                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 7
                    color: Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4)

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 9
                        anchors.right: removeButton.left
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: hookRow.modelData
                        color: page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 8
                        elide: Text.ElideMiddle
                    }

                    Rectangle {
                        id: removeButton

                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        radius: 5
                        color: removeHover.hovered
                            ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.25)
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: removeHover.hovered ? page.accentColor : page.mutedColor
                            font.family: page.monoFont
                            font.pixelSize: 9
                        }

                        HoverHandler {
                            id: removeHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.removeHook(hookRow.index)
                        }
                    }
                }
            }

            SettingsTextRow {
                Layout.fillWidth: true
                label: "Add hook"
                description: "Optional command run after each change; {path} is replaced."
                value: ""
                placeholder: "e.g. notify-send wallpaper {path}"
                maximumLength: 500
                clearAfterCommit: true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onCommitted: text => page.addHook(text)
            }

            Text {
                text: "NOW"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            Text {
                Layout.fillWidth: true
                text: "Showing " + page.currentName
                    + (page.wallpaper && page.wallpaper.files ? " · " + page.wallpaper.files.length + " images" : "")
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: page.wallpaper && page.wallpaper.lastError.length > 0
                text: page.wallpaper ? page.wallpaper.lastError : ""
                color: page.settings ? page.accentColor : page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.preferredWidth: 92
                    Layout.preferredHeight: 28
                    radius: 7
                    color: shuffleHover.hovered
                        ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.2)
                        : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                    Text {
                        anchors.centerIn: parent
                        text: "SHUFFLE"
                        color: shuffleHover.hovered ? page.accentColor : page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 7
                        font.weight: Font.Bold
                    }

                    HoverHandler {
                        id: shuffleHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (page.wallpaper) page.wallpaper.randomWallpaper()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 76
                    Layout.preferredHeight: 28
                    radius: 7
                    color: reloadHover.hovered
                        ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.2)
                        : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                    Text {
                        anchors.centerIn: parent
                        text: "RELOAD"
                        color: reloadHover.hovered ? page.accentColor : page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 7
                        font.weight: Font.Bold
                    }

                    HoverHandler {
                        id: reloadHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (page.wallpaper) page.wallpaper.refresh()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 128
                    Layout.preferredHeight: 28
                    radius: 7
                    color: restoreHover.hovered
                        ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.2)
                        : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                    Text {
                        anchors.centerIn: parent
                        text: "RESTORE DEFAULTS"
                        color: restoreHover.hovered ? page.accentColor : page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 7
                        font.weight: Font.Bold
                    }

                    HoverHandler {
                        id: restoreHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (page.settings) page.settings.resetWallpaper()
                    }
                }
            }
        }
    }
}
