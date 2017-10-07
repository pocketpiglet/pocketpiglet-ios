import QtQuick 2.6

Image {
    id: actionButton

    signal startAction()

    MouseArea {
        id:           actionButtonMouseArea
        anchors.fill: parent

        onClicked: {
            actionButton.startAction();
        }
    }
}