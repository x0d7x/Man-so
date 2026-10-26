import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    property var media
    property string monoFont
    property color bgColor
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color accentColor
    property color secondaryColor
    property color onAccentColor
    property color errorColor
    property color borderMutedColor

    radius: 16
    color: Qt.rgba(card.bgColor.r, card.bgColor.g, card.bgColor.b, 0.98)
    border.width: 1
    border.color: card.accentColor
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            radius: 12
            color: card.surfaceHighColor
            clip: true

            Image {
                id: artworkImage
                anchors.fill: parent
                source: card.media ? card.media.artwork : ""
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: card.media && card.media.artwork.length > 0 && status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !artworkImage.visible
                text: "󰎆"
                color: card.mutedColor
                font.family: card.monoFont
                font.pixelSize: 30
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: card.media ? card.media.title : ""
                    color: card.fgColor
                    font.family: card.monoFont
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    text: card.media && card.media.isPlaying ? "PLAYING" : "PAUSED"
                    color: card.media && card.media.isPlaying ? card.secondaryColor : card.mutedColor
                    font.family: card.monoFont
                    font.pixelSize: 8
                    font.weight: Font.DemiBold
                }
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (!card.media)
                        return "";
                    if (card.media.artist.length > 0)
                        return card.media.artist;
                    return card.media.appName;
                }
                color: card.mutedColor
                font.family: card.monoFont
                font.pixelSize: 9
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: card.media && card.media.length > 0

                Text {
                    text: card.media ? card.media.positionText : "0:00"
                    color: card.borderMutedColor
                    font.family: card.monoFont
                    font.pixelSize: 8
                }

                Rectangle {
                    id: progressTrack

                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    radius: 2
                    color: card.surfaceHighColor

                    Rectangle {
                        width: parent.width * (card.media ? card.media.progress : 0)
                        height: parent.height
                        radius: parent.radius
                        color: card.accentColor

                        Behavior on width {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (card.media)
                                card.media.seekTo(mouse.x / width);
                        }
                    }
                }

                Text {
                    text: card.media ? card.media.lengthText : "0:00"
                    color: card.borderMutedColor
                    font.family: card.monoFont
                    font.pixelSize: 8
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    opacity: card.media && card.media.canPrevious ? 1 : 0.35

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        color: card.fgColor
                        font.family: card.monoFont
                        font.pixelSize: 15
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.media)
                                card.media.previous();
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 24
                    radius: 7
                    color: card.accentColor

                    Text {
                        anchors.centerIn: parent
                        text: card.media && card.media.isPlaying ? "󰏤" : "󰐊"
                        color: card.onAccentColor
                        font.family: card.monoFont
                        font.pixelSize: 15
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.media)
                                card.media.togglePlaying();
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    opacity: card.media && card.media.canNext ? 1 : 0.35

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        color: card.fgColor
                        font.family: card.monoFont
                        font.pixelSize: 15
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.media)
                                card.media.next();
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
