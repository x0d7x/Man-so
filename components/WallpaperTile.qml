import QtQuick
import QtQuick.Effects

// One wallpaper thumbnail. Requests its own thumbnail on creation, so only the
// delegates a layout actually instantiates are ever generated.
Item {
    id: tile

    property string source: ""
    property bool applied: false
    property bool selected: false
    property var thumbnails
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor
    property real radius: 14
    property int borderWidth: 2
    property color borderColor: accentColor

    signal activated()

    readonly property string thumb: tile.thumbnails ? tile.thumbnails.thumbPath(tile.source) : ""
    readonly property bool thumbReady: tile.thumbnails ? tile.thumbnails.has(tile.source) : false
    readonly property string fileName: {
        const slash = tile.source.lastIndexOf("/");
        return slash >= 0 ? tile.source.slice(slash + 1) : tile.source;
    }

    property int revision: 0

    function refresh() {
        tile.revision += 1;
    }

    Component.onCompleted: if (tile.thumbnails)
        tile.thumbnails.request(tile.source);

    Connections {
        target: tile.thumbnails

        function onReady(source) {
            if (source === tile.source)
                tile.refresh();
        }
    }

    Rectangle {
        id: frame

        anchors.fill: parent
        radius: tile.radius
        color: Qt.rgba(tile.surfaceHighColor.r, tile.surfaceHighColor.g, tile.surfaceHighColor.b, 0.55)
        border.width: tile.selected ? tile.borderWidth : (tile.applied ? Math.max(1, tile.borderWidth - 1) : 0)
        border.color: tile.borderColor
        clip: true

        // clip: true only clips to the bounding box, so the content is masked by a
        // rounded rectangle to keep the corners round.
        Item {
            id: content

            anchors.fill: parent
            anchors.margins: frame.border.width
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: cornerMask
            }

            Image {
                id: preview

                anchors.fill: parent
                source: tile.thumbReady && tile.revision >= 0 ? "file://" + tile.thumb + "?r=" + tile.revision : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(Math.round(width * 2), Math.round(height * 2))
                asynchronous: true
                cache: false
                smooth: true
                visible: status === Image.Ready
            }

            // Placeholder while the thumbnail is being generated.
            Text {
                anchors.centerIn: parent
                visible: !preview.visible
                text: "󰸉"
                color: tile.mutedColor
                font.family: tile.monoFont
                font.pixelSize: Math.max(16, Math.min(width, height) * 0.22)
            }

            // Filename strip along the bottom.
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Math.min(26, parent.height * 0.28)
                color: Qt.rgba(0, 0, 0, 0.55)

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    text: tile.fileName
                    color: tile.fgColor
                    font.family: tile.monoFont
                    font.pixelSize: 8
                    elide: Text.ElideMiddle
                }
            }
        }

        // Applied marker sits above the masked content so its circle stays crisp.
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6 + frame.border.width
            visible: tile.applied
            width: 18
            height: 18
            radius: 9
            color: tile.accentColor

            Text {
                anchors.centerIn: parent
                text: "󰄬"
                color: tile.onAccentColor
                font.family: tile.monoFont
                font.pixelSize: 9
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.activated()
        }
    }

    Rectangle {
        id: cornerMask

        anchors.fill: parent
        radius: Math.max(0, tile.radius - frame.border.width)
        color: "white"
        visible: false
        layer.enabled: true
    }
}
