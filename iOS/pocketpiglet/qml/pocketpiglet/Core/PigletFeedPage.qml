import QtQuick 2.9
import QtMultimedia 5.9

import "Dialog"
import "PigletFeed"

Item {
    id: pigletFeedPage

    property bool appInForeground:   Qt.application.active
    property bool pageActive:        false
    property bool pageInitialized:   false
    property bool allowLevelRestart: false

    property int screenRotation:     90
    property int currentLevel:       1
    property int maximumLevel:       1
    property int maximumLevelEasy:   5
    property int maximumLevelMedium: 10
    property int maximumLevelHard:   15

    property real screenDeltaX:      (backgroundAnimatedImage.width - backgroundAnimatedImage.paintedWidth) / 2
    property real screenDeltaY:      (backgroundAnimatedImage.height - backgroundAnimatedImage.paintedHeight) / 2
    property real screenFactorX:     backgroundAnimatedImage.paintedWidth / backgroundAnimatedImage.sourceSize.width
    property real screenFactorY:     backgroundAnimatedImage.paintedHeight / backgroundAnimatedImage.sourceSize.height

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            backgroundAnimatedImage.playing    = true;
            backgroundEatAnimatedImage.playing = true;

            if (!pageInitialized) {
                pageInitialized = true;

                gameBeginTimer.start();
            } else if (allowLevelRestart) {
                newLevelNotificationDialog.open();
            }
        } else {
            backgroundAnimatedImage.playing    = false;
            backgroundEatAnimatedImage.playing = false;

            refrigerator.cancelOrder();
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            backgroundAnimatedImage.playing    = true;
            backgroundEatAnimatedImage.playing = true;

            if (!pageInitialized) {
                pageInitialized = true;

                gameBeginTimer.start();
            } else if (allowLevelRestart) {
                newLevelNotificationDialog.open();
            }
        } else {
            backgroundAnimatedImage.playing    = false;
            backgroundEatAnimatedImage.playing = false;

            refrigerator.cancelOrder();
        }
    }

    function screenOrientationUpdated(orientation) {
        if (typeof(pigletFeedPage) !== "undefined") {
            if (orientation === Qt.LandscapeOrientation) {
                screenRotation = 90;
            } else if (orientation === Qt.InvertedLandscapeOrientation) {
                screenRotation = 270;
            }
        }
    }

    function beginGame() {
        currentLevel = 1;

        refrigerator.prepareOrder(maximumLevel + 2);
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletFeedPage.appInForeground || !pigletFeedPage.pageActive

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
        id:               backgroundRectangle
        anchors.centerIn: parent
        width:            parent.height
        height:           parent.width
        rotation:         pigletFeedPage.screenRotation
        color:            "black"

        AnimatedImage {
            id:           backgroundAnimatedImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_feed/background.gif"
            fillMode:     Image.Stretch
            smooth:       true
            playing:      false
        }

        AnimatedImage {
            id:           backgroundEatAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_feed/background_eat.gif"
            fillMode:     Image.Stretch
            smooth:       true
            playing:      false
            visible:      false
        }

        Refrigerator {
            id: refrigerator
            x:  pigletFeedPage.screenDeltaX
            y:  pigletFeedPage.screenDeltaY
            z:  2

            onValidFoodItemSelected: {
                sandwich.addItem(item_type);
            }

            onInvalidFoodItemSelected: {
                pigletFeedPage.allowLevelRestart = false;

                gameOverQueryDialog.open();
            }
        }

        Sandwich {
            id:     sandwich
            x:      pigletFeedPage.screenDeltaX + 412 * pigletFeedPage.screenFactorX
            y:      pigletFeedPage.screenDeltaY + 0   * pigletFeedPage.screenFactorY
            z:      2
            width:  80  * pigletFeedPage.screenFactorX
            height: 275 * pigletFeedPage.screenFactorY

            onAllItemsInPlace: {
                audio.playAudio("qrc:/resources/sound/piglet_feed/sandwich_eat.wav");

                backgroundAnimatedImage.visible    = false;
                backgroundEatAnimatedImage.visible = true;

                eatSandwichTimer.start();
            }

            onAllItemsEaten: {
                backgroundAnimatedImage.visible    = true;
                backgroundEatAnimatedImage.visible = false;

                pigletFeedPage.allowLevelRestart = false;

                if (currentLevel < maximumLevel) {
                    currentLevel = currentLevel + 1;

                    newLevelNotificationDialog.open();
                } else {
                    gameCompleteQueryDialog.open();
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
                    pigletPage.gameFinished("piglet_feed");

                    mainStackView.pop();
                }
            }
        }
    }

    Rectangle {
        id:               complexitySelectionRectangle
        anchors.centerIn: parent
        width:            parent.height
        height:           parent.width
        rotation:         pigletFeedPage.screenRotation
        z:                20
        color:            "black"
        visible:          false

        MouseArea {
            id:           complexitySelectionRectangleMouseArea
            anchors.fill: parent

            Image {
                id:           complexitySelectionBackgroundImage
                anchors.fill: parent
                source:       "qrc:/resources/images/background.png"
                fillMode:     Image.Stretch
                smooth:       true

                Image {
                    id:               complexitySelectionRowBackgroundImage
                    anchors.centerIn: parent
                    width:            434
                    height:           160
                    source:           "qrc:/resources/images/piglet_feed/complexity_selection_background.png"

                    Row {
                        id:               complexitySelectionRow
                        anchors.centerIn: parent
                        spacing:          10

                        Image {
                            id:     easyComplexityButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_feed/complexity_easy.png"

                            MouseArea {
                                id:           easyComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletFeedPage.maximumLevel          = pigletFeedPage.maximumLevelEasy;
                                    refrigerator.refrigeratorType        = "easy";
                                    complexitySelectionRectangle.visible = false;

                                    pigletFeedPage.beginGame();

                                    newLevelNotificationDialog.open();
                                }
                            }
                        }

                        Image {
                            id:     mediumComplexityButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_feed/complexity_medium.png"

                            MouseArea {
                                id:           mediumComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletFeedPage.maximumLevel          = pigletFeedPage.maximumLevelMedium;
                                    refrigerator.refrigeratorType        = "medium";
                                    complexitySelectionRectangle.visible = false;

                                    pigletFeedPage.beginGame();

                                    newLevelNotificationDialog.open();
                                }
                            }
                        }

                        Image {
                            id:     hardComplexityButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_feed/complexity_hard.png"

                            MouseArea {
                                id:           hardComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletFeedPage.maximumLevel          = pigletFeedPage.maximumLevelHard;
                                    refrigerator.refrigeratorType        = "hard";
                                    complexitySelectionRectangle.visible = false;

                                    pigletFeedPage.beginGame();

                                    newLevelNotificationDialog.open();
                                }
                            }
                        }
                    }
                }

                Image {
                    id:             complexitySelectionHelpButtonImage
                    anchors.bottom: parent.bottom
                    anchors.left:   parent.left
                    width:          48
                    height:         48
                    z:              21
                    source:         "qrc:/resources/images/help.png"

                    MouseArea {
                        id:           complexitySelectionHelpButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            // helpMessageDialog.open();
                        }
                    }
                }

                Image {
                    id:             complexitySelectionExitButtonImage
                    anchors.bottom: parent.bottom
                    anchors.right:  parent.right
                    width:          48
                    height:         48
                    z:              21
                    source:         "qrc:/resources/images/exit.png"

                    MouseArea {
                        id:           complexitySelectionExitButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            pigletPage.gameFinished("piglet_feed");

                            mainStackView.pop();
                        }
                    }
                }
            }
        }
    }

    NotificationDialog {
        id:       newLevelNotificationDialog
        rotation: pigletFeedPage.screenRotation
        z:        30
        text:     "Level " + pigletFeedPage.currentLevel + " of " + pigletFeedPage.maximumLevel + ". Get ready to remember a sandwich recipe..."

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/new_level.wav");

            newLevelBeginTimer.start();
        }

        onClosed: {
            newLevelBeginTimer.stop();

            pigletFeedPage.allowLevelRestart = true;

            sandwich.newSandwich(currentLevel + 2);
            refrigerator.beginOrder(currentLevel + 2);
        }
    }

    QueryDialog {
        id:       gameCompleteQueryDialog
        rotation: pigletFeedPage.screenRotation
        z:        30
        text:     "Congratulations, you have just won the game! Do you want to play again?"

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/game_complete.wav");
        }

        onYes: {
            complexitySelectionRectangle.visible = true;
        }

        onNo: {
            pigletPage.gameFinished("piglet_feed");

            mainStackView.pop();
        }
    }

    QueryDialog {
        id:       gameOverQueryDialog
        rotation: pigletFeedPage.screenRotation
        z:        30
        text:     "Game over. Do you want to play again?"

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/game_over.wav");
        }

        onYes: {
            complexitySelectionRectangle.visible = true;
        }

        onNo: {
            pigletPage.gameFinished("piglet_feed");

            mainStackView.pop();
        }
    }

    Timer {
        id:       gameBeginTimer
        interval: 100

        onTriggered: {
            complexitySelectionRectangle.visible = true;
        }
    }

    Timer {
        id:       eatSandwichTimer
        interval: 100

        onTriggered: {
            sandwich.eatSandwich();
        }
    }

    Timer {
        id:       newLevelBeginTimer
        interval: 2000

        onTriggered: {
            newLevelNotificationDialog.close();
        }
    }
}
