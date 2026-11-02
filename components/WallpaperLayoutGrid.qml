import QtQuick

// Multi-row grid of thumbnails.
Item {
    id: layout

    property var files: []
    property int index: 0
    property string currentPath: ""
    property var thumbnails
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor
    property int tileRadius: 18
    property int tileBorderWidth: 2
    property color tileBorderColor: accentColor

    readonly property int columns: Math.max(2, Math.floor(width / 250))
    readonly property int cellWidth: Math.floor(width / layout.columns)
    // Whole rows only: pick a row count that fits, then divide the height by it.
    readonly property int rows: Math.max(2, Math.round(height / 230))
    readonly property int cellHeight: Math.floor(height / layout.rows)

    signal selected(string path)
    signal activated(string path)

    // Ignore the selection change the view makes while it settles its first layout,
    // which would otherwise move the ring off the applied image when opening.
    property bool settled: false

    Timer {
        interval: 300
        running: true
        onTriggered: layout.settled = true
    }

    GridView {
        id: view

        anchors.fill: parent
        cellWidth: layout.cellWidth
        cellHeight: layout.cellHeight
        model: layout.files
        currentIndex: layout.index
        clip: true
        cacheBuffer: 600
        highlightMoveDuration: 120
        // Keep the current tile centred; partial rows at the edges are expected.
        highlightRangeMode: GridView.StrictlyEnforceRange
        preferredHighlightBegin: height / 2 - layout.cellHeight / 2
        preferredHighlightEnd: height / 2 + layout.cellHeight / 2

        onCurrentIndexChanged: {
            if (!layout.settled)
                return;
            if (currentIndex >= 0 && currentIndex < layout.files.length && currentIndex !== layout.index)
                layout.selected(layout.files[currentIndex]);
        }

        delegate: Item {
            id: cell

            required property int index
            required property string modelData

            width: view.cellWidth
            height: view.cellHeight

            WallpaperTile {
                anchors.fill: parent
                anchors.margins: 6
                radius: layout.tileRadius
                borderWidth: layout.tileBorderWidth
                borderColor: layout.tileBorderColor
                source: cell.modelData
                applied: cell.modelData === layout.currentPath
                selected: cell.index === layout.index
                thumbnails: layout.thumbnails
                monoFont: layout.monoFont
                fgColor: layout.fgColor
                mutedColor: layout.mutedColor
                accentColor: layout.accentColor
                onAccentColor: layout.onAccentColor
                surfaceHighColor: layout.surfaceHighColor
                onActivated: {
                    layout.selected(cell.modelData);
                    layout.activated(cell.modelData);
                }
            }
        }
    }
}
