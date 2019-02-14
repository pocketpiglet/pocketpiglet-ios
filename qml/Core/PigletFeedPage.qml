import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12

import "Dialog"
import "PigletFeed"

Item {
    id: pigletFeedPage

    property bool appInForeground:   Qt.application.active
    property bool pageActive:        StackView.status === StackView.Active
    property bool allowLevelRestart: false

    property int screenRotation:     90
    property int currentLevel:       1
    property int maximumLevel:       1
    property int maximumLevelEasy:   5
    property int maximumLevelMedium: 10
    property int maximumLevelHard:   15

    signal gameFinished(string game)

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            backgroundAnimatedImage.playing    = true;
            backgroundEatAnimatedImage.playing = true;

            if (allowLevelRestart) {
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

            if (allowLevelRestart) {
                newLevelNotificationDialog.open();
            }
        } else {
            backgroundAnimatedImage.playing    = false;
            backgroundEatAnimatedImage.playing = false;

            refrigerator.cancelOrder();
        }
    }

    StackView.onRemoved: {
        destroy();
    }

    function screenOrientationUpdated(orientation) {
        if (typeof(pigletFeedPage) !== "undefined" && pigletFeedPage !== null) {
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
            fillMode:     Image.PreserveAspectCrop
            playing:      false
        }

        AnimatedImage {
            id:           backgroundEatAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_feed/background_eat.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      false
            visible:      false
        }

        Refrigerator {
            id:           refrigerator
            anchors.top:  parent.top
            anchors.left: parent.left
            z:            2

            onValidFoodItemSelected: {
                sandwich.addItem(item_type);
            }

            onInvalidFoodItemSelected: {
                pigletFeedPage.allowLevelRestart = false;

                gameOverQueryDialog.open();
            }
        }

        Sandwich {
            id:             sandwich
            x:              (backgroundAnimatedImage.width  - backgroundAnimatedImage.paintedWidth)  / 2 + 412 * sandwichScaleX
            y:              (backgroundAnimatedImage.height - backgroundAnimatedImage.paintedHeight) / 2 + 0   * sandwichScaleY
            z:              2
            width:          80  * sandwichScaleX
            height:         275 * sandwichScaleY
            sandwichScaleX: backgroundAnimatedImage.paintedWidth  / backgroundAnimatedImage.sourceSize.width
            sandwichScaleY: backgroundAnimatedImage.paintedHeight / backgroundAnimatedImage.sourceSize.height

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
            id:                  backButtonImage
            anchors.bottom:      parent.bottom
            anchors.right:       parent.right
            anchors.rightMargin: 30
            width:               64
            height:              64
            z:                   10
            source:              "qrc:/resources/images/back.png"

            MouseArea {
                id:           backButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    pigletFeedPage.gameFinished("piglet_feed");

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

        MouseArea {
            id:           complexitySelectionRectangleMouseArea
            anchors.fill: parent

            Image {
                id:           complexitySelectionBackgroundImage
                anchors.fill: parent
                source:       "qrc:/resources/images/background.png"
                fillMode:     Image.PreserveAspectCrop

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
                    id:                  complexitySelectionBackButtonImage
                    anchors.bottom:      parent.bottom
                    anchors.right:       parent.right
                    anchors.rightMargin: 30
                    width:               64
                    height:              64
                    z:                   21
                    source:              "qrc:/resources/images/back.png"

                    MouseArea {
                        id:           complexitySelectionBackButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            pigletFeedPage.gameFinished("piglet_feed");

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
        text:     qsTr("Level %1 of %2. Get ready to remember a sandwich recipe...").arg(pigletFeedPage.currentLevel).arg(pigletFeedPage.maximumLevel)

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
        text:     qsTr("Congratulations, you have just won the game! Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/game_complete.wav");
        }

        onYes: {
            complexitySelectionRectangle.visible = true;
        }

        onNo: {
            pigletFeedPage.gameFinished("piglet_feed");

            mainStackView.pop();
        }
    }

    QueryDialog {
        id:       gameOverQueryDialog
        rotation: pigletFeedPage.screenRotation
        z:        30
        text:     qsTr("Game over. Do you want to play again?")

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/game_over.wav");
        }

        onYes: {
            complexitySelectionRectangle.visible = true;
        }

        onNo: {
            pigletFeedPage.gameFinished("piglet_feed");

            mainStackView.pop();
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
        interval: 3000

        onTriggered: {
            newLevelNotificationDialog.close();
        }
    }
}
