import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    signal monitorsLine(string line)
    signal keyboardLine(string line)

    readonly property string socketPath: Quickshell.env("MANGO_INSTANCE_SIGNATURE") || ""
    property string pendingCommand: ""
    property string version: ""
    property bool versionRequested: false

    function consumeCommand(line) {
        try {
            const data = JSON.parse(line);
            if (data && typeof data.version === "string")
                root.version = data.version;
        } catch (error) {
        }
    }

    function sendCommand(command) {
        if (root.socketPath.length === 0)
            return;
        root.pendingCommand = command;
        if (commandSocket.connected) {
            commandSocket.write(command + "\n");
            commandSocket.flush();
            root.pendingCommand = "";
        } else {
            commandSocket.connected = true;
        }
    }

    Socket {
        id: monitorSocket
        path: root.socketPath
        connected: root.socketPath.length > 0
        parser: SplitParser {
            onRead: line => root.monitorsLine(line)
        }

        onConnectionStateChanged: {
            if (connected) {
                monitorRetry.stop();
                monitorSocket.write("watch all-monitors\n");
                monitorSocket.flush();
            } else if (root.socketPath.length > 0) {
                monitorRetry.restart();
            }
        }
    }

    Socket {
        id: keyboardSocket
        path: root.socketPath
        connected: root.socketPath.length > 0
        parser: SplitParser {
            onRead: line => root.keyboardLine(line)
        }

        onConnectionStateChanged: {
            if (connected) {
                keyboardRetry.stop();
                keyboardSocket.write("watch keyboardlayout\n");
                keyboardSocket.flush();
            } else if (root.socketPath.length > 0) {
                keyboardRetry.restart();
            }
        }
    }

    Socket {
        id: commandSocket
        path: root.socketPath
        connected: root.socketPath.length > 0
        parser: SplitParser {
            onRead: line => root.consumeCommand(line)
        }

        onConnectionStateChanged: {
            if (connected) {
                commandRetry.stop();
                if (!root.versionRequested) {
                    root.versionRequested = true;
                    commandSocket.write("get version\n");
                    commandSocket.flush();
                }
                if (root.pendingCommand.length > 0) {
                    commandSocket.write(root.pendingCommand + "\n");
                    commandSocket.flush();
                    root.pendingCommand = "";
                }
            } else if (root.pendingCommand.length > 0 && root.socketPath.length > 0) {
                commandRetry.restart();
            }
        }
    }

    Timer {
        id: monitorRetry
        interval: 1000
        onTriggered: monitorSocket.connected = true
    }

    Timer {
        id: keyboardRetry
        interval: 1000
        onTriggered: keyboardSocket.connected = true
    }

    Timer {
        id: commandRetry
        interval: 1000
        onTriggered: commandSocket.connected = true
    }
}
