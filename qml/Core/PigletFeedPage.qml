import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12

import "Dialog"
import "PigletFeed"

import "../Util.js" as UtilScript

Item {
    id: pigletFeedPage

    readonly property bool appInForeground:   Qt.application.state === Qt.ApplicationActive
    readonly property bool pageActive:        StackView.status === StackView.Active

    readonly property int maximumLevelEasy:   5
    readonly property int maximumLevelMedium: 10
    readonly property int maximumLevelHard:   15

    property bool allowLevelRestart:          false

    property int screenRotation:              90
    property int currentLevel:                1
    property int maximumLevel:                1

    signal gameFinished(string game)

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            if (allowLevelRestart) {
                newLevelNotificationDialog.open();
            }
        } else {
            refrigerator.cancelOrder();
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            if (allowLevelRestart) {
                newLevelNotificationDialog.open();
            }
        } else {
            refrigerator.cancelOrder();
        }
    }

    StackView.onRemoved: {
        destroy();
    }

    function handleScreenOrientationUpdate(screen_orientation) {
        if (pigletFeedPage) {
            if (screen_orientation === Qt.LandscapeOrientation) {
                screenRotation = 90;
            } else if (screen_orientation === Qt.InvertedLandscapeOrientation) {
                screenRotation = 270;
            }
        }
    }

    function startGame() {
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
        color:            "black"
        rotation:         pigletFeedPage.screenRotation

        AnimatedImage {
            id:           backgroundAnimatedImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_feed/background.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      pigletFeedPage.appInForeground && pigletFeedPage.pageActive
        }

        AnimatedImage {
            id:           backgroundEatingAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_feed/background_eating.gif"
            fillMode:     Image.PreserveAspectCrop
            playing:      pigletFeedPage.appInForeground && pigletFeedPage.pageActive
            visible:      false
        }

        Refrigerator {
            id:           refrigerator
            anchors.top:  parent.top
            anchors.left: parent.left
            z:            2

            onValidFoodItemSelected: {
                sandwich.addItem(itemType);
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
                audio.playAudio("qrc:/resources/sound/piglet_feed/sandwich_eating.wav");

                backgroundAnimatedImage.visible       = false;
                backgroundEatingAnimatedImage.visible = true;

                sandwich.eatSandwich();
            }

            onAllItemsEaten: {
                backgroundAnimatedImage.visible       = true;
                backgroundEatingAnimatedImage.visible = false;

                pigletFeedPage.allowLevelRestart = false;

                if (currentLevel < maximumLevel) {
                    currentLevel = currentLevel + 1;

                    newLevelNotificationDialog.open();
                } else {
                    gameCompletedQueryDialog.open();
                }
            }
        }

        Image {
            id:                  backButtonImage
            anchors.bottom:      parent.bottom
            anchors.right:       parent.right
            anchors.rightMargin: UtilScript.pt(30)
            z:                   5
            width:               UtilScript.pt(64)
            height:              UtilScript.pt(64)
            source:              "qrc:/resources/images/back.png"
            fillMode:            Image.PreserveAspectFit

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
        z:                1
        width:            parent.height
        height:           parent.width
        color:            "black"
        rotation:         pigletFeedPage.screenRotation

        MultiPointTouchArea {
            id:           complexitySelectionRectangleMultiPointTouchArea
            anchors.fill: parent

            Image {
                id:           complexitySelectionBackgroundImage
                anchors.fill: parent
                source:       "qrc:/resources/images/background.png"
                fillMode:     Image.PreserveAspectCrop

                Image {
                    id:               complexitySelectionRowBackgroundImage
                    anchors.centerIn: parent
                    width:            UtilScript.pt(434)
                    height:           UtilScript.pt(160)
                    source:           "qrc:/resources/images/piglet_feed/complexity_selection_background.png"
                    fillMode:         Image.PreserveAspectFit

                    Row {
                        id:               complexitySelectionRow
                        anchors.centerIn: parent
                        spacing:          UtilScript.pt(10)

                        Image {
                            id:       easyComplexityButtonImage
                            width:    UtilScript.pt(120)
                            height:   UtilScript.pt(120)
                            source:   "qrc:/resources/images/piglet_feed/complexity_easy.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           easyComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletFeedPage.maximumLevel          = pigletFeedPage.maximumLevelEasy;
                                    refrigerator.refrigeratorType        = "easy";
                                    complexitySelectionRectangle.visible = false;

                                    pigletFeedPage.startGame();

                                    newLevelNotificationDialog.open();
                                }
                            }
                        }

                        Image {
                            id:       mediumComplexityButtonImage
                            width:    UtilScript.pt(120)
                            height:   UtilScript.pt(120)
                            source:   "qrc:/resources/images/piglet_feed/complexity_medium.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           mediumComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletFeedPage.maximumLevel          = pigletFeedPage.maximumLevelMedium;
                                    refrigerator.refrigeratorType        = "medium";
                                    complexitySelectionRectangle.visible = false;

                                    pigletFeedPage.startGame();

                                    newLevelNotificationDialog.open();
                                }
                            }
                        }

                        Image {
                            id:       hardComplexityButtonImage
                            width:    UtilScript.pt(120)
                            height:   UtilScript.pt(120)
                            source:   "qrc:/resources/images/piglet_feed/complexity_hard.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           hardComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletFeedPage.maximumLevel          = pigletFeedPage.maximumLevelHard;
                                    refrigerator.refrigeratorType        = "hard";
                                    complexitySelectionRectangle.visible = false;

                                    pigletFeedPage.startGame();

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
                    anchors.rightMargin: UtilScript.pt(30)
                    z:                   1
                    width:               UtilScript.pt(64)
                    height:              UtilScript.pt(64)
                    source:              "qrc:/resources/images/back.png"
                    fillMode:            Image.PreserveAspectFit

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
        z:        2
        text:     qsTr("Level %1 of %2. Get ready to remember a sandwich recipe...").arg(pigletFeedPage.currentLevel).arg(pigletFeedPage.maximumLevel)
        rotation: pigletFeedPage.screenRotation

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/new_level.wav");

            newLevelStartTimer.start();
        }

        onClosed: {
            newLevelStartTimer.stop();

            pigletFeedPage.allowLevelRestart = true;

            sandwich.newSandwich(currentLevel + 2);
            refrigerator.startOrder(currentLevel + 2);
        }
    }

    QueryDialog {
        id:       gameCompletedQueryDialog
        z:        2
        text:     qsTr("Congratulations, you have just won the game! Do you want to play again?")
        rotation: pigletFeedPage.screenRotation

        onOpened: {
            audio.playAudio("qrc:/resources/sound/piglet_feed/game_completed.wav");
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
        z:        2
        text:     qsTr("Game over. Do you want to play again?")
        rotation: pigletFeedPage.screenRotation

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
        id:       newLevelStartTimer
        interval: 3000

        onTriggered: {
            newLevelNotificationDialog.close();
        }
    }
}
