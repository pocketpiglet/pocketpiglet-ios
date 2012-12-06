import QtQuick 1.1
import QtMultimediaKit 1.1
import com.nokia.meego 1.0

import "PigletWash"

import "PigletWashPage.js" as PigletWashPageScript

Page {
    id:              pigletWashPage
    anchors.fill:    parent
    orientationLock: PageOrientation.LockPortrait

    property bool appInForeground:    Qt.application.active
    property bool audioActive:        false

    property int highScore:           0
    property int visibleBubblesCount: 0
    property int burstedBubblesCount: 0
    property int missedBubblesCount:  0

    property real gameStartTime:      (new Date()).getTime()

    signal destroyBubbles()

    onStatusChanged: {
        if (status === PageStatus.Active) {
            background0MissedAnimatedImage.playing = true;
            background1MissedAnimatedImage.playing = true;
            background2MissedAnimatedImage.playing = true;
            background3MissedAnimatedImage.playing = true;

            waitRectangle.visible = true;

            gameBeginTimer.start();
        } else {
            background0MissedAnimatedImage.playing = false;
            background1MissedAnimatedImage.playing = false;
            background2MissedAnimatedImage.playing = false;
            background3MissedAnimatedImage.playing = false;

            if (audioActive) {
                audio.stop();
            }
        }
    }

    onAppInForegroundChanged: {
        if (appInForeground) {
            pauseRectangle.visible = false;

            if (status === PageStatus.Active) {
                bubbleCreationTimer.start();
            }
        } else {
            pauseRectangle.visible = true;

            bubbleCreationTimer.stop();

            if (status === PageStatus.Active) {
                destroyBubbles();
            }
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
            pigletWashPage.playAudio("../../sound/piglet_wash/bubble_burst.wav", false);
        }

        var score = burstedBubblesCount + "";

        while (score.length < 6) {
            score = "0" + score;
        }

        scoreText.text = score;
    }

    onMissedBubblesCountChanged: {
        if (missedBubblesCount === 1) {
            bubble1MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_red.png";
        } else if (missedBubblesCount > 1) {
            bubble1MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble1MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }
        if (missedBubblesCount === 2) {
            bubble2MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_red.png";
        } else if (missedBubblesCount > 2) {
            bubble2MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble2MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }
        if (missedBubblesCount === 3) {
            bubble3MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_red.png";
        } else if (missedBubblesCount > 3) {
            bubble3MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble.png";
        } else {
            bubble3MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png";
        }
        if (missedBubblesCount === 4) {
            bubble4MissedImage.source = "qrc:/resources/images/piglet_wash/missed_bubble_red.png";
        } else if (missedBubblesCount > 4) {
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

            if (burstedBubblesCount > highScore) {
                mainWindow.setSetting("PigletWashHighScore", burstedBubblesCount);

                highScoreQueryDialog.open();
            } else {
                gameOverQueryDialog.open();
            }
        }
    }

    function playAudio(src, interrupt) {
        if (audioActive) {
            if (interrupt) {
                audio.stop();

                audio.source   = src;
                audio.position = 0;

                audio.play();
            }
        } else {
            audio.source   = src;
            audio.position = 0;

            audio.play();
        }
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  pigletWashPage.appInForeground ? false : true

        onStarted: {
            pigletWashPage.audioActive = true;
        }

        onStopped: {
            pigletWashPage.audioActive = false;
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
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            playing:      false
        }

        AnimatedImage {
            id:           background1MissedAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_wash/background_1_missed.gif"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            playing:      false
            visible:      false
        }

        AnimatedImage {
            id:           background2MissedAnimatedImage
            anchors.fill: parent
            z:            2
            source:       "qrc:/resources/images/piglet_wash/background_2_missed.gif"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            playing:      false
            visible:      false
        }

        AnimatedImage {
            id:           background3MissedAnimatedImage
            anchors.fill: parent
            z:            3
            source:       "qrc:/resources/images/piglet_wash/background_3_missed.gif"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            playing:      false
            visible:      false
        }

        Image {
            id:           missedBubblesBackgroundImage
            anchors.top:  parent.top
            anchors.left: parent.left
            width:        133
            height:       38
            z:            4
            source:       "qrc:/resources/images/piglet_wash/missed_bubbles_background.png"

            Row {
                id:               missedBubblesRow
                anchors.centerIn: parent
                spacing:          4

                Image {
                    id:      bubble1MissedImage
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                    width:   29
                    height:  29
                }

                Image {
                    id:      bubble2MissedImage
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                    width:   29
                    height:  29
                }

                Image {
                    id:      bubble3MissedImage
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                    width:   29
                    height:  29
                }

                Image {
                    id:      bubble4MissedImage
                    source:  "qrc:/resources/images/piglet_wash/missed_bubble_grayed.png"
                    width:   29
                    height:  29
                }
            }
        }

        Text {
            id:                  scoreText
            anchors.top:         parent.top
            anchors.right:       parent.right
            z:                   4
            text:                "000000"
            color:               "yellow"
            horizontalAlignment: Text.AlignRight
            verticalAlignment:   Text.AlignVCenter
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
            font.pixelSize:      32
        }

        Image {
            id:             exitButtonImage
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            width:          48
            height:         48
            z:              10
            source:         "qrc:/resources/images/exit.png"

            MouseArea {
                id:           exitButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    bubbleCreationTimer.stop();

                    pigletWashPage.destroyBubbles();

                    pigletPage.gameFinished("piglet_wash");

                    mainPageStack.replace(pigletPage);
                }
            }
        }
    }

    Rectangle {
        id:           waitRectangle
        anchors.fill: parent
        z:            50
        color:        "black"
        visible:      false

        MouseArea {
            id:           waitRectangleMouseArea
            anchors.fill: parent

            Image {
                id:                       waitBusyIndicatorImage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
                source:                   "qrc:/resources/images/busy_indicator.png"

                NumberAnimation on rotation {
                    running: waitRectangle.visible
                    from:    0
                    to:      360
                    loops:   Animation.Infinite
                }
            }
        }
    }

    Rectangle {
        id:           pauseRectangle
        anchors.fill: parent
        z:            70
        color:        "black"
        visible:      false

        MouseArea {
            id:           pauseRectangleMouseArea
            anchors.fill: parent

            Image {
                id:               pauseRectangleImage
                anchors.centerIn: parent
                source:           "qrc:/resources/images/game_pause.png"
            }
        }
    }

    QueryDialog {
        id:        gameStartQueryDialog
        titleText: "Wash the Piglet"
        icon:      "qrc:/resources/images/dialog_info.png"
        message:   "Your piglet wants to take a bath and play with soap bubbles! Help him to catch and pop as many bubbles as you can."

        onStatusChanged: {
            if (status === DialogStatus.Open) {
                pigletWashPage.playAudio("../../sound/piglet_wash/game_start.wav", true);

                gameStartTimer.start();
            }
        }

        onRejected: {
            gameStartTimer.stop();

            pigletWashPage.highScore           = mainWindow.getSetting("PigletWashHighScore", 0);
            pigletWashPage.burstedBubblesCount = 0;
            pigletWashPage.missedBubblesCount  = 0;
            pigletWashPage.gameStartTime       = (new Date()).getTime();

            bubbleCreationTimer.start();
        }
    }

    QueryDialog {
        id:               highScoreQueryDialog
        titleText:        "Wash the Piglet"
        icon:             "qrc:/resources/images/dialog_question.png"
        message:          "Congratulations, you have a new highscore! Do you want to play again?"
        acceptButtonText: "Play"
        rejectButtonText: "Quit"

        onStatusChanged: {
            if (status === DialogStatus.Open) {
                pigletWashPage.playAudio("../../sound/piglet_wash/high_score.wav", true);
            }
        }

        onAccepted: {
            gameStartQueryDialog.open();
        }

        onRejected: {
            pigletPage.gameFinished("piglet_wash");

            mainPageStack.replace(pigletPage);
        }
    }

    QueryDialog {
        id:               gameOverQueryDialog
        titleText:        "Wash the Piglet"
        icon:             "qrc:/resources/images/dialog_question.png"
        message:          "Game over. Do you want to play again?"
        acceptButtonText: "Play"
        rejectButtonText: "Quit"

        onStatusChanged: {
            if (status === DialogStatus.Open) {
                pigletWashPage.playAudio("../../sound/piglet_wash/game_over.wav", true);
            }
        }

        onAccepted: {
            gameStartQueryDialog.open();
        }

        onRejected: {
            pigletPage.gameFinished("piglet_wash");

            mainPageStack.replace(pigletPage);
        }
    }

    Timer {
        id:       gameBeginTimer
        interval: 100

        onTriggered: {
            waitRectangle.visible = false;

            gameStartQueryDialog.open();
        }
    }

    Timer {
        id:       gameStartTimer
        interval: 2000

        onTriggered: {
            gameStartQueryDialog.reject();
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
                count = 5 + Math.floor((seconds - 25) / 30);
            }

            if (count > 10) {
                count = 10;
            }

            PigletWashPageScript.createBubbles(count - pigletWashPage.visibleBubblesCount);
        }
    }
}
