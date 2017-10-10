import QtQuick 2.9
import QtMultimedia 5.9
import QtSensors 5.9
import SpeechRecorder 1.0

import "Piglet"

Item {
    id: pigletPage

    property bool appInForeground:     Qt.application.active
    property bool pageActive:          false
    property bool animationEnabled:    false

    property real lastGameTime:        (new Date()).getTime()
    property real accelShakeThreshold: 50.0

    property string nextAnimation:     ""
    property string wantedGame:        ""

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            if (!pigletSpeechAnimatedSprite.running) {
                animationEnabled = true;

                pigletAnimationTimer.restart();
            }

            pigletRandomAnimationTimer.restart();
        } else {
            animationEnabled = false;
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            if (!pigletSpeechAnimatedSprite.running) {
                animationEnabled = true;

                pigletAnimationTimer.restart();
            }

            pigletRandomAnimationTimer.restart();
        } else {
            animationEnabled = false;
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

    function stopAnimation() {
        animationSpriteSequence.running = false;
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
        muted:  !pigletPage.appInForeground || !pigletPage.pageActive || speechAudio.playbackState === Audio.PlayingState

        property string audioSource: ""

        onError: {
            console.log(errorString);
        }

        function playAudio(src) {
            audioSource = src;
            source      = "";
            source      = src;

            seek(0);
            play();
        }
    }

    Audio {
        id:     speechAudio
        volume: 1.0
        muted:  !pigletPage.appInForeground || !pigletPage.pageActive || audio.playbackState === Audio.PlayingState

        property bool playbackWasStarted: false

        onError: {
            console.log(errorString);
        }

        onPlaybackStateChanged: {
            if (playbackWasStarted && playbackState !== Audio.PlayingState) {
                playbackWasStarted = false;

                pigletSpeechAnimatedSprite.running = false;
            }
        }

        function playAudio(src) {
            source = "";
            source = src;

            seek(0);
            play();

            playbackWasStarted = true;
        }
    }

    SpeechRecorder {
        id:                   speechRecorder
        volume:               1.0
        sampleRate:           16000
        sampleRateMultiplier: 1.5
        minVoiceDuration:     500
        minSilenceDuration:   100
        active:               pigletPage.appInForeground && pigletPage.pageActive && audio.playbackState       !== Audio.PlayingState &&
                                                                                     speechAudio.playbackState !== Audio.PlayingState

        onError: {
            console.log(errorString);
        }

        onVoiceFound: {
            pigletPage.animationEnabled = false;

            pigletPage.stopAnimation();

            pigletVoiceFoundAnimatedSprite.playAnimation();
        }

        onVoiceRecorded: {
            pigletVoiceFoundAnimatedSprite.running = false;

            pigletVoiceEndedAnimatedSprite.playAnimation(true);
        }

        onVoiceReset: {
            pigletVoiceFoundAnimatedSprite.running = false;

            pigletVoiceEndedAnimatedSprite.playAnimation(false);
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
                id:               pigletIdleImage
                anchors.centerIn: parent
                width:            parent.width
                height:           parent.height
                z:                5
                source:           "qrc:/resources/images/piglet/piglet_idle.jpg"
                fillMode:         Image.PreserveAspectCrop
                smooth:           true

                property bool geometrySettled: false

                onPaintedWidthChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width    = paintedWidth;
                        height   = paintedHeight;
                        fillMode = Image.Stretch;
                    }
                }

                onPaintedHeightChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width    = paintedWidth;
                        height   = paintedHeight;
                        fillMode = Image.Stretch;
                    }
                }
            }

            SpriteSequence {
                id:               animationSpriteSequence
                anchors.centerIn: parent
                width:            pigletIdleImage.width
                height:           pigletIdleImage.height
                z:                pigletIdleImage.z - 1
                running:          false

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

            Image {
                id:               pigletListenImage
                anchors.centerIn: parent
                width:            parent.width
                height:           parent.height
                z:                pigletIdleImage.z - 1
                source:           "qrc:/resources/images/piglet/piglet_listen.jpg"
                fillMode:         Image.PreserveAspectCrop
                smooth:           true

                property bool geometrySettled: false

                onPaintedWidthChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width    = paintedWidth;
                        height   = paintedHeight;
                        fillMode = Image.Stretch;
                    }
                }

                onPaintedHeightChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width    = paintedWidth;
                        height   = paintedHeight;
                        fillMode = Image.Stretch;
                    }
                }
            }

            AnimatedSprite {
                id:               pigletVoiceFoundAnimatedSprite
                anchors.centerIn: parent
                width:            pigletListenImage.width
                height:           pigletListenImage.height
                z:                pigletIdleImage.z - 1
                running:          false
                source:           "qrc:/resources/animations/piglet/piglet_voice_found.jpg"
                frameCount:       5
                frameWidth:       360
                frameHeight:      640
                frameX:           0
                frameRate:        15
                loops:            1

                onRunningChanged: {
                    if (running) {
                        z                   = pigletIdleImage.z + 1;
                    } else {
                        pigletListenImage.z = pigletIdleImage.z + 1;
                        z                   = pigletIdleImage.z - 1;
                    }
                }

                onCurrentFrameChanged: {
                    if (running && currentFrame === frameCount - 1) {
                        running = false;
                    }
                }

                function playAnimation() {
                    currentFrame = 0;
                    running      = true;
                }
            }

            AnimatedSprite {
                id:               pigletVoiceEndedAnimatedSprite
                anchors.centerIn: parent
                width:            pigletListenImage.width
                height:           pigletListenImage.height
                z:                pigletIdleImage.z - 1
                running:          false
                source:           "qrc:/resources/animations/piglet/piglet_voice_ended.jpg"
                frameCount:       5
                frameWidth:       360
                frameHeight:      640
                frameX:           0
                frameRate:        15
                loops:            1

                property bool voiceRecorded: false

                onRunningChanged: {
                    if (running) {
                        z                   = pigletIdleImage.z + 1;
                        pigletListenImage.z = pigletIdleImage.z - 1;
                    } else {
                        z                   = pigletIdleImage.z - 1;

                        if (voiceRecorded) {
                            pigletSpeechAnimatedSprite.playAnimation();
                        } else {
                            pigletPage.animationEnabled = true;

                            pigletPage.restartAnimation();
                        }
                    }
                }

                onCurrentFrameChanged: {
                    if (running && currentFrame === frameCount - 1) {
                        running = false;
                    }
                }

                function playAnimation(voice_recorded) {
                    currentFrame  = 0;
                    voiceRecorded = voice_recorded;
                    running       = true;
                }
            }

            AnimatedSprite {
                id:               pigletSpeechAnimatedSprite
                anchors.centerIn: parent
                width:            pigletIdleImage.width
                height:           pigletIdleImage.height
                z:                pigletIdleImage.z - 1
                running:          false
                source:           "qrc:/resources/animations/piglet/piglet_speech.jpg"
                frameCount:       4
                frameWidth:       360
                frameHeight:      640
                frameX:           0
                frameRate:        10
                loops:            AnimatedSprite.Infinite

                onRunningChanged: {
                    if (running) {
                        z = pigletIdleImage.z + 1;

                        speechAudio.playAudio(speechRecorder.voiceFileURL);
                    } else {
                        z = pigletIdleImage.z - 1;

                        pigletPage.animationEnabled = true;

                        pigletPage.restartAnimation();
                    }
                }

                function playAnimation() {
                    currentFrame = 0;
                    running      = true;
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
    }

    Accelerometer {
        id:       accelerometer
        dataRate: 10
        active:   pigletPage.appInForeground && pigletPage.pageActive

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
