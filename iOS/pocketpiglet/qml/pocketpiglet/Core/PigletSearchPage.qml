import QtQuick 2.9
import QtMultimedia 5.9
import QtSensors 5.9

import "Dialog"
import "PigletSearch"

Item {
    id: pigletSearchPage

    property bool appInForeground:   Qt.application.active
    property bool pageActive:        false
    property bool pageInitialized:   false
    property bool allowGameRestart:  false

    property int highScore:          0
    property int foundPigletsCount:  0
    property int missedPigletsCount: 0

    property var currentPiglet:      null

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            if (!pageInitialized) {
                pageInitialized = true;

                gameBeginTimer.start();
            } else if (allowGameRestart) {
                pigletCreationTimer.start();
            }
        } else {
            pigletCreationTimer.stop();

            if (currentPiglet !== null) {
                currentPiglet.destroy();

                currentPiglet = null;
            }
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            if (!pageInitialized) {
                pageInitialized = true;

                gameBeginTimer.start();
            } else if (allowGameRestart) {
                pigletCreationTimer.start();
            }
        } else {
            pigletCreationTimer.stop();

            if (currentPiglet !== null) {
                currentPiglet.destroy();

                currentPiglet = null;
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

    onFoundPigletsCountChanged: {
        if (foundPigletsCount > 0) {
            audio.playAudio("qrc:/resources/sound/piglet_search/piglet_found.wav");
        }

        var score = foundPigletsCount + "";

        while (score.length < 6) {
            score = "0" + score;
        }

        scoreText.text = score;

        if (foundPigletsCount > 0) {
            pigletCreationTimer.start();
        }
    }

    onMissedPigletsCountChanged: {
        if (missedPigletsCount > 0) {
            audio.playAudio("qrc:/resources/sound/piglet_search/piglet_missed.wav");
        }

        if (missedPigletsCount > 0) {
            piglet1MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet.png";
        } else {
            piglet1MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet_grayed.png";
        }
        if (missedPigletsCount > 1) {
            piglet2MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet.png";
        } else {
            piglet2MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet_grayed.png";
        }
        if (missedPigletsCount > 2) {
            piglet3MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet.png";
        } else {
            piglet3MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet_grayed.png";
        }
        if (missedPigletsCount > 3) {
            piglet4MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet.png";
        } else {
            piglet4MissedImage.source = "qrc:/resources/images/piglet_search/missed_piglet_grayed.png";
        }

        if (missedPigletsCount === 4) {
            pigletSearchPage.allowGameRestart = false;

            if (foundPigletsCount > highScore) {
                mainWindow.setSetting("PigletSearchHighScore", foundPigletsCount);

                highScoreQueryDialog.open();
            } else {
                gameOverQueryDialog.open();
            }
        } else if (missedPigletsCount > 0) {
            pigletCreationTimer.start();
        }
    }

    function pigletFound() {
        foundPigletsCount = foundPigletsCount + 1;
    }

    function pigletMissed() {
        missedPigletsCount = missedPigletsCount + 1;
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletSearchPage.appInForeground || !pigletSearchPage.pageActive

        onError: {
            console.log(errorString);
        }

        function playAudio(src) {
            source = src;

            seek(0);
            play();
        }
    }

    Camera {
        id: camera

        onError: {
            console.log(errorString);
        }
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        VideoOutput {
            id:           videoOutput
            anchors.fill: parent
            source:       camera
            focus:        false
            orientation:  270
        }

        Image {
            id:                missedPigletsBackgroundImage
            anchors.top:       parent.top
            anchors.left:      parent.left
            anchors.topMargin: 30
            width:             133
            height:            38
            z:                 4
            source:            "qrc:/resources/images/piglet_search/missed_piglets_background.png"

            Row {
                id:               missedPigletsRow
                anchors.centerIn: parent
                spacing:          4

                Image {
                    id:      piglet1MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                }

                Image {
                    id:      piglet2MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                }

                Image {
                    id:      piglet3MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                }

                Image {
                    id:      piglet4MissedImage
                    width:   29
                    height:  29
                    source:  "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
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

        Text {
            id:                       timerText
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        4
            visible:                  false
            text:                     "00"
            color:                    "red"
            horizontalAlignment:      Text.AlignHCenter
            verticalAlignment:        Text.AlignVCenter
            font.pixelSize:           32
        }

        Image {
            id:                     turnLeftImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            width:                  29
            height:                 29
            z:                      4
            visible:                pigletSearchPage.currentPiglet !== null &&
                                    pigletSearchPage.currentPiglet.x < 0 - pigletSearchPage.currentPiglet.width
            source:                 "qrc:/resources/images/piglet_search/turn_left.png"
        }

        Image {
            id:                     turnRightImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:          parent.right
            width:                  29
            height:                 29
            z:                      4
            visible:                pigletSearchPage.currentPiglet !== null &&
                                    pigletSearchPage.currentPiglet.x > backgroundRectangle.width
            source:                 "qrc:/resources/images/piglet_search/turn_right.png"
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
                    pigletCreationTimer.stop();

                    if (pigletSearchPage.currentPiglet !== null) {
                        pigletSearchPage.currentPiglet.destroy();

                        pigletSearchPage.currentPiglet = null;
                    }

                    pigletPage.gameFinished("piglet_search");

                    mainStackView.pop();
                }
            }
        }
    }

    Compass {
        id:       compass
        dataRate: 10
        active:   pigletSearchPage.appInForeground && pigletSearchPage.pageActive

        property real lastAzimuth: 0.0

        onReadingChanged: {
            lastAzimuth = reading.azimuth;

            if (pigletSearchPage.currentPiglet !== null) {
                pigletSearchPage.currentPiglet.updatePosition(lastAzimuth);
            }
        }
    }

    NotificationDialog {
        id:   gameStartNotificationDialog
        z:    20
        text: qsTr("Your piglet wants to take a bath and play with soap bubbles! Help him to catch and pop as many bubbles as you can.")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_search/game_start.wav");

            gameStartTimer.start();
        }

        onClosed: {
            gameStartTimer.stop();

            pigletSearchPage.allowGameRestart   = true;
            pigletSearchPage.highScore          = mainWindow.getSetting("PigletSearchHighScore", 0);
            pigletSearchPage.foundPigletsCount  = 0;
            pigletSearchPage.missedPigletsCount = 0;

            pigletCreationTimer.start();
        }
    }

    QueryDialog {
        id:   highScoreQueryDialog
        z:    20
        text: qsTr("Congratulations, you have a new highscore! Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_search/high_score.wav");
        }

        onYes: {
            gameStartNotificationDialog.open();
        }

        onNo: {
            pigletPage.gameFinished("piglet_search");

            mainStackView.pop();
        }
    }

    QueryDialog {
        id:   gameOverQueryDialog
        z:    20
        text: qsTr("Game over. Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_search/game_over.wav");
        }

        onYes: {
            gameStartNotificationDialog.open();
        }

        onNo: {
            pigletPage.gameFinished("piglet_search");

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
        interval: 2000

        onTriggered: {
           gameStartNotificationDialog.close();
        }
    }

    Timer {
        id:       pigletCreationTimer
        interval: 100

        onTriggered: {
            var mseconds = 30000 - (pigletSearchPage.foundPigletsCount + pigletSearchPage.missedPigletsCount) * 2000;

            if (mseconds < 3000) {
                mseconds = 3000;
            }

            pigletSearchPage.currentPiglet = Qt.createComponent("PigletSearch/Piglet.qml").createObject(backgroundRectangle, {"z": 5});

            pigletSearchPage.currentPiglet.y        = Math.random() * (parent.height - pigletSearchPage.currentPiglet.height);
            pigletSearchPage.currentPiglet.azimuth  = Math.random() * 180;
            pigletSearchPage.currentPiglet.waitTime = mseconds;

            pigletSearchPage.currentPiglet.pigletFound.connect(pigletSearchPage.pigletFound);
            pigletSearchPage.currentPiglet.pigletMissed.connect(pigletSearchPage.pigletMissed);

            pigletSearchPage.currentPiglet.updatePosition(compass.lastAzimuth);

            countdownTimer.restart();
        }
    }

    Timer {
        id:       countdownTimer
        interval: 1000
        repeat:   true

        property int countdownTime: 0

        onRunningChanged: {
            if (running) {
                if (pigletSearchPage.currentPiglet !== null) {
                    countdownTime = pigletSearchPage.currentPiglet.waitTime;
                } else {
                    countdownTime = 0;
                }

                if (countdownTime > 0) {
                    var time = (countdownTime / 1000) + "";

                    while (time.length < 2) {
                        time = "0" + time;
                    }

                    timerText.text = time;
                } else {
                    timerText.text = "00";
                }

                timerText.visible = true;
            } else {
                timerText.visible = false;
            }
        }

        onTriggered: {
            countdownTime = countdownTime - interval;

            if (countdownTime > 0) {
                var time = (countdownTime / 1000) + "";

                while (time.length < 2) {
                    time = "0" + time;
                }

                timerText.text = time;
            } else {
                timerText.text = "00";
            }
        }
    }
}