import QtQuick 2.9

Rectangle {
    id:     bubble
    width:  bubbleImage.sourceSize.width
    height: bubbleImage.sourceSize.height
    color:  "transparent"

    property bool valid: true

    signal bubbleBursted()
    signal bubbleMissed()
    signal bubbleDestroyed()

    function destroyBubble() {
        if (typeof(bubble) !== "undefined") {
            if (valid) {
                valid = false;

                bubbleDestroyed();
            }

            bubble.destroy();
        }
    }

    MouseArea {
        id:           bubbleMouseArea
        anchors.fill: parent

        onClicked: {
            bubbleMouseArea.enabled    = false;
            bubbleImage.visible        = false;
            bubbleBurstedImage.visible = true;

            bubbleBurstTimer.start();

            if (bubble.valid) {
                bubble.valid = false;

                bubble.bubbleBursted();
            }
        }

        Image {
            id:           bubbleImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_wash/bubble_1.png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
        }

        Image {
            id:           bubbleBurstedImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_wash/bubble_bursted.png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            visible:      false
        }
    }

    PropertyAnimation {
        id:       bubbleFlightPropertyAnimation
        target:   bubble
        property: "y"
        to:       0 - bubble.height
        duration: 5000

        onRunningChanged: {
            if (!running) {
                if (bubble.valid) {
                    bubble.valid = false;

                    bubble.bubbleMissed();
                }

                bubble.destroy();
            }
        }
    }

    Timer {
        id:       bubbleBurstTimer
        interval: 100

        onTriggered: {
            bubble.destroy();
        }
    }

    Component.onCompleted: {
        var rand = Math.random();

        if (rand < 0.33) {
            bubbleImage.source = "qrc:/resources/images/piglet_wash/bubble_1.png";
        } else if (rand < 0.66) {
            bubbleImage.source = "qrc:/resources/images/piglet_wash/bubble_2.png";
        } else {
            bubbleImage.source = "qrc:/resources/images/piglet_wash/bubble_3.png";
        }

        x = Math.random() * (parent.width - bubble.width);
        y = (parent.height / 2) + Math.random() * ((parent.height / 2) - bubble.height);

        bubbleFlightPropertyAnimation.start();
    }
}
