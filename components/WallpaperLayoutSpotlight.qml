import QtQuick

// One large preview of the selection with a thumbnail strip underneath.
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

    signal selected(string path)
    signal activated(string path)

    readonly property string selectedPath: layout.index >= 0 && layout.index < layout.files.length
        ? layout.files[layout.index] : ""
    readonly property string selectedName: {
        const slash = layout.selectedPath.lastIndexOf("/");
        return slash >= 0 ? layout.selectedPath.slice(slash + 1) : layout.selectedPath;
    }
    readonly property bool selectedIsApplied: layout.selectedPath === layout.currentPath

    Rectangle {
        id: stage

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: strip.top
        anchors.bottomMargin: 12
        radius: layout.tileRadius
        color: Qt.rgba(layout.surfaceHighColor.r, layout.surfaceHighColor.g, layout.surfaceHighColor.b, 0.55)
        clip: true

        Image {
            id: hero

            anchors.fill: parent
            anchors.margins: 1
            source: layout.selectedPath.length > 0
                ? "file://" + layout.selectedPath
                : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            color: Qt.rgba(0, 0, 0, 0.55)

            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: Text.AlignVCenter
                text: layout.selectedName + (layout.selectedIsApplied ? "  ·  applied" : "  ·  enter to apply")
                color: layout.fgColor
                font.family: layout.monoFont
                font.pixelSize: 9
                elide: Text.ElideMiddle
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (layout.selectedPath.length > 0)
                layout.activated(layout.selectedPath)
        }
    }

    ListView {
        id: strip

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 96
        orientation: ListView.Horizontal
        model: layout.files
        currentIndex: layout.index
        spacing: 8
        clip: true
        cacheBuffer: 600
        highlightMoveDuration: 120

        onCurrentIndexChanged: {
            if (currentIndex >= 0 && currentIndex < layout.files.length && currentIndex !== layout.index)
                layout.selected(layout.files[currentIndex]);
        }

        delegate: Item {
            id: stripCell

            required property int index
            required property string modelData

            width: 150
            height: strip.height

            WallpaperTile {
                anchors.fill: parent
                radius: layout.tileRadius
                borderWidth: layout.tileBorderWidth
                borderColor: layout.tileBorderColor
                source: stripCell.modelData
                applied: stripCell.modelData === layout.currentPath
                selected: stripCell.index === layout.index
                thumbnails: layout.thumbnails
                monoFont: layout.monoFont
                fgColor: layout.fgColor
                mutedColor: layout.mutedColor
                accentColor: layout.accentColor
                onAccentColor: layout.onAccentColor
                surfaceHighColor: layout.surfaceHighColor
                onActivated: layout.selected(stripCell.modelData)
            }
        }
    }
}
