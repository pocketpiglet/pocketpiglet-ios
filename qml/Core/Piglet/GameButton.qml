import QtQuick 2.12

Rectangle {
    id:    gameButton
    color: "transparent"

    property bool highlighted:      false

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal clicked()

    Image {
        id:           normalImage
        anchors.fill: parent
        source:       gameButton.sourceNormal
        fillMode:     Image.PreserveAspectFit
    }

    Image {
        id:           highlightedImage
        anchors.fill: parent
        z:            1
        source:       gameButton.sourceHighlighted
        fillMode:     Image.PreserveAspectFit
        visible:      gameButton.highlighted
    }

    MouseArea {
        id:           gameButtonMouseArea
        anchors.fill: parent
        z:            2

        onClicked: {
            gameButton.clicked();
        }
    }

    SequentialAnimation {
        id:      highlightAnimation
        loops:   Animation.Infinite
        running: gameButton.highlighted

        NumberAnimation {
            target:   highlightedImage
            property: "opacity"
            from:     0.0
            to:       1.0
            duration: 500
        }

        NumberAnimation {
            target:   highlightedImage
            property: "opacity"
            from:     1.0
            to:       0.0
            duration: 500
        }
    }
}
