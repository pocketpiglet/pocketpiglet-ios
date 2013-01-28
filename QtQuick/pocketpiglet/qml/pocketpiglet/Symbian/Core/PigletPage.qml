import QtQuick 1.1
import QtMobility.sensors 1.1
import com.nokia.symbian 1.0

import "Piglet"

Page {
    id:              pigletPage
    anchors.fill:    parent
    orientationLock: PageOrientation.LockPortrait

    property bool appInForeground:            true
    property bool pigletAnimationEnabled:     true
    property bool pigletAnimationVideoActive: false

    property real lastGameTime:               (new Date()).getTime()
    property real accelShakeThreshold:        10.0

    property string nextAnimationVideoSource: ""
    property string wantedGame:               ""

    property Page nextPage:                   pigletPage

    onStatusChanged: {
        if (status === PageStatus.Active && appInForeground) {
            pigletAnimationEnabled = true;

            accelerometer.start();

            pigletAnimationTimer.restart();
            pigletRandomAnimationTimer.restart();
        } else {
            pigletAnimationEnabled = false;

            accelerometer.stop();

            pigletAnimationVideoPlayerLoader.unloadVideoPlayer();
        }
    }

    onAppInForegroundChanged: {
        if (status === PageStatus.Active && appInForeground) {
            pigletAnimationEnabled = true;

            accelerometer.start();

            pigletAnimationTimer.restart();
            pigletRandomAnimationTimer.restart();
        } else {
            pigletAnimationEnabled = false;

            accelerometer.stop();

            pigletAnimationVideoPlayerLoader.unloadVideoPlayer();
        }
    }

    function gameFinished(game) {
        lastGameTime = (new Date()).getTime();

        if (game === wantedGame) {
            wantedGame = "";

            unhighlightGameButtons();
        }

        if (game === "piglet_feed") {
            nextAnimationVideoSource = "piglet_feed_game_finished.mp4";
        } else if (game === "piglet_wash") {
            nextAnimationVideoSource = "piglet_wash_game_finished.mp4";
        } else {
            nextAnimationVideoSource = "";
        }
    }

    function performAnimation() {
        if (nextAnimationVideoSource !== "") {
            pigletAnimationVideoPlayerLoader.playVideo(nextAnimationVideoSource);
        } else {
            pigletAnimationVideoPlayerLoader.playVideo("piglet_eyes_blink.mp4");
        }

        nextAnimationVideoSource = "";
    }

    function restartAnimation() {
        if (pigletAnimationVideoActive) {
            pigletAnimationVideoPlayerLoader.stopVideo();
        }

        pigletAnimationTimer.restart();
    }

    function isAnimationActive(src) {
        if ((pigletAnimationVideoActive === true  && src === pigletAnimationVideoPlayerLoader.videoSource) ||
            (pigletAnimationVideoActive === false && src === nextAnimationVideoSource)) {
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

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        MouseArea {
            id:           pigletMouseArea
            anchors.fill: parent

            property int pressX: 0
            property int pressY: 0

            onPressed: {
                pressX = mouse.x;
                pressY = mouse.y;
            }

            onPositionChanged: {
                if (pressX !== 0 && pressY !== 0) {
                    var len = Math.sqrt(Math.pow(mouse.x - pressX, 2) + Math.pow(mouse.y - pressY, 2));

                    if (len > 50) {
                        if (!pigletPage.isAnimationActive("piglet_laughs.mp4")) {
                            pigletPage.nextAnimationVideoSource = "piglet_laughs.mp4";

                            pigletPage.restartAnimation();
                        }

                        pressX = 0;
                        pressY = 0;
                    }
                }
            }

            Image {
                id:           pigletIdleImage
                anchors.fill: parent
                z:            5
                source:       "qrc:/resources/images/piglet/piglet_idle_" + mainWindow.targetPlatform + ".png"
                fillMode:     Image.PreserveAspectFit
                smooth:       true
            }

            Loader {
                id:           pigletAnimationVideoPlayerLoader
                anchors.fill: parent
                z:            pigletIdleImage.z - 1

                property bool   playerLoaded: false
                property bool   unloadPlayer: false
                property bool   replacePage:  false
                property string videoSource:  ""

                function playVideo(src) {
                    pigletPage.pigletAnimationVideoActive = false;

                    if (!playerLoaded) {
                        source = "Piglet/VideoPlayer.qml";

                        playerLoaded = true;
                    }

                    videoSource = src;

                    item.playVideo(src);
                }

                function stopVideo() {
                    item.stopVideo();
                }

                function unloadVideoPlayer() {
                    if (pigletPage.pigletAnimationVideoActive) {
                        unloadPlayer = true;

                        item.stopVideo();
                    } else {
                        // Unload VideoPlayer on Symbian because of crash while
                        // navigating between pages with loaded player, but not
                        // on Meego - to avoid problems with sound on other pages
                        if (mainWindow.targetPlatform === "symbian") {
                            source = "";

                            playerLoaded = false;
                        }
                    }
                }

                function unloadVideoPlayerAndReplacePage() {
                    if (pigletPage.pigletAnimationVideoActive) {
                        unloadPlayer = true;
                        replacePage  = true;

                        item.stopVideo();
                    } else {
                        // Unload VideoPlayer on Symbian because of crash while
                        // navigating between pages with loaded player, but not
                        // on Meego - to avoid problems with sound on other pages
                        if (mainWindow.targetPlatform === "symbian") {
                            source = "";

                            playerLoaded = false;
                        }

                        pageReplaceTimer.start();
                    }
                }

                Connections {
                    target:               pigletAnimationVideoPlayerLoader.item
                    ignoreUnknownSignals: true

                    onPlayerStarted: {
                        pigletPage.pigletAnimationVideoActive = true;
                    }

                    onPlayerPlaying: {
                        if (pigletPage.pigletAnimationVideoActive && pigletAnimationVideoPlayerLoader.z !== pigletIdleImage.z + 1) {
                            pigletAnimationVideoShowTimer.start();
                        }
                    }

                    onPlayerStopped: {
                        pigletPage.pigletAnimationVideoActive = false;

                        pigletAnimationVideoPlayerLoader.z = pigletIdleImage.z - 1;

                        pigletAnimationTimer.start();
                        pigletAnimationVideoShowTimer.stop();

                        if (pigletAnimationVideoPlayerLoader.unloadPlayer) {
                            // Unload VideoPlayer on Symbian because of crash while
                            // navigating between pages with loaded player, but not
                            // on Meego - to avoid problems with sound on other pages
                            if (mainWindow.targetPlatform === "symbian") {
                                pigletAnimationVideoPlayerLoader.source = "";

                                pigletAnimationVideoPlayerLoader.playerLoaded = false;
                            }

                            pigletAnimationVideoPlayerLoader.unloadPlayer = false;
                        }
                        if (pigletAnimationVideoPlayerLoader.replacePage) {
                            pageReplaceTimer.start();

                            pigletAnimationVideoPlayerLoader.replacePage = false;
                        }
                    }
                }
            }
        }

        Column {
            id:                     buttonsColumn
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            z:                      10
            spacing:                96

            Column {
                id:      gameButtonsColumn
                spacing: 16

                GameButton {
                    id:                pigletFeedGameButton
                    width:             64
                    height:            64
                    sourceNormal:      "qrc:/resources/images/piglet/game_piglet_feed.png"
                    sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_feed_highlighted.png"

                    onStartGame: {
                        waitRectangle.visible = true;

                        pigletPage.pigletAnimationEnabled = false;
                        pigletPage.nextPage               = pigletFeedPage;

                        pigletAnimationVideoPlayerLoader.unloadVideoPlayerAndReplacePage();
                    }
                }

                GameButton {
                    id:                pigletWashGameButton
                    width:             64
                    height:            64
                    sourceNormal:      "qrc:/resources/images/piglet/game_piglet_wash.png"
                    sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_wash_highlighted.png"

                    onStartGame: {
                        waitRectangle.visible = true;

                        pigletPage.pigletAnimationEnabled = false;
                        pigletPage.nextPage               = pigletWashPage;

                        pigletAnimationVideoPlayerLoader.unloadVideoPlayerAndReplacePage();
                    }
                }

                GameButton {
                    id:                pigletPuzzleGameButton
                    width:             64
                    height:            64
                    sourceNormal:      "qrc:/resources/images/piglet/game_piglet_puzzle.png"
                    sourceHighlighted: "qrc:/resources/images/piglet/game_piglet_puzzle_highlighted.png"

                    onStartGame: {
                        waitRectangle.visible = true;

                        pigletPage.pigletAnimationEnabled = false;
                        pigletPage.nextPage               = pigletPuzzlePage;

                        pigletAnimationVideoPlayerLoader.unloadVideoPlayerAndReplacePage();
                    }
                }
            }

            Column {
                id:      actionButtonsColumn
                spacing: 16

                ActionButton {
                    id:             cakeActionButton
                    width:          64
                    height:         64
                    actionActive:   pigletPage.pigletAnimationVideoActive
                    sourceNormal:   "qrc:/resources/images/piglet/action_cake.png"
                    sourceDisabled: "qrc:/resources/images/piglet/action_cake_disabled.png"

                    onActionActiveChanged: {
                        if (actionActive && pigletPage.isAnimationActive("piglet_eats_cake.mp4")) {
                            actionValid = true;
                        }
                    }

                    onStartAction: {
                        pigletPage.nextAnimationVideoSource = "piglet_eats_cake.mp4";

                        pigletPage.restartAnimation();
                    }
                }

                ActionButton {
                    id:             candyActionButton
                    width:          64
                    height:         64
                    actionActive:   pigletPage.pigletAnimationVideoActive
                    sourceNormal:   "qrc:/resources/images/piglet/action_candy.png"
                    sourceDisabled: "qrc:/resources/images/piglet/action_candy_disabled.png"

                    onActionActiveChanged: {
                        if (actionActive && pigletPage.isAnimationActive("piglet_eats_candy.mp4")) {
                            actionValid = true;
                        }
                    }

                    onStartAction: {
                        pigletPage.nextAnimationVideoSource = "piglet_eats_candy.mp4";

                        pigletPage.restartAnimation();
                    }
                }
            }
        }

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

                    pigletPage.pigletAnimationEnabled = false;
                    pigletPage.nextPage               = helpPage;

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
    }

    Rectangle {
        id:           waitRectangle
        anchors.fill: parent
        z:            50
        color:        "black"
        opacity:      0.75
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

    Accelerometer {
        id: accelerometer

        property real lastReadingX: 0.0
        property real lastReadingY: 0.0
        property real lastReadingZ: 0.0

        onReadingChanged: {
            if (lastReadingX !== 0.0 || lastReadingY !== 0.0 || lastReadingZ !== 0.0) {
                if (Math.abs(reading.x - lastReadingX) > pigletPage.accelShakeThreshold ||
                    Math.abs(reading.y - lastReadingY) > pigletPage.accelShakeThreshold ||
                    Math.abs(reading.z - lastReadingZ) > pigletPage.accelShakeThreshold) {
                    if (!pigletPage.isAnimationActive("piglet_falls.mp4")) {
                        pigletPage.nextAnimationVideoSource = "piglet_falls.mp4";

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
            if (pigletPage.pigletAnimationEnabled) {
                pigletPage.performAnimation();
            }
        }
    }

    Timer {
        id:       pigletAnimationVideoShowTimer
        interval: 250

        onTriggered: {
            if (pigletPage.pigletAnimationEnabled) {
                pigletAnimationVideoPlayerLoader.z = pigletIdleImage.z + 1;
            }
        }
    }

    Timer {
        id:       pigletRandomAnimationTimer
        interval: 10000 + 5000 * Math.random()
        repeat:   true

        onTriggered: {
            if (pigletPage.nextAnimationVideoSource === "") {
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
                    pigletPage.nextAnimationVideoSource = "piglet_look_around.mp4";
                } else {
                    pigletPage.nextAnimationVideoSource = "piglet_in_sorrow.mp4";
                }
            }

            interval = 10000 + 5000 * Math.random();

            restart();
        }
    }

    Timer {
        id:       pageReplaceTimer
        interval: 100

        onTriggered: {
            waitRectangle.visible = false;

            mainPageStack.replace(pigletPage.nextPage);
        }
    }

    Connections {
        target: CSApplication

        onAppInBackground: {
            pigletPage.appInForeground = false;
        }

        onAppInForeground: {
            pigletPage.appInForeground = true;
        }
    }
}
