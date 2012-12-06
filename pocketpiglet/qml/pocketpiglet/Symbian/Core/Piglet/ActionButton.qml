import QtQuick 1.1

Image {
    id: actionButton

    property bool actionActive:  false
    property bool actionValid:   false

    property url sourceNormal:   ""
    property url sourceDisabled: ""

    signal startAction()

    onActionActiveChanged: {
        if (!actionActive && actionValid) {
            source                        = sourceNormal;
            actionButtonMouseArea.enabled = true;
        }
    }

    onActionValidChanged: {
        if (actionValid) {
            source                        = sourceDisabled;
            actionButtonMouseArea.enabled = false;
        }
    }

    MouseArea {
        id:           actionButtonMouseArea
        anchors.fill: parent

        onClicked: {
            actionButton.actionValid = false;

            actionButton.startAction();
        }
    }

    Component.onCompleted: {
        source = sourceNormal;
    }
}
