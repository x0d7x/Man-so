import Quickshell
import Quickshell.Services.Polkit
import QtQuick

// Registers maneso as a polkit authentication agent when enabled.
// The agent only exists while enabled: two registered agents for the same session
// would compete, so this stays off unless the user replaces their current agent.
Scope {
    id: root

    property bool enabled: false
    property var agent: null

    readonly property bool registered: root.agent ? root.agent.isRegistered : false
    readonly property bool isActive: root.agent ? root.agent.isActive : false
    readonly property var flow: root.agent ? root.agent.flow : null

    // Convenience passthroughs so the island does not have to null-check the flow.
    readonly property string message: root.flow ? root.flow.message : ""
    readonly property string actionId: root.flow ? root.flow.actionId : ""
    readonly property string inputPrompt: root.flow ? root.flow.inputPrompt : ""
    readonly property string supplementaryMessage: root.flow ? root.flow.supplementaryMessage : ""
    readonly property bool supplementaryIsError: root.flow ? root.flow.supplementaryIsError : false
    readonly property bool responseRequired: root.flow ? root.flow.isResponseRequired : false
    readonly property bool responseVisible: root.flow ? root.flow.responseVisible : false
    readonly property bool failed: root.flow ? root.flow.failed : false

    function submit(value) {
        if (root.flow)
            root.flow.submit(String(value));
    }

    function cancel() {
        if (root.flow)
            root.flow.cancelAuthenticationRequest();
    }

    onEnabledChanged: {
        if (!root.enabled)
            root.agent = null;
    }

    Variants {
        model: root.enabled ? [1] : []

        delegate: Component {
            PolkitAgent {
                path: "/org/quickshell/Polkit"

                Component.onCompleted: root.agent = this
            }
        }
    }
}
