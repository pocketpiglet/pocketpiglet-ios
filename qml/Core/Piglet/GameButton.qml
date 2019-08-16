import QtQuick 2.12

Image {
    id:     gameButton
    source: sourceNormal

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal startGame()

    function highlightButton() {
        source = Qt.binding(function() { return gameButton.sourceHighlighted; });
    }

    function unhighlightButton() {
        source = Qt.binding(function() { return gameButton.sourceNormal; });
    }

    MouseArea {
        id:           gameButtonMouseArea
        anchors.fill: parent

        onClicked: {
            gameButton.startGame();
        }
    }
}
