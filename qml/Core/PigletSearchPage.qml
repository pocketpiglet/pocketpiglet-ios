import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtSensors 5.12

import "Dialog"
import "PigletSearch"

Item {
    id: pigletSearchPage

    readonly property bool appInForeground: Qt.application.state === Qt.ApplicationActive
    readonly property bool pageActive:      StackView.status === StackView.Active

    property bool pageInitialized:          false
    property bool allowGameRestart:         false

    property int highScore:                 0
    property int foundPigletsCount:         0
    property int missedPigletsCount:        0

    property var currentPiglet:             null

    signal gameFinished(string game)

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            if (!pageInitialized) {
                pageInitialized = true;

                gameStartedNotificationDialog.open();
            } else if (allowGameRestart) {
                createPiglet();
            }
        } else {
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

                gameStartedNotificationDialog.open();
            } else if (allowGameRestart) {
                createPiglet();
            }
        } else {
            if (currentPiglet !== null) {
                currentPiglet.destroy();

                currentPiglet = null;
            }
        }
    }

    onHighScoreChanged: {
        mainWindow.setSetting("PigletSearchHighScore", highScore.toString(10));
    }

    onFoundPigletsCountChanged: {
        if (foundPigletsCount > 0) {
            audio.playAudio("qrc:/resources/sound/piglet_search/piglet_found.wav");

            createPiglet();
        }
    }

    onMissedPigletsCountChanged: {
        if (missedPigletsCount > 0) {
            audio.playAudio("qrc:/resources/sound/piglet_search/piglet_missed.wav");
        }

        if (missedPigletsCount === 4) {
            pigletSearchPage.allowGameRestart = false;

            if (foundPigletsCount > highScore) {
                highScore = foundPigletsCount;

                highScoreQueryDialog.open();
            } else {
                gameOverQueryDialog.open();
            }
        } else if (missedPigletsCount > 0) {
            createPiglet();
        }
    }

    StackView.onRemoved: {
        destroy();
    }

    function createPiglet() {
        var mseconds = 30000 - (foundPigletsCount + missedPigletsCount) * 2000;

        if (mseconds < 3000) {
            mseconds = 3000;
        }

        currentPiglet = Qt.createComponent("PigletSearch/Piglet.qml").createObject(backgroundRectangle, {"z": 5});

        currentPiglet.azimuth  = Math.random() * 180;
        currentPiglet.zenith   = Math.random() * 45 + 45;
        currentPiglet.waitTime = mseconds;

        currentPiglet.pigletFound.connect(handlePigletFinding);
        currentPiglet.pigletMissed.connect(handlePigletMiss);

        currentPiglet.updatePosition(compass.lastAzimuth, rotationSensor.lastZenith);

        countdownTimer.restart();
    }

    function handlePigletFinding() {
        currentPiglet = null;

        foundPigletsCount = foundPigletsCount + 1;
    }

    function handlePigletMiss() {
        currentPiglet = null;

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
            z:                 1
            width:             133
            height:            38
            source:            "qrc:/resources/images/piglet_search/missed_piglets_background.png"
            fillMode:          Image.PreserveAspectFit

            Row {
                id:               missedPigletsRow
                anchors.centerIn: parent
                spacing:          4

                Image {
                    id:       piglet1MissedImage
                    width:    29
                    height:   29
                    source:   pigletSearchPage.missedPigletsCount > 0 ? "qrc:/resources/images/piglet_search/missed_piglet.png" :
                                                                        "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id:       piglet2MissedImage
                    width:    29
                    height:   29
                    source:   pigletSearchPage.missedPigletsCount > 1 ? "qrc:/resources/images/piglet_search/missed_piglet.png" :
                                                                        "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id:       piglet3MissedImage
                    width:    29
                    height:   29
                    source:   pigletSearchPage.missedPigletsCount > 2 ? "qrc:/resources/images/piglet_search/missed_piglet.png" :
                                                                        "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id:       piglet4MissedImage
                    width:    29
                    height:   29
                    source:   pigletSearchPage.missedPigletsCount > 3 ? "qrc:/resources/images/piglet_search/missed_piglet.png" :
                                                                        "qrc:/resources/images/piglet_search/missed_piglet_grayed.png"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        Text {
            id:                  scoreText
            anchors.top:         parent.top
            anchors.right:       parent.right
            anchors.topMargin:   30
            z:                   1
            text:                textText(pigletSearchPage.foundPigletsCount)
            color:               "yellow"
            font.pixelSize:      32
            font.family:         "Courier"
            horizontalAlignment: Text.AlignRight
            verticalAlignment:   Text.AlignVCenter

            function textText(found_piglets) {
                var score = found_piglets + "";

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
            z:                   1
            text:                textText(pigletSearchPage.highScore)
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

        Text {
            id:                       timerText
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin:     30
            z:                        1
            visible:                  countdownTimer.running
            text:                     textText(countdownTimer.countdownTime)
            color:                    "yellow"
            font.pixelSize:           32
            font.family:              "Courier"
            horizontalAlignment:      Text.AlignHCenter
            verticalAlignment:        Text.AlignVCenter

            function textText(countdown_time) {
                if (countdown_time > 0) {
                    var time = (countdown_time / 1000) + "";

                    while (time.length < 2) {
                        time = "0" + time;
                    }

                    return time;
                } else {
                    return "00";
                }
            }
        }

        Image {
            id:                       turnUpImage
            anchors.top:              highScoreText.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin:        8
            z:                        1
            width:                    128
            height:                   32
            visible:                  pigletSearchPage.currentPiglet !== null &&
                                      pigletSearchPage.currentPiglet.y < 0 - pigletSearchPage.currentPiglet.height
            source:                   "qrc:/resources/images/piglet_search/turn_up.png"
            fillMode:                 Image.PreserveAspectFit

            SequentialAnimation {
                loops:   Animation.Infinite
                running: true

                NumberAnimation {
                    target:   turnUpImage
                    property: "opacity"
                    from:     1.0
                    to:       0.0
                    duration: 300
                }

                NumberAnimation {
                    target:   turnUpImage
                    property: "opacity"
                    from:     0.0
                    to:       1.0
                    duration: 300
                }
            }
        }

        Image {
            id:                       turnDownImage
            anchors.bottom:           timerText.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin:     8
            z:                        1
            width:                    128
            height:                   32
            visible:                  pigletSearchPage.currentPiglet !== null &&
                                      pigletSearchPage.currentPiglet.y > backgroundRectangle.height
            source:                   "qrc:/resources/images/piglet_search/turn_down.png"
            fillMode:                 Image.PreserveAspectFit

            SequentialAnimation {
                loops:   Animation.Infinite
                running: true

                NumberAnimation {
                    target:   turnDownImage
                    property: "opacity"
                    from:     1.0
                    to:       0.0
                    duration: 300
                }

                NumberAnimation {
                    target:   turnDownImage
                    property: "opacity"
                    from:     0.0
                    to:       1.0
                    duration: 300
                }
            }
        }

        Image {
            id:                     turnLeftImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            z:                      1
            width:                  32
            height:                 128
            visible:                pigletSearchPage.currentPiglet !== null &&
                                    pigletSearchPage.currentPiglet.x < 0 - pigletSearchPage.currentPiglet.width
            source:                 "qrc:/resources/images/piglet_search/turn_left.png"
            fillMode:               Image.PreserveAspectFit

            SequentialAnimation {
                loops:   Animation.Infinite
                running: true

                NumberAnimation {
                    target:   turnLeftImage
                    property: "opacity"
                    from:     1.0
                    to:       0.0
                    duration: 300
                }

                NumberAnimation {
                    target:   turnLeftImage
                    property: "opacity"
                    from:     0.0
                    to:       1.0
                    duration: 300
                }
            }
        }

        Image {
            id:                     turnRightImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:          parent.right
            z:                      1
            width:                  32
            height:                 128
            visible:                pigletSearchPage.currentPiglet !== null &&
                                    pigletSearchPage.currentPiglet.x > backgroundRectangle.width
            source:                 "qrc:/resources/images/piglet_search/turn_right.png"
            fillMode:               Image.PreserveAspectFit

            SequentialAnimation {
                loops:   Animation.Infinite
                running: true

                NumberAnimation {
                    target:   turnRightImage
                    property: "opacity"
                    from:     1.0
                    to:       0.0
                    duration: 300
                }

                NumberAnimation {
                    target:   turnRightImage
                    property: "opacity"
                    from:     0.0
                    to:       1.0
                    duration: 300
                }
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
            fillMode:             Image.PreserveAspectFit

            MouseArea {
                id:           backButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    if (pigletSearchPage.currentPiglet !== null) {
                        pigletSearchPage.currentPiglet.destroy();

                        pigletSearchPage.currentPiglet = null;
                    }

                    pigletSearchPage.gameFinished("piglet_search");

                    mainStackView.pop();
                }
            }
        }
    }

    Accelerometer {
        id:               accelerometer
        dataRate:         10
        accelerationMode: Accelerometer.Gravity
        active:           pigletSearchPage.appInForeground && pigletSearchPage.pageActive

        property real lastZAccel: 0.0

        onReadingChanged: {
            lastZAccel = reading.z;
        }
    }

    RotationSensor {
        id:       rotationSensor
        dataRate: 10
        active:   pigletSearchPage.appInForeground && pigletSearchPage.pageActive

        property real lastZenith: 0.0

        onReadingChanged: {
            var zenith = reading.x;

            if (zenith < 0) {
                zenith = 0;
            }

            if (accelerometer.lastZAccel < 0) {
                zenith = 180 - zenith;
            }

            // Low-pass filter
            lastZenith = lastZenith + 0.25 * (zenith - lastZenith);

            if (pigletSearchPage.currentPiglet !== null) {
                pigletSearchPage.currentPiglet.updatePosition(compass.lastAzimuth, lastZenith);
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
                pigletSearchPage.currentPiglet.updatePosition(lastAzimuth, rotationSensor.lastZenith);
            }
        }
    }

    NotificationDialog {
        id:   gameStartedNotificationDialog
        z:    1
        text: qsTr("Your piglet wants to play hide-and-seek! Try to find him in your room using your phone's camera as fast as you can.")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_search/game_started.wav");

            gameStartTimer.start();
        }

        onClosed: {
            gameStartTimer.stop();

            pigletSearchPage.allowGameRestart   = true;
            pigletSearchPage.foundPigletsCount  = 0;
            pigletSearchPage.missedPigletsCount = 0;

            pigletSearchPage.createPiglet();
        }
    }

    QueryDialog {
        id:   highScoreQueryDialog
        z:    1
        text: qsTr("Congratulations, you have a new highscore! Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_search/high_score.wav");
        }

        onYes: {
            gameStartedNotificationDialog.open();
        }

        onNo: {
            pigletSearchPage.gameFinished("piglet_search");

            mainStackView.pop();
        }
    }

    QueryDialog {
        id:   gameOverQueryDialog
        z:    1
        text: qsTr("Game over. Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_search/game_over.wav");
        }

        onYes: {
            gameStartedNotificationDialog.open();
        }

        onNo: {
            pigletSearchPage.gameFinished("piglet_search");

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
        id:       countdownTimer
        interval: 1000
        repeat:   true

        property int countdownTime: 0

        onRunningChanged: {
            if (running && pigletSearchPage.currentPiglet !== null) {
                countdownTime = pigletSearchPage.currentPiglet.waitTime;
            } else {
                countdownTime = 0;
            }
        }

        onTriggered: {
            countdownTime = countdownTime - interval;
        }
    }

    Component.onCompleted: {
        highScore = parseInt(mainWindow.getSetting("PigletSearchHighScore", "0"), 10);
    }
}
