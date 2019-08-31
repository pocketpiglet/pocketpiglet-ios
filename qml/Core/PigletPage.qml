import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtSensors 5.12
import SpeechRecorder 1.0

import "Dialog"
import "Piglet"

import "../Util.js" as UtilScript

Item {
    id: pigletPage

    readonly property bool appInForeground:     Qt.application.state === Qt.ApplicationActive
    readonly property bool pageActive:          StackView.status === StackView.Active

    readonly property int diamondsMaxAmount:    10

    readonly property real accelShakeThreshold: 50.0

    property bool animationEnabled:             false

    property int diamondsAmount:                0

    property double lastGameTime:               (new Date()).getTime()

    property string nextAnimation:              ""
    property string wantedGame:                 ""

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            if (!pigletSaysAnimatedSprite.running) {
                animationEnabled = true;

                performAnimation();
            }
        } else {
            animationEnabled = false;
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            if (!pigletSaysAnimatedSprite.running) {
                animationEnabled = true;

                performAnimation();
            }
        } else {
            animationEnabled = false;
        }
    }

    onDiamondsAmountChanged: {
        mainWindow.setSetting("PigletDiamondsAmount", diamondsAmount.toString(10));
    }

    function handleGameFinish(game) {
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
        if (animationEnabled) {
            if (nextAnimation === "piglet_looks_around") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_looks_around.jpg",
                                                      "", nextAnimation, 55, 15);
            } else if (nextAnimation === "piglet_laughs") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_laughs.jpg",
                                                      "qrc:/resources/sound/piglet/piglet_laughs.wav", nextAnimation, 55, 15);
            } else if (nextAnimation === "piglet_in_sorrow"){
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_in_sorrow.jpg",
                                                      "", nextAnimation, 105, 15);
            } else if (nextAnimation === "piglet_eats_candy") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_eats_candy.jpg",
                                                      "qrc:/resources/sound/piglet/piglet_eats_candy.wav", nextAnimation, 75, 15);
            } else if (nextAnimation === "piglet_eats_cake") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_eats_cake.jpg",
                                                      "qrc:/resources/sound/piglet/piglet_eats_cake.wav", nextAnimation, 115, 15);
            } else if (nextAnimation === "piglet_falls") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_falls.jpg",
                                                      "qrc:/resources/sound/piglet/piglet_falls.wav", nextAnimation, 80, 15);
            } else if (nextAnimation === "piglet_feed_game_finished") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_feed_game_finished.jpg",
                                                      "qrc:/resources/sound/piglet/piglet_feed_game_finished.wav", nextAnimation, 66, 15);
            } else if (nextAnimation === "piglet_wash_game_finished") {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_wash_game_finished.jpg",
                                                      "qrc:/resources/sound/piglet/piglet_wash_game_finished.wav", nextAnimation, 56, 15);
            } else {
                animationSpriteSequence.playAnimation("qrc:/resources/animations/piglet/piglet_blinks.jpg",
                                                      "", "piglet_blinks", 40, 15);
            }

            nextAnimation = "";
        }
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
            gameButtonsColumn.children[i].highlighted = false;
        }
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletPage.appInForeground || !pigletPage.pageActive ||
                speechAudio.playbackState === Audio.PlayingState

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
        muted:  !pigletPage.appInForeground || !pigletPage.pageActive ||
                audio.playbackState === Audio.PlayingState

        property bool playbackWasStarted: false

        onError: {
            console.log(errorString);
        }

        onPlaybackStateChanged: {
            if (playbackWasStarted && playbackState !== Audio.PlayingState) {
                playbackWasStarted = false;

                pigletSaysAnimatedSprite.running = false;
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
        active:               pigletPage.appInForeground && pigletPage.pageActive &&
                              audio.playbackState       !== Audio.PlayingState &&
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

            readonly property int minStrokingDistance: UtilScript.pt(200)

            property int totalDistance:                0
            property int lastEventX:                  -1
            property int lastEventY:                  -1

            onPressed: {
                totalDistance = 0;
                lastEventX    = mouse.x;
                lastEventY    = mouse.y;
            }

            onPositionChanged: {
                if (lastEventX !== -1 && lastEventY !== -1) {
                    totalDistance = totalDistance + Math.sqrt(Math.pow(mouse.x - lastEventX, 2) + Math.pow(mouse.y - lastEventY, 2));
                    lastEventX    = mouse.x;
                    lastEventY    = mouse.y;

                    if (totalDistance > minStrokingDistance) {
                        if (!pigletPage.isAnimationActive("piglet_laughs") && pigletPage.nextAnimation !== "piglet_laughs") {
                            pigletPage.nextAnimation = "piglet_laughs";

                            pigletPage.performAnimation();
                        }

                        totalDistance =  0;
                        lastEventX    = -1;
                        lastEventY    = -1;
                    }
                }
            }

            Image {
                id:               pigletIdleImage
                anchors.centerIn: parent
                z:                5
                width:            parent.width
                height:           parent.height
                source:           "qrc:/resources/images/piglet/piglet_idle.jpg"
                fillMode:         Image.PreserveAspectCrop

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
                z:                running ? pigletIdleImage.z + 1 : pigletIdleImage.z - 1
                width:            pigletIdleImage.width
                height:           pigletIdleImage.height
                running:          false

                readonly property int animationFrameWidth:          360
                readonly property int animationFrameHeight:         640
                readonly property int animationSpriteMaxFrameCount: 20

                property string animationName:                      ""
                property string audioSource:                        ""

                property var animationCache:                        ({})

                onRunningChanged: {
                    if (running) {
                        if (audioSource !== "") {
                            audio.playAudio(audioSource);
                        }
                    } else {
                        if (audioSource === audio.audioSource) {
                            audio.stop();
                        }
                    }
                }

                onCurrentSpriteChanged: {
                    if (running && currentSprite === "animationFinishSprite") {
                        running = false;

                        pigletPage.performAnimation();
                    }
                }

                function playAnimation(src, audio_src, name, frames_count, frame_rate) {
                    var sprites_list = [];

                    if (animationCache[name]) {
                        sprites_list = animationCache[name];
                    } else {
                        var sprite_code = "import QtQuick 2.9; Sprite {}";
                        var sprite      = null;

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
                            sprite.frameRate   = frame_rate;

                            if (i < sprites_count - 1) {
                                var to = {};

                                to["animation%1Sprite".arg(i + 1)] = 1;

                                sprite.to = to;
                            } else {
                                sprite.to = {"animationFinishSprite": 1};
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
                        sprite.to          = {"animation0Sprite": 1};

                        sprites_list.push(sprite);
                    }

                    running = false;

                    if (!animationCache[animationName]) {
                        for (var j = 0; j < sprites.length; j++) {
                            if (sprites[j].name !== "dummySprite") {
                                sprites[j].destroy();
                            }
                        }
                    }

                    animationName = name;
                    audioSource   = audio_src;
                    sprites       = sprites_list;
                    running       = true;
                }

                function cacheAnimation(src, name, frames_count, frame_rate) {
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
                        sprite.frameRate   = frame_rate;

                        if (i < sprites_count - 1) {
                            var to = {};

                            to["animation%1Sprite".arg(i + 1)] = 1;

                            sprite.to = to;
                        } else {
                            sprite.to = {"animationFinishSprite": 1};
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
                    sprite.to          = {"animation0Sprite": 1};

                    sprites_list.push(sprite);

                    animationCache[name] = sprites_list;
                }

                Sprite {
                    name: "dummySprite"
                }
            }

            Image {
                id:               pigletListensImage
                anchors.centerIn: parent
                z:                pigletIdleImage.z - 1
                width:            parent.width
                height:           parent.height
                source:           "qrc:/resources/images/piglet/piglet_listens.jpg"
                fillMode:         Image.PreserveAspectCrop

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
                z:                running ? pigletIdleImage.z + 1 : pigletIdleImage.z - 1
                width:            pigletListensImage.width
                height:           pigletListensImage.height
                running:          false
                source:           "qrc:/resources/animations/piglet/piglet_voice_found.jpg"
                frameCount:       5
                frameWidth:       360
                frameHeight:      640
                frameX:           0
                frameRate:        15
                loops:            1

                onRunningChanged: {
                    if (!running) {
                        pigletListensImage.z = pigletIdleImage.z + 1;
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
                z:                running ? pigletIdleImage.z + 1 : pigletIdleImage.z - 1
                width:            pigletListensImage.width
                height:           pigletListensImage.height
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
                        pigletListensImage.z = pigletIdleImage.z - 1;
                    } else {
                        if (voiceRecorded) {
                            pigletSaysAnimatedSprite.playAnimation();
                        } else {
                            pigletPage.animationEnabled = true;

                            pigletPage.performAnimation();
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
                id:               pigletSaysAnimatedSprite
                anchors.centerIn: parent
                z:                running ? pigletIdleImage.z + 1 : pigletIdleImage.z - 1
                width:            pigletIdleImage.width
                height:           pigletIdleImage.height
                running:          false
                source:           "qrc:/resources/animations/piglet/piglet_says.jpg"
                frameCount:       4
                frameWidth:       360
                frameHeight:      640
                frameX:           0
                frameRate:        10
                loops:            AnimatedSprite.Infinite

                onRunningChanged: {
                    if (running) {
                        speechAudio.playAudio(speechRecorder.voiceFileURL);
                    } else {
                        pigletPage.animationEnabled = true;

                        pigletPage.performAnimation();
                    }
                }

                function playAnimation() {
                    currentFrame = 0;
                    running      = true;
                }
            }
        }

        Column {
            id:           currencyButtonsColumn
            anchors.left: parent.left
            anchors.top:  parent.top
            z:            1
            spacing:      UtilScript.pt(16)
            topPadding:   UtilScript.pt(16)

            CurrencyButton {
                id:                diamondCurrencyButton
                imageWidth:        UtilScript.pt(64)
                imageHeight:       UtilScript.pt(64)
                sourceNormal:      "qrc:/resources/images/piglet/currency_diamond.png"
                sourceHighlighted: "qrc:/resources/images/piglet/currency_diamond_highlighted.png"
                amount:            pigletPage.diamondsAmount
                visible:           !mainWindow.fullVersion

                onClicked: {
                    parentalGateDialog.open();
                }
            }
        }

        Column {
            id:             gameButtonsColumn
            anchors.left:   parent.left
            anchors.bottom: parent.bottom
            z:              1
            spacing:        UtilScript.pt(16)
            bottomPadding:  UtilScript.pt(16)

            GameButton {
                id:                pigletFeedGameButton
                width:             UtilScript.pt(64)
                height:            UtilScript.pt(64)
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_feed.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_feed_highlighted.png"

                onClicked: {
                    if (mainWindow.fullVersion || pigletPage.diamondsAmount > 0) {
                        var component = Qt.createComponent("PigletFeedPage.qml");

                        if (component.status === Component.Ready) {
                            var object = component.createObject(null);

                            object.gameFinished.connect(pigletPage.handleGameFinish);

                            mainStackView.push(object);
                        } else {
                            console.log(component.errorString());
                        }

                        pigletPage.diamondsAmount = Math.max(pigletPage.diamondsAmount - 1, 0);
                    } else {
                        parentalGateDialog.open();
                    }
                }
            }

            GameButton {
                id:                pigletWashGameButton
                width:             UtilScript.pt(64)
                height:            UtilScript.pt(64)
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_wash.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_wash_highlighted.png"

                onClicked: {
                    if (mainWindow.fullVersion || pigletPage.diamondsAmount > 0) {
                        var component = Qt.createComponent("PigletWashPage.qml");

                        if (component.status === Component.Ready) {
                            var object = component.createObject(null);

                            object.gameFinished.connect(pigletPage.handleGameFinish);

                            mainStackView.push(object);
                        } else {
                            console.log(component.errorString());
                        }

                        pigletPage.diamondsAmount = Math.max(pigletPage.diamondsAmount - 1, 0);
                    } else {
                        parentalGateDialog.open();
                    }
                }
            }

            GameButton {
                id:                pigletPuzzleGameButton
                width:             UtilScript.pt(64)
                height:            UtilScript.pt(64)
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_puzzle.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_puzzle_highlighted.png"

                onClicked: {
                    if (mainWindow.fullVersion || pigletPage.diamondsAmount > 0) {
                        var component = Qt.createComponent("PigletPuzzlePage.qml");

                        if (component.status === Component.Ready) {
                            var object = component.createObject(null);

                            object.gameFinished.connect(pigletPage.handleGameFinish);

                            mainStackView.push(object);
                        } else {
                            console.log(component.errorString());
                        }

                        pigletPage.diamondsAmount = Math.max(pigletPage.diamondsAmount - 1, 0);
                    } else {
                        parentalGateDialog.open();
                    }
                }
            }

            GameButton {
                id:                pigletSearchGameButton
                width:             UtilScript.pt(64)
                height:            UtilScript.pt(64)
                sourceNormal:      "qrc:/resources/images/piglet/game_piglet_search.png"
                sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_search_highlighted.png"

                onClicked: {
                    if (mainWindow.fullVersion || pigletPage.diamondsAmount > 0) {
                        var component = Qt.createComponent("PigletSearchPage.qml");

                        if (component.status === Component.Ready) {
                            var object = component.createObject(null);

                            object.gameFinished.connect(pigletPage.handleGameFinish);

                            mainStackView.push(object);
                        } else {
                            console.log(component.errorString());
                        }

                        pigletPage.diamondsAmount = Math.max(pigletPage.diamondsAmount - 1, 0);
                    } else {
                        parentalGateDialog.open();
                    }
                }
            }
        }

        Column {
            id:             actionButtonsColumn
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            z:              1
            spacing:        UtilScript.pt(16)
            bottomPadding:  UtilScript.pt(16)

            ActionButton {
                id:     cakeActionButton
                width:  UtilScript.pt(64)
                height: UtilScript.pt(64)
                source: "qrc:/resources/images/piglet/action_cake.png"

                onClicked: {
                    if (mainWindow.fullVersion || pigletPage.diamondsAmount > 0) {
                        if (!pigletPage.isAnimationActive("piglet_eats_cake") && pigletPage.nextAnimation !== "piglet_eats_cake") {
                            pigletPage.nextAnimation = "piglet_eats_cake";

                            pigletPage.performAnimation();

                            pigletPage.diamondsAmount = Math.max(pigletPage.diamondsAmount - 1, 0);
                        }
                    } else {
                        parentalGateDialog.open();
                    }
                }
            }

            ActionButton {
                id:     candyActionButton
                width:  UtilScript.pt(64)
                height: UtilScript.pt(64)
                source: "qrc:/resources/images/piglet/action_candy.png"

                onClicked: {
                    if (mainWindow.fullVersion || pigletPage.diamondsAmount > 0) {
                        if (!pigletPage.isAnimationActive("piglet_eats_candy") && pigletPage.nextAnimation !== "piglet_eats_candy") {
                            pigletPage.nextAnimation = "piglet_eats_candy";

                            pigletPage.performAnimation();

                            pigletPage.diamondsAmount = Math.max(pigletPage.diamondsAmount - 1, 0);
                        }
                    } else {
                        parentalGateDialog.open();
                    }
                }
            }
        }
    }

    PurchaseDialog {
        id: purchaseDialog
        z:  1

        onGetFreeDiamondsSelected: {
            var diamonds_amount = pigletPage.diamondsAmount;

            pigletPage.diamondsAmount = Math.min(diamonds_amount + deliveredAmount, pigletPage.diamondsMaxAmount);

            newDiamondsDialog.open(pigletPage.diamondsAmount - diamonds_amount);
        }

        onPurchaseFullVersionSelected: {
            fullVersionProduct.purchase();
        }

        onRestorePurchasesSelected: {
            store.restorePurchases();
        }
    }

    NewDiamondsDialog {
        id: newDiamondsDialog
        z:  1

        onOk: {
            StoreHelper.requestReview();
        }
    }

    ParentalGateDialog {
        id: parentalGateDialog
        z:  1

        onPassed: {
            purchaseDialog.open(pigletPage.diamondsAmount < pigletPage.diamondsMaxAmount);
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
            if ((lastReadingX !== 0.0 || lastReadingY !== 0.0 || lastReadingZ !== 0.0) &&
                (Math.abs(reading.x - lastReadingX) > pigletPage.accelShakeThreshold ||
                 Math.abs(reading.y - lastReadingY) > pigletPage.accelShakeThreshold ||
                 Math.abs(reading.z - lastReadingZ) > pigletPage.accelShakeThreshold)) {
                if (!pigletPage.isAnimationActive("piglet_falls") && pigletPage.nextAnimation !== "piglet_falls") {
                    pigletPage.nextAnimation = "piglet_falls";

                    pigletPage.performAnimation();
                }
            }

            lastReadingX = reading.x;
            lastReadingY = reading.y;
            lastReadingZ = reading.z;
        }
    }

    Timer {
        id:       pigletRandomAnimationTimer
        running:  true
        interval: 10000 + 5000 * Math.random()
        repeat:   true

        onTriggered: {
            if (pigletPage.nextAnimation === "") {
                var elapsed = (new Date()).getTime() - pigletPage.lastGameTime;

                if ((elapsed < 0 || elapsed > 60000) && pigletPage.wantedGame === "") {
                    var rand = Math.random();

                    if (rand < 0.25) {
                        pigletPage.wantedGame = "piglet_feed";

                        pigletFeedGameButton.highlighted = true;
                    } else if (rand < 0.50) {
                        pigletPage.wantedGame = "piglet_wash";

                        pigletWashGameButton.highlighted = true;
                    } else if (rand < 0.75) {
                        pigletPage.wantedGame = "piglet_puzzle";

                        pigletPuzzleGameButton.highlighted = true;
                    } else {
                        pigletPage.wantedGame = "piglet_search";

                        pigletSearchGameButton.highlighted = true;
                    }
                }

                if (pigletPage.wantedGame === "") {
                    pigletPage.nextAnimation = "piglet_looks_around";
                } else {
                    pigletPage.nextAnimation = "piglet_in_sorrow";
                }
            }

            interval = 10000 + 5000 * Math.random();
        }
    }

    Component.onCompleted: {
        diamondsAmount = parseInt(mainWindow.getSetting("PigletDiamondsAmount", diamondsMaxAmount.toString(10)), 10);

        animationSpriteSequence.cacheAnimation("qrc:/resources/animations/piglet/piglet_eats_candy.jpg",
                                               "piglet_eats_candy", 75, 15);
        animationSpriteSequence.cacheAnimation("qrc:/resources/animations/piglet/piglet_eats_cake.jpg",
                                               "piglet_eats_cake", 115, 15);
    }
}
