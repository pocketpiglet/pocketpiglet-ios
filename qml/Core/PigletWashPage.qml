import QtQuick 2.9
import QtMultimedia 5.9

import "Dialog"
import "PigletWash"

import "PigletWashPage.js" as PigletWashPageScript

Item {
    id: pigletWashPage

    property bool appInForeground:    Qt.application.active
    property bool pageActive:         false
    property bool pageInitialized:    false
    property bool allowGameRestart:   false

    property int highScore:           0
    property int visibleBubblesCount: 0
    property int burstedBubblesCount: 0
    property int missedBubblesCount:  0

    property double gameStartTime:    (new Date()).getTime()

    signal destroyBubbles()

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            background0MissedAnimatedImage.playing = true;
            background1MissedAnimatedImage.playing = true;
            background2MissedAnimatedImage.playing = true;
            background3MissedAnimatedImage.playing = true;

            if (!pageInitialized) {
                pageInitialized = true;

                gameBeginTimer.start();
            } else if (allowGameRestart) {
                bubbleCreationTimer.start();
            }
        } else {
            background0MissedAnimatedImage.playing = false;
            background1MissedAnimatedImage.playing = false;
            background2MissedAnimatedImage.playing = false;
            background3MissedAnimatedImage.playing = false;

            bubbleCreationTimer.stop();

            destroyBubbles();
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            background0MissedAnimatedImage.playing = true;
            background1MissedAnimatedImage.playing = true;
            background2MissedAnimatedImage.playing = true;
            background3MissedAnimatedImage.playing = true;

            if (!pageInitialized) {
                pageInitialized = true;

                gameBeginTimer.start();
            } else if (allowGameRestart) {
                bubbleCreationTimer.start();
            }
        } else {
            background0MissedAnimatedImage.playing = false;
            background1MissedAnimatedImage.playing = false;
            background2MissedAnimatedImage.playing = false;
            background3MissedAnimatedImage.playing = false;

            bubbleCreationTimer.stop();

            destroyBubbles();
        }
    }

    onHighScoreChanged: {
        var score = highScore + "";

        while (score.length < 6) {
            score = "0" + score;
        }

        highScoreText.text = score;
    }

    onBurstedBubblesCountChanged: {
        if (burstedBubblesCount > 0) {
            audio.playAudio("qrc:/resources/sound/piglet_wash/bubble_burst.wav");
        }

        var score = burstedBubblesCount + "";

        while (score.length < 6) {
            score = "0" + score;
        }

        scoreText.text = score;
    }

    onMissedBubblesCountChanged: {
        if (missedBubblesCount > 0) {
            bubble1MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble1MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }
        if (missedBubblesCount > 1) {
            bubble2MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble2MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }
        if (missedBubblesCount > 2) {
            bubble3MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble3MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }
        if (missedBubblesCount > 3) {
            bubble4MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble4MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }

        if (missedBubblesCount === 0 || missedBubblesCount > 3) {
            background0MissedAnimatedImage.visible = true;
        } else {
            background0MissedAnimatedImage.visible = false;
        }
        if (missedBubblesCount === 1) {
            background1MissedAnimatedImage.visible = true;
        } else {
            background1MissedAnimatedImage.visible = false;
        }
        if (missedBubblesCount === 2) {
            background2MissedAnimatedImage.visible = true;
        } else {
            background2MissedAnimatedImage.visible = false;
        }
        if (missedBubblesCount === 3) {
            background3MissedAnimatedImage.visible = true;
        } else {
            background3MissedAnimatedImage.visible = false;
        }

        if (missedBubblesCount === 4) {
            bubbleCreationTimer.stop();

            destroyBubbles();

            pigletWashPage.allowGameRestart = false;

            if (burstedBubblesCount > highScore) {
                mainWindow.setSetting("PigletWashHighScore", burstedBubblesCount.toString(10));

                highScoreQueryDialog.open();
            } else {
                gameOverQueryDialog.open();
            }
        }
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletWashPage.appInForeground || !pigletWashPage.pageActive

        onError: {
            console.log(errorString);
        }

        function playAudio(src) {
            source = src;

            seek(0);
            play();
        }
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        AnimatedImage {
            id:           background0MissedAnimatedImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_wash/background_0_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      false
        }

        AnimatedImage {
            id:           background1MissedAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_wash/background_1_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      false
            visible:      false
        }

        AnimatedImage {
            id:           background2MissedAnimatedImage
            anchors.fill: parent
            z:            2
            source:       "qrc:/resources/images/piglet_wash/background_2_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      false
            visible:      false
        }

        AnimatedImage {
            id:           background3MissedAnimatedImage
            anchors.fill: parent
            z:            3
            source:       "qrc:/resources/images/piglet_wash/background_3_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      false
            visible:      false
        }

        Image {
            id:                missedBubblesBackgroundImage
            anchors.top:       parent.top
            anchors.left:      parent.left
            anchors.topMargin: 30
            width:             133
            height:            38
            z:                 4
            source:            "qrc:/resources/images/piglet_wash/missed_bubbles_background.png"

            Row {
                id:               missedBubblesRow
                anchors.centerIn: parent
                spacing:          4

                Image {
                    id:      bubble1MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }

                Image {
                    id:      bubble2MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }

                Image {
                    id:      bubble3MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }

                Image {
                    id:      bubble4MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }
            }
        }

        Text {
            id:                  scoreText
            anchors.top:         parent.top
            anchors.right:       parent.right
            anchors.topMargin:   30
            z:                   4
            text:                "000000"
            color:               "yellow"
            horizontalAlignment: Text.AlignRight
            verticalAlignment:   Text.AlignVCenter
            font.family:         "Courier"
            font.pixelSize:      32
        }

        Text {
            id:                  highScoreText
            anchors.top:         scoreText.bottom
            anchors.right:       parent.right
            z:                   4
            text:                "000000"
            color:               "red"
            horizontalAlignment: Text.AlignRight
            verticalAlignment:   Text.AlignVCenter
            font.family:         "Courier"
            font.pixelSize:      32
        }

        Image {
            id:             backButtonImage
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            width:          64
            height:         64
            z:              10
            source:         "qrc:/resources/images/back.png"

            MouseArea {
                id:           backButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    bubbleCreationTimer.stop();

                    pigletWashPage.destroyBubbles();

                    pigletPage.gameFinished("piglet_wash");

                    mainStackView.pop();
                }
            }
        }
    }

    NotificationDialog {
        id:   gameStartNotificationDialog
        z:    20
        text: qsTr("Your piglet wants to take a bath and play with soap bubbles! Help him to catch and pop as many bubbles as you can.")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_wash/game_start.wav");

            gameStartTimer.start();
        }

        onClosed: {
            gameStartTimer.stop();

            pigletWashPage.allowGameRestart    = true;
            pigletWashPage.highScore           = parseInt(mainWindow.getSetting("PigletWashHighScore", "0"), 10);
            pigletWashPage.burstedBubblesCount = 0;
            pigletWashPage.missedBubblesCount  = 0;
            pigletWashPage.gameStartTime       = (new Date()).getTime();

            bubbleCreationTimer.start();
        }
    }

    QueryDialog {
        id:   highScoreQueryDialog
        z:    20
        text: qsTr("Congratulations, you have a new highscore! Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_wash/high_score.wav");
        }

        onYes: {
            gameStartNotificationDialog.open();
        }

        onNo: {
            pigletPage.gameFinished("piglet_wash");

            mainStackView.pop();
        }
    }

    QueryDialog {
        id:   gameOverQueryDialog
        z:    20
        text: qsTr("Game over. Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_wash/game_over.wav");
        }

        onYes: {
            gameStartNotificationDialog.open();
        }

        onNo: {
            pigletPage.gameFinished("piglet_wash");

            mainStackView.pop();
        }
    }

    Timer {
        id:       gameBeginTimer
        interval: 100

        onTriggered: {
            gameStartNotificationDialog.open();
        }
    }

    Timer {
        id:       gameStartTimer
        interval: 3000

        onTriggered: {
           gameStartNotificationDialog.close();
        }
    }

    Timer {
        id:       bubbleCreationTimer
        interval: 500
        repeat:   true

        onTriggered: {
            var seconds = ((new Date()).getTime() - pigletWashPage.gameStartTime) / 1000;
            var count   = 0;

            if (seconds < 25) {
                count = Math.floor(seconds / 5) + 1;
            } else {
                count = 5 + Math.floor((seconds - 25) / 10);
            }

            if (count > 50) {
                count = 50;
            }

            PigletWashPageScript.createBubbles(count - pigletWashPage.visibleBubblesCount);
        }
    }
}
