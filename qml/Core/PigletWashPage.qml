import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12

import "Dialog"
import "PigletWash"

import "PigletWashPage.js" as PigletWashPageScript

Item {
    id: pigletWashPage

    readonly property bool appInForeground: Qt.application.state === Qt.ApplicationActive
    readonly property bool pageActive:      StackView.status === StackView.Active

    property bool pageInitialized:          false
    property bool allowGameRestart:         false

    property int highScore:                 0
    property int visibleBubblesCount:       0
    property int burstedBubblesCount:       0
    property int missedBubblesCount:        0

    property double gameStartTime:          (new Date()).getTime()

    signal gameFinished(string game)
    signal bubbleCleanupRequested()

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            if (!pageInitialized) {
                pageInitialized = true;

                gameStartedNotificationDialog.open();
            } else if (allowGameRestart) {
                bubbleCreationTimer.start();
            }
        } else {
            bubbleCreationTimer.stop();

            bubbleCleanupRequested();
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            if (!pageInitialized) {
                pageInitialized = true;

                gameStartedNotificationDialog.open();
            } else if (allowGameRestart) {
                bubbleCreationTimer.start();
            }
        } else {
            bubbleCreationTimer.stop();

            bubbleCleanupRequested();
        }
    }

    onBurstedBubblesCountChanged: {
        if (burstedBubblesCount > 0) {
            audio.playAudio("qrc:/resources/sound/piglet_wash/bubble_bursted.wav");
        }
    }

    onMissedBubblesCountChanged: {
        if (missedBubblesCount === 4) {
            bubbleCreationTimer.stop();

            bubbleCleanupRequested();

            pigletWashPage.allowGameRestart = false;

            if (burstedBubblesCount > highScore) {
                mainWindow.setSetting("PigletWashHighScore", burstedBubblesCount.toString(10));

                highScoreQueryDialog.open();
            } else {
                gameOverQueryDialog.open();
            }
        }
    }

    StackView.onRemoved: {
        destroy();
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
            playing:      pigletWashPage.appInForeground && pigletWashPage.pageActive
            visible:      pigletWashPage.missedBubblesCount === 0 || pigletWashPage.missedBubblesCount > 3
        }

        AnimatedImage {
            id:           background1MissedAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_wash/background_1_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      pigletWashPage.appInForeground && pigletWashPage.pageActive
            visible:      pigletWashPage.missedBubblesCount === 1
        }

        AnimatedImage {
            id:           background2MissedAnimatedImage
            anchors.fill: parent
            z:            2
            source:       "qrc:/resources/images/piglet_wash/background_2_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      pigletWashPage.appInForeground && pigletWashPage.pageActive
            visible:      pigletWashPage.missedBubblesCount === 2
        }

        AnimatedImage {
            id:           background3MissedAnimatedImage
            anchors.fill: parent
            z:            3
            source:       "qrc:/resources/images/piglet_wash/background_3_missed.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      pigletWashPage.appInForeground && pigletWashPage.pageActive
            visible:      pigletWashPage.missedBubblesCount === 3
        }

        Image {
            id:                missedBubblesBackgroundImage
            anchors.top:       parent.top
            anchors.left:      parent.left
            anchors.topMargin: 30
            z:                 4
            width:             133
            height:            38
            source:            "qrc:/resources/images/piglet_wash/missed_bubbles_background.png"

            Row {
                id:               missedBubblesRow
                anchors.centerIn: parent
                spacing:          4

                Image {
                    id:      bubble1MissedImage
                    width:   29
                    height:  29
                    source:  pigletWashPage.missedBubblesCount > 0 ? "qrc:/resources/images/piglet_wash/missed_bubble.png" :
                                                                     "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }

                Image {
                    id:      bubble2MissedImage
                    width:   29
                    height:  29
                    source:  pigletWashPage.missedBubblesCount > 1 ? "qrc:/resources/images/piglet_wash/missed_bubble.png" :
                                                                     "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }

                Image {
                    id:      bubble3MissedImage
                    width:   29
                    height:  29
                    source:  pigletWashPage.missedBubblesCount > 2 ? "qrc:/resources/images/piglet_wash/missed_bubble.png" :
                                                                     "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }

                Image {
                    id:      bubble4MissedImage
                    width:   29
                    height:  29
                    source:  pigletWashPage.missedBubblesCount > 3 ? "qrc:/resources/images/piglet_wash/missed_bubble.png" :
                                                                     "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                }
            }
        }

        Text {
            id:                  scoreText
            anchors.top:         parent.top
            anchors.right:       parent.right
            anchors.topMargin:   30
            z:                   4
            text:                textText(pigletWashPage.burstedBubblesCount)
            color:               "yellow"
            font.pixelSize:      32
            font.family:         "Courier"
            horizontalAlignment: Text.AlignRight
            verticalAlignment:   Text.AlignVCenter

            function textText(bursted_bubbles) {
                var score = bursted_bubbles + "";

                while (score.length < 6) {
                    score = "0" + score;
                }

                return score;
            }
        }

        Text {
            id:                  highScoreText
            anchors.top:         scoreText.bottom
            anchors.right:       parent.right
            z:                   4
            text:                textText(pigletWashPage.highScore)
            color:               "red"
            font.pixelSize:      32
            font.family:         "Courier"
            horizontalAlignment: Text.AlignRight
            verticalAlignment:   Text.AlignVCenter

            function textText(high_score) {
                var score = high_score + "";

                while (score.length < 6) {
                    score = "0" + score;
                }

                return score;
            }
        }

        Image {
            id:                   backButtonImage
            anchors.bottom:       parent.bottom
            anchors.right:        parent.right
            anchors.bottomMargin: 30
            z:                    10
            width:                64
            height:               64
            source:               "qrc:/resources/images/back.png"

            MouseArea {
                id:           backButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    bubbleCreationTimer.stop();

                    pigletWashPage.bubbleCleanupRequested();

                    pigletWashPage.gameFinished("piglet_wash");

                    mainStackView.pop();
                }
            }
        }
    }

    NotificationDialog {
        id:   gameStartedNotificationDialog
        z:    1
        text: qsTr("Your piglet wants to take a bath and play with soap bubbles! Help him to catch and pop as many bubbles as you can.")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_wash/game_started.wav");

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
        z:    1
        text: qsTr("Congratulations, you have a new highscore! Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_wash/high_score.wav");
        }

        onYes: {
            gameStartedNotificationDialog.open();
        }

        onNo: {
            pigletWashPage.gameFinished("piglet_wash");

            mainStackView.pop();
        }
    }

    QueryDialog {
        id:   gameOverQueryDialog
        z:    1
        text: qsTr("Game over. Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_wash/game_over.wav");
        }

        onYes: {
            gameStartedNotificationDialog.open();
        }

        onNo: {
            pigletWashPage.gameFinished("piglet_wash");

            mainStackView.pop();
        }
    }

    Timer {
        id:       gameStartTimer
        interval: 3000

        onTriggered: {
           gameStartedNotificationDialog.close();
        }
    }

    Timer {
        id:       bubbleCreationTimer
        interval: 500
        repeat:   true

        onTriggered: {
            var elapsed = (new Date()).getTime() - pigletWashPage.gameStartTime;

            if (elapsed < 0) {
                pigletWashPage.gameStartTime = (new Date()).getTime();

                elapsed = 0;
            }

            var seconds = elapsed / 1000;
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
