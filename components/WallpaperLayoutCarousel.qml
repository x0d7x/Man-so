import QtQuick

// Centred carousel: the selected tile is enlarged, neighbours stay visible.
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
    property int zoomPercent: 8

    readonly property int baseWidth: 300
    readonly property int baseHeight: 220
    readonly property int currentWidth: Math.round(baseWidth * (1 + layout.zoomPercent / 100))
    readonly property int currentHeight: Math.round(baseHeight * (1 + layout.zoomPercent / 100))

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

    ListView {
        id: view

        anchors.fill: parent
        orientation: ListView.Horizontal
        model: layout.files
        currentIndex: layout.index
        spacing: 14
        clip: true
        cacheBuffer: 1200
        highlightMoveDuration: 160
        preferredHighlightBegin: width / 2 - layout.currentWidth / 2
        preferredHighlightEnd: width / 2 + layout.currentWidth / 2
        highlightRangeMode: ListView.StrictlyEnforceRange

        onCurrentIndexChanged: {
            if (!layout.settled)
                return;
            if (currentIndex >= 0 && currentIndex < layout.files.length && currentIndex !== layout.index)
                layout.selected(layout.files[currentIndex]);
        }

        delegate: WallpaperTile {
            id: carouselTile

            required property int index
            required property string modelData

            width: ListView.isCurrentItem ? layout.currentWidth : layout.baseWidth
            height: ListView.isCurrentItem ? layout.currentHeight : layout.baseHeight
            y: (view.height - height) / 2
            radius: layout.tileRadius
            borderWidth: layout.tileBorderWidth
            borderColor: layout.tileBorderColor
            source: carouselTile.modelData
            applied: carouselTile.modelData === layout.currentPath
            selected: ListView.isCurrentItem
            thumbnails: layout.thumbnails
            monoFont: layout.monoFont
            fgColor: layout.fgColor
            mutedColor: layout.mutedColor
            accentColor: layout.accentColor
            onAccentColor: layout.onAccentColor
            surfaceHighColor: layout.surfaceHighColor
            onActivated: layout.activated(carouselTile.modelData)

            Behavior on width {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }
            Behavior on height {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }
        }
    }

    // Clicking the empty area either side steps through the carousel.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        onPressed: mouse => mouse.accepted = false
        onWheel: wheel => wheel.accepted = false
    }
}
