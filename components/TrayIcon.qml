import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root

    property var trayItem
    property var host
    property bool compact: false

    readonly property int iconSize: root.compact ? 15 : 16
    readonly property bool menuAvailable: root.trayItem && root.trayItem.hasMenu

    function openMenu() {
        if (root.menuAvailable)
            trayMenu.open();
    }

    implicitWidth: root.compact ? 15 : 18
    implicitHeight: root.compact ? 15 : 18

    Image {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: root.host ? root.host.trayIconSource(root.trayItem) : ""
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (!root.trayItem)
                return;

            if (mouse.button === Qt.MiddleButton) {
                root.trayItem.secondaryActivate();
                return;
            }

            if (mouse.button === Qt.RightButton || root.trayItem.onlyMenu) {
                root.openMenu();
                return;
            }

            root.trayItem.activate();
        }

        onWheel: wheel => {
            if (root.trayItem)
                root.trayItem.scroll(wheel.angleDelta.y, wheel.angleDelta.x !== 0);
        }
    }

    QsMenuAnchor {
        id: trayMenu
        menu: root.trayItem ? root.trayItem.menu : null
        anchor.window: root.host ? root.host.panelWindow : null
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
    }
}
