import QtQuick 2.9
import QtMultimedia 5.9
import QtSensors 5.9

import "Piglet"

Item {
    id: pigletPage

    property bool appInForeground:            Qt.application.active
    property bool pageActive:                 false
    property bool animationEnabled:           false

    property real lastGameTime:               (new Date()).getTime()
    property real accelShakeThreshold:        20.0

    property string nextAnimation:            ""
    property string wantedGame:               ""

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

    function performAnimation() {
        if (nextAnimation === "piglet_look_around") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_look_around.jpg",
                                                  "", nextAnimation, 55);
        } else if (nextAnimation === "piglet_laughs") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_laughs.jpg",
                                                  "qrc:/resources/sound/piglet/piglet_laughs.wav", nextAnimation, 55);
        } else if (nextAnimation === "piglet_in_sorrow"){
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_in_sorrow.jpg",
                                                  "", nextAnimation, 105);
        } else if (nextAnimation === "piglet_eats_candy") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_eats_candy.jpg",
                                                  "qrc:/resources/sound/piglet/piglet_eats_candy.wav", nextAnimation, 80);
        } else if (nextAnimation === "piglet_eats_cake") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_eats_cake.jpg",
                                                  "qrc:/resources/sound/piglet/piglet_eats_cake.wav", nextAnimation, 115);
        } else if (nextAnimation === "piglet_falls") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_falls.jpg",
                                                  "qrc:/resources/sound/piglet/piglet_falls.wav", nextAnimation, 80);
        } else if (nextAnimation === "piglet_feed_game_finished") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg",
                                                  "qrc:/resources/sound/piglet/piglet_feed_game_finished.wav", nextAnimation, 66);
        } else if (nextAnimation === "piglet_wash_game_finished") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_wash_game_finished.jpg",
                                                  "qrc:/resources/sound/piglet/piglet_wash_game_finished.wav", nextAnimation, 56);
        } else if (nextAnimation === "piglet_listen") {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_listen.jpg",
                                                  "", nextAnimation, 5);
        } else {
            animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_eyes_blink.jpg",
                                                  "", "piglet_eyes_blink", 40);
        }

        nextAnimation = "";
    }

    function restartAnimation() {
        animationSpriteSequence.running = false;

        pigletAnimationTimer.restart();
    }

    function isAnimationActive(src) {
        if (animationSpriteSequence.running && animationSpriteSequence.animationName === src) {
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

        property string audioSource: ""

        onError: {
            console.log(errorString);
        }

        function playAudio(src) {
            audioSource = src;
            source      = src;

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
                        if (!pigletPage.isAnimationActive("piglet_laughs") && pigletPage.nextAnimation !== "piglet_laughs") {
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
                id:           animationSpriteSequence
                anchors.fill: parent
                z:            pigletIdleImage.z - 1
                running:      false

                property int animationFrameWidth:          360
                property int animationFrameHeight:         640
                property int animationFrameRate:           15
                property int animationSpriteMaxFrameCount: 20

                property string animationName:             ""
                property string audioSource:               ""

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;

                        if (audioSource !== "") {
                            audio.playAudio(audioSource);
                        }
                    } else {
                        z = pigletIdleImage.z - 1;

                        if (audioSource === audio.audioSource) {
                            audio.stop();
                        }
                    }
                }

                onCurrentSpriteChanged: {
                    if (running && currentSprite === "animationFinishSprite") {
                        running = false;

                        pigletAnimationTimer.start();
                    }
                }

                function playAnimation(src, audio_src, name, frames_count) {
                    var sprite_code  = "import QtQuick 2.9; Sprite {}";
                    var sprites_list = [];
                    var sprite       = null;

                    var sprites_count = frames_count / animationSpriteMaxFrameCount;

                    if (frames_count % animationSpriteMaxFrameCount > 0) {
                        sprites_count++;
                    }

                    for (var i = 0; i < sprites_count; i++) {
                        sprite = Qt.createQmlObject(sprite_code, animationSpriteSequence, "animation%1Sprite".arg(i));

                        sprite.name   = "animation%1Sprite".arg(i);
                        sprite.source = src;

                        if (frames_count - animationSpriteMaxFrameCount * i >= animationSpriteMaxFrameCount) {
                            sprite.frameCount = animationSpriteMaxFrameCount;
                        } else {
                            sprite.frameCount = frames_count - animationSpriteMaxFrameCount * i;
                        }

                        sprite.frameWidth  = animationFrameWidth;
                        sprite.frameHeight = animationFrameHeight;
                        sprite.frameX      = animationSpriteMaxFrameCount * i * animationFrameWidth;
                        sprite.frameRate   = animationFrameRate;

                        if (i < sprites_count - 1) {
                            var to = {};

                            to["animation%1Sprite".arg(i + 1)] = 1;

                            sprite.to = to;
                        } else {
                            sprite.to = { "animationFinishSprite" : 1 };
                        }

                        sprites_list.push(sprite);
                    }

                    sprite = Qt.createQmlObject(sprite_code, animationSpriteSequence, "animationFinishSprite");

                    sprite.name        = "animationFinishSprite";
                    sprite.source      = src;
                    sprite.frameCount  = 1;
                    sprite.frameWidth  = animationFrameWidth;
                    sprite.frameHeight = animationFrameHeight;
                    sprite.frameX      = 0;
                    sprite.frameRate   = 1;
                    sprite.to          = { "animation0Sprite" : 1 };

                    sprites_list.push(sprite);

                    running = false;

                    for (var j = 0; j < sprites.length; j++) {
                        if (sprites[j].name !== "dummySprite") {
                            sprites[j].destroy();
                        }
                    }

                    animationName = name;
                    audioSource   = audio_src;
                    sprites       = sprites_list;
                    running       = true;
                }

                Sprite {
                    name: "dummySprite"
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

                    if (!pigletPage.isAnimationActive("piglet_falls") && pigletPage.nextAnimation !== "piglet_falls") {
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
