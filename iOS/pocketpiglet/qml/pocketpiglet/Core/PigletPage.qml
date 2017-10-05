import QtQuick 2.9
import QtMultimedia 5.9
import QtSensors 5.9

import "Piglet"

Item {
    id: pigletPage

    property bool appInForeground:            Qt.application.active
    property bool pageActive:                 false
    property bool animationEnabled:           false

    property int  animationsCount:            0
    property int  initializedAnimationsCount: 0

    property real lastGameTime:               (new Date()).getTime()
    property real accelShakeThreshold:        20.0

    property string nextAnimation:            ""
    property string wantedGame:               ""

    property SpriteSequence currentAnimation: null

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            animationEnabled = true;

            accelerometer.active = true;

            pigletAnimationTimer.restart();
            pigletRandomAnimationTimer.restart();
        } else {
            animationEnabled = false;

            accelerometer.active = false;
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            animationEnabled = true;

            accelerometer.active = true;

            pigletAnimationTimer.restart();
            pigletRandomAnimationTimer.restart();
        } else {
            animationEnabled = false;

            accelerometer.active = false;
        }
    }

    function gameFinished(game) {
        lastGameTime = (new Date()).getTime();

        if (game === wantedGame) {
            wantedGame = "";

            unhighlightGameButtons();
        }

        if (game === "piglet_feed") {
            nextAnimation = "piglet_feed_game_finished";
        } else if (game === "piglet_wash") {
            nextAnimation = "piglet_wash_game_finished";
        } else {
            nextAnimation = "";
        }
    }

    function animationInitialized() {
        if (animationsCount === 0) {
            for (var i = 0; i < pigletMouseArea.children.length; i++) {
                if (pigletMouseArea.children[i].hasOwnProperty("animationName")) {
                    animationsCount++;
                }
            }
        }

        if (initializedAnimationsCount < animationsCount) {
            initializedAnimationsCount++;
        } else if (initializedAnimationsCount === animationsCount) {
            initializedAnimationsCount++;

            console.debug("ANIMATIONS INITIALIZED");
        }
    }

    function performAnimation() {
        if (nextAnimation === "piglet_look_around") {
            spriteSequencePigletLookAround.running = true;

            currentAnimation = spriteSequencePigletLookAround;
        } else if (nextAnimation === "piglet_laughs") {
            audio.playAudio("qrc:/resources/sound/piglet/piglet_laughs.wav");

            spriteSequencePigletLaughs.running = true;

            currentAnimation = spriteSequencePigletLaughs;
        } else if (nextAnimation === "piglet_in_sorrow"){
            spriteSequencePigletInSorrow.running = true;

            currentAnimation = spriteSequencePigletInSorrow;
        } else if (nextAnimation === "piglet_eats_candy") {
            spriteSequencePigletEatsCandy.running = true;

            currentAnimation = spriteSequencePigletEatsCandy;
        } else if (nextAnimation === "piglet_eats_cake") {
            spriteSequencePigletEatsCake.running = true;

            currentAnimation = spriteSequencePigletEatsCake;
        } else if (nextAnimation === "piglet_falls") {
            spriteSequencePigletFalls.running = true;

            currentAnimation = spriteSequencePigletFalls;
        } else if (nextAnimation === "piglet_feed_game_finished") {
            spriteSequencePigletFeedGameFinished.running = true;

            currentAnimation = spriteSequencePigletFeedGameFinished;
        } else if (nextAnimation === "piglet_wash_game_finished") {
            spriteSequencePigletWashGameFinished.running = true;

            currentAnimation = spriteSequencePigletWashGameFinished;
        } else if (nextAnimation === "piglet_listen") {
            spriteSequencePigletListen.running = true;

            currentAnimation = spriteSequencePigletListen;
        } else {
            spriteSequencePigletEyesBlink.running = true;

            currentAnimation = spriteSequencePigletEyesBlink;
        }

        nextAnimation = "";
    }

    function restartAnimation() {
        audio.stop();

        if (currentAnimation !== null) {
            currentAnimation.running = false;
        }

        pigletAnimationTimer.restart();
    }

    function isAnimationActive(src) {
        if (currentAnimation !== null && currentAnimation.animationName === src) {
            return true;
        } else {
            return false;
        }
    }

    function unhighlightGameButtons() {
        for (var i = 0; i < gameButtonsColumn.children.length; i++) {
            gameButtonsColumn.children[i].unhighlightButton();
        }
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletPage.appInForeground || !pigletPage.pageActive

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

        MouseArea {
            id:           pigletMouseArea
            anchors.fill: parent

            property int pressX:   -1
            property int pressY:   -1
            property int totalPath: 0

            onPressed: {
                pressX    = mouse.x;
                pressY    = mouse.y;
                totalPath = 0;
            }

            onPositionChanged: {
                if (pressX !== -1 && pressY !== -1) {
                    totalPath = totalPath + Math.sqrt(Math.pow(mouse.x - pressX, 2) + Math.pow(mouse.y - pressY, 2));
                    pressX    = mouse.x;
                    pressY    = mouse.y;

                    if (totalPath > 500) {
                        if (!pigletPage.isAnimationActive("piglet_laughs")) {
                            pigletPage.nextAnimation = "piglet_laughs";

                            pigletPage.restartAnimation();
                        }

                        pressX    = -1;
                        pressY    = -1;
                        totalPath =  0;
                    }
                }
            }

            Image {
                id:           pigletIdleImage
                anchors.fill: parent
                z:            5
                source:       "qrc:/resources/images/piglet/piglet_idle.jpg"
                fillMode:     Image.Stretch
                smooth:       true
            }

            SpriteSequence {
                id:           spriteSequencePigletEyesBlink
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_eyes_blink"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletEyesBlinkStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletEyesBlinkStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletEyesBlinkStart"
                    source:      "qrc:/resources/animations/piglet/piglet_eyes_blink.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletEyesBlinkOne" : 1 }
                }

                Sprite {
                    name:        "pigletEyesBlinkOne"
                    source:      "qrc:/resources/animations/piglet/piglet_eyes_blink.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletEyesBlinkTwo" : 1 }
                }

                Sprite {
                    name:        "pigletEyesBlinkTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_eyes_blink.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletEyesBlinkStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletLookAround
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_look_around"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletLookAroundStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletLookAroundStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletLookAroundStart"
                    source:      "qrc:/resources/animations/piglet/piglet_look_around.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletLookAroundOne" : 1 }
                }

                Sprite {
                    name:        "pigletLookAroundOne"
                    source:      "qrc:/resources/animations/piglet/piglet_look_around.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletLookAroundTwo" : 1 }
                }

                Sprite {
                    name:        "pigletLookAroundTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_look_around.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletLookAroundThree" : 1 }
                }

                Sprite {
                    name:        "pigletLookAroundThree"
                    source:      "qrc:/resources/animations/piglet/piglet_look_around.jpg"
                    frameCount:  15
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletLookAroundStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletLaughs
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_laughs"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletLaughsStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletLaughsStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletLaughsStart"
                    source:      "qrc:/resources/animations/piglet/piglet_laughs.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletLaughsOne" : 1 }
                }

                Sprite {
                    name:        "pigletLaughsOne"
                    source:      "qrc:/resources/animations/piglet/piglet_laughs.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletLaughsTwo" : 1 }
                }

                Sprite {
                    name:        "pigletLaughsTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_laughs.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletLaughsThree" : 1 }
                }

                Sprite {
                    name:        "pigletLaughsThree"
                    source:      "qrc:/resources/animations/piglet/piglet_laughs.jpg"
                    frameCount:  15
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletLaughsStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletInSorrow
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_in_sorrow"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletInSorrowStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletInSorrowStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletInSorrowStart"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletInSorrowOne" : 1 }
                }

                Sprite {
                    name:        "pigletInSorrowOne"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletInSorrowTwo" : 1 }
                }

                Sprite {
                    name:        "pigletInSorrowTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletInSorrowThree" : 1 }
                }

                Sprite {
                    name:        "pigletInSorrowThree"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletInSorrowFour" : 1 }
                }

                Sprite {
                    name:        "pigletInSorrowFour"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      21600
                    frameRate:   15
                    to:          { "pigletInSorrowFive" : 1 }
                }

                Sprite {
                    name:        "pigletInSorrowFive"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      28800
                    frameRate:   15
                    to:          { "pigletInSorrowSix" : 1 }
                }

                Sprite {
                    name:        "pigletInSorrowSix"
                    source:      "qrc:/resources/animations/piglet/piglet_in_sorrow.jpg"
                    frameCount:  5
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      36000
                    frameRate:   15
                    to:          { "pigletInSorrowStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletEatsCandy
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_eats_candy"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletEatsCandyStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletEatsCandyStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletEatsCandyStart"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_candy.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletEatsCandyOne" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCandyOne"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_candy.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletEatsCandyTwo" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCandyTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_candy.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletEatsCandyThree" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCandyThree"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_candy.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletEatsCandyFour" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCandyFour"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_candy.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      21600
                    frameRate:   15
                    to:          { "pigletEatsCandyStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletEatsCake
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_eats_cake"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletEatsCakeStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletEatsCakeStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletEatsCakeStart"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletEatsCakeOne" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCakeOne"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletEatsCakeTwo" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCakeTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletEatsCakeThree" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCakeThree"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletEatsCakeFour" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCakeFour"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      21600
                    frameRate:   15
                    to:          { "pigletEatsCakeFive" : 1 }
                }
                Sprite {
                    name:        "pigletEatsCakeFive"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      28800
                    frameRate:   15
                    to:          { "pigletEatsCakeSix" : 1 }
                }

                Sprite {
                    name:        "pigletEatsCakeSix"
                    source:      "qrc:/resources/animations/piglet/piglet_eats_cake.jpg"
                    frameCount:  15
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      36000
                    frameRate:   15
                    to:          { "pigletEatsCakeStart" : 1 }
                }

            }

            SpriteSequence {
                id:           spriteSequencePigletFalls
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_falls"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletFallsStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletFallsStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletFallsStart"
                    source:      "qrc:/resources/animations/piglet/piglet_falls.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletFallsOne" : 1 }
                }

                Sprite {
                    name:        "pigletFallsOne"
                    source:      "qrc:/resources/animations/piglet/piglet_falls.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletFallsTwo" : 1 }
                }

                Sprite {
                    name:        "pigletFallsTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_falls.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletFallsThree" : 1 }
                }

                Sprite {
                    name:        "pigletFallsThree"
                    source:      "qrc:/resources/animations/piglet/piglet_falls.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletFallsFour" : 1 }
                }

                Sprite {
                    name:        "pigletFallsFour"
                    source:      "qrc:/resources/animations/piglet/piglet_falls.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      21600
                    frameRate:   15
                    to:          { "pigletFallsStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletFeedGameFinished
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_feed_game_finished"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletFeedGameFinishedStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletFeedGameFinishedStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletFeedGameFinishedStart"
                    source:      "qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletFeedGameFinishedOne" : 1 }
                }

                Sprite {
                    name:        "pigletFeedGameFinishedOne"
                    source:      "qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletFeedGameFinishedTwo" : 1 }
                }

                Sprite {
                    name:        "pigletFeedGameFinishedTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletFeedGameFinishedThree" : 1 }
                }

                Sprite {
                    name:        "pigletFeedGameFinishedThree"
                    source:      "qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletFeedGameFinishedFour" : 1 }
                }

                Sprite {
                    name:        "pigletFeedGameFinishedFour"
                    source:      "qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg"
                    frameCount:  6
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      21600
                    frameRate:   15
                    to:          { "pigletFeedGameFinishedStart" : 1 }
                }
            }

            SpriteSequence {
                id:           spriteSequencePigletWashGameFinished
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_wash_game_finished"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletWashGameFinishedStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletWashGameFinishedStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletWashGameFinishedStart"
                    source:      "qrc:/resources/animations/piglet/piglet_wash_game_finished.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletWashGameFinishedOne" : 1 }
                }

                Sprite {
                    name:        "pigletWashGameFinishedOne"
                    source:      "qrc:/resources/animations/piglet/piglet_wash_game_finished.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletWashGameFinishedTwo" : 1 }
                }

                Sprite {
                    name:        "pigletWashGameFinishedTwo"
                    source:      "qrc:/resources/animations/piglet/piglet_wash_game_finished.jpg"
                    frameCount:  20
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      7200
                    frameRate:   15
                    to:          { "pigletWashGameFinishedThree" : 1 }
                }

                Sprite {
                    name:        "pigletWashGameFinishedThree"
                    source:      "qrc:/resources/animations/piglet/piglet_wash_game_finished.jpg"
                    frameCount:  16
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      14400
                    frameRate:   15
                    to:          { "pigletWashGameFinishedStart" : 1 }
                }
            }


            SpriteSequence {
                id:           spriteSequencePigletListen
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property string animationName: "piglet_listen"

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;
                    } else {
                        z = pigletIdleImage.z - 1;

                        jumpTo("pigletListenStart");

                        pigletAnimationTimer.start();
                    }
                }

                onCurrentSpriteChanged: {
                    pigletPage.animationInitialized();

                    if (running && currentSprite === "pigletListenStart") {
                        running = false;
                    }
                }

                Sprite {
                    name:        "pigletListenStart"
                    source:      "qrc:/resources/animations/piglet/piglet_listen.jpg"
                    frameCount:  1
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   1
                    to:          { "pigletListenOne" : 1 }
                }

                Sprite {
                    name:        "pigletListenOne"
                    source:      "qrc:/resources/animations/piglet/piglet_listen.jpg"
                    frameCount:  5
                    frameWidth:  360
                    frameHeight: 640
                    frameX:      0
                    frameRate:   15
                    to:          { "pigletListenStart" : 1 }
                }
            }
        }

        Column {
            id:             gameButtonsColumn
            anchors.left:   parent.left
            anchors.bottom: parent.bottom
            z:              10
            spacing:        16
            bottomPadding:  16

            GameButton {
                id:                pigletFeedGameButton
                width:             64
                height:            64
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_feed.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_feed_highlighted.png"

                onStartGame: {
                    var component = Qt.createComponent("PigletFeedPage.qml");

                    if (component.status === Component.Ready) {
                        mainStackView.push(component);
                    } else {
                        console.log(component.errorString());
                    }
                }
            }

            GameButton {
                id:                pigletWashGameButton
                width:             64
                height:            64
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_wash.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_wash_highlighted.png"

                onStartGame: {
                    var component = Qt.createComponent("PigletWashPage.qml");

                    if (component.status === Component.Ready) {
                        mainStackView.push(component);
                    } else {
                        console.log(component.errorString());
                    }
                }
            }

            GameButton {
                id:                pigletPuzzleGameButton
                width:             64
                height:            64
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_puzzle.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_puzzle_highlighted.png"

                onStartGame: {
                    var component = Qt.createComponent("PigletPuzzlePage.qml");

                    if (component.status === Component.Ready) {
                        mainStackView.push(component);
                    } else {
                        console.log(component.errorString());
                    }
                }
            }
        }

        Column {
            id:             actionButtonsColumn
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            z:              10
            spacing:        16
            bottomPadding:  16

            ActionButton {
                id:     cakeActionButton
                width:  64
                height: 64
                source: "qrc:/resources/images/piglet/action_cake.png"

                onStartAction: {
                    pigletPage.nextAnimation = "piglet_eats_cake";

                    pigletPage.restartAnimation();
                }
            }

            ActionButton {
                id:     candyActionButton
                width:  64
                height: 64
                source: "qrc:/resources/images/piglet/action_candy.png"

                onStartAction: {
                    pigletPage.nextAnimation = "piglet_eats_candy";

                    pigletPage.restartAnimation();
                }
            }
        }

        /*
        Image {
            id:             helpButtonImage
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            width:          48
            height:         48
            z:              10
            source:         "qrc:/resources/images/help.png"

            MouseArea {
                id:           helpButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    waitRectangle.visible = true;

                    pigletPage.animationEnabled = false;
                    pigletPage.nextPage         = helpPage;

                    pigletAnimationVideoPlayerLoader.unloadVideoPlayerAndReplacePage();
                }
            }
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
                    Qt.quit();
                }
            }
        }
        */
    }

    Accelerometer {
        id:       accelerometer
        dataRate: 10

        property real lastReadingX: 0.0
        property real lastReadingY: 0.0
        property real lastReadingZ: 0.0

        onReadingChanged: {
            if (lastReadingX !== 0.0 || lastReadingY !== 0.0 || lastReadingZ !== 0.0) {
                if (Math.abs(reading.x - lastReadingX) > pigletPage.accelShakeThreshold ||
                    Math.abs(reading.y - lastReadingY) > pigletPage.accelShakeThreshold ||
                    Math.abs(reading.z - lastReadingZ) > pigletPage.accelShakeThreshold) {

                    if (!pigletPage.isAnimationActive("piglet_falls")) {
                        pigletPage.nextAnimation = "piglet_falls";

                        pigletPage.restartAnimation();
                    }                    
                }
            }

            lastReadingX = reading.x;
            lastReadingY = reading.y;
            lastReadingZ = reading.z;
        }
    }

    Timer {
        id:       pigletAnimationTimer
        interval: 100

        onTriggered: {
            if (pigletPage.animationEnabled) {
                pigletPage.performAnimation();
            }
        }
    }

    Timer {
        id:       pigletRandomAnimationTimer
        interval: 10000 + 5000 * Math.random()
        repeat:   true

        onTriggered: {
            if (pigletPage.nextAnimation === "") {
                if ((new Date()).getTime() > pigletPage.lastGameTime + 60000) {
                    if (pigletPage.wantedGame === "") {
                        var rand = Math.random();

                        if (rand < 0.33) {
                            pigletPage.wantedGame = "piglet_feed";

                            pigletFeedGameButton.highlightButton();
                        } else if (rand < 0.66) {
                            pigletPage.wantedGame = "piglet_wash";

                            pigletWashGameButton.highlightButton();
                        } else {
                            pigletPage.wantedGame = "piglet_puzzle";

                            pigletPuzzleGameButton.highlightButton();
                        }
                    }
                }

                if (pigletPage.wantedGame === "") {
                    pigletPage.nextAnimation = "piglet_look_around";
                } else {
                    pigletPage.nextAnimation = "piglet_in_sorrow";
                }
            }

            interval = 10000 + 5000 * Math.random();

            restart();
        }
    }
}
