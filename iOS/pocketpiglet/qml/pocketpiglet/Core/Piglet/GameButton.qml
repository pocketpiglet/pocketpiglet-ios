import QtQuick 2.6

Image {
    id: gameButton

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal startGame()

    function highlightButton() {
        source = sourceHighlighted;
    }

    function unhighlightButton() {
        source = sourceNormal;
    }

    MouseArea {
        id:           gameButtonMouseArea
        anchors.fill: parent

        onClicked: {
            gameButton.startGame();
        }
    }

    Component.onCompleted: {
        source = sourceNormal;
    }
}
