import QtQuick 1.1
import QtMultimediaKit 1.1
import com.nokia.meego 1.0

import "PigletFeed"

Page {
    id:              pigletFeedPage
    anchors.fill:    parent
    orientationLock: PageOrientation.LockLandscape

    property bool appInForeground:   Qt.application.active
    property bool allowLevelRestart: false
    property bool audioActive:       false

    property int currentLevel:       1
    property int maximumLevel:       1
    property int maximumLevelEasy:   5
    property int maximumLevelMedium: 10
    property int maximumLevelHard:   15

    property real screenDeltaX:      (backgroundAnimatedImage.width - backgroundAnimatedImage.paintedWidth) / 2
    property real screenDeltaY:      (backgroundAnimatedImage.height - backgroundAnimatedImage.paintedHeight) / 2
    property real screenFactorX:     backgroundAnimatedImage.paintedWidth / backgroundAnimatedImage.sourceSize.width
    property real screenFactorY:     backgroundAnimatedImage.paintedHeight / backgroundAnimatedImage.sourceSize.height

    onStatusChanged: {
        if (status === PageStatus.Active) {
            backgroundAnimatedImage.playing    = true;
            backgroundEatAnimatedImage.playing = true;

            waitRectangle.visible = true;

            gameBeginTimer.start();
        } else {
            backgroundAnimatedImage.playing    = false;
            backgroundEatAnimatedImage.playing = false;

            if (audioActive) {
                audio.stop();
            }
        }
    }

    onAppInForegroundChanged: {
        if (appInForeground) {
            pauseRectangle.visible = false;

            if (allowLevelRestart) {
                newLevelQueryDialog.open();
            }
        } else {
            pauseRectangle.visible = true;

            refrigerator.cancelOrder();
        }
    }

    function beginGame() {
        currentLevel = 1;

        refrigerator.prepareOrder(maximumLevel + 2);
    }

    function playAudio(src) {
        if (audioActive) {
            audio.stop();
        }

        audio.source   = src;
        audio.position = 0;

        audio.play();
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  pigletFeedPage.appInForeground ? false : true

        onStarted: {
            pigletFeedPage.audioActive = true;
        }

        onStopped: {
            pigletFeedPage.audioActive = false;
        }
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        AnimatedImage {
            id:           backgroundAnimatedImage
            anchors.fill: parent
            source:       "qrc:/resources/images/piglet_feed/background.gif"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
            playing:      false
        }

        AnimatedImage {
            id:           backgroundEatAnimatedImage
            anchors.fill: parent
            z:            1
            source:       "qrc:/resources/images/piglet_feed/background_eat.gif"
            fillMode:     Image.PreserveAspectFit
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
                sandwich.addItem(itemType);

                if (lastItem) {
                    pigletFeedPage.allowLevelRestart = false;
                }
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
                pigletFeedPage.playAudio("../../sound/piglet_feed/sandwich_eat.wav");

                backgroundAnimatedImage.visible    = false;
                backgroundEatAnimatedImage.visible = true;

                eatSandwichTimer.start();
            }

            onAllItemsEaten: {
                backgroundAnimatedImage.visible    = true;
                backgroundEatAnimatedImage.visible = false;

                if (currentLevel < maximumLevel) {
                    currentLevel = currentLevel + 1;

                    if (pigletFeedPage.appInForeground) {
                        newLevelQueryDialog.open();
                    } else {
                        pigletFeedPage.allowLevelRestart = true;
                    }
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
                    pigletFeedPage.allowLevelRestart = false;

                    refrigerator.cancelOrder();

                    pigletPage.gameFinished("piglet_feed");

                    mainPageStack.replace(pigletPage);
                }
            }
        }
    }

    Rectangle {
        id:           waitRectangle
        anchors.fill: parent
        z:            50
        color:        "black"
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

    Rectangle {
        id:           complexitySelectionRectangle
        anchors.fill: parent
        z:            60
        color:        "black"
        visible:      false

        MouseArea {
            id:           complexitySelectionRectangleMouseArea
            anchors.fill: parent

            Image {
                id:           complexitySelectionBackgroundImage
                anchors.fill: parent
                source:       "qrc:/resources/images/background.png"
                fillMode:     Image.PreserveAspectFit
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

                                    newLevelQueryDialog.open();
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

                                    newLevelQueryDialog.open();
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

                                    newLevelQueryDialog.open();
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
                    z:              61
                    source:         "qrc:/resources/images/help.png"

                    MouseArea {
                        id:           complexitySelectionHelpButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            helpQueryDialog.open();
                        }
                    }
                }

                Image {
                    id:             complexitySelectionExitButtonImage
                    anchors.bottom: parent.bottom
                    anchors.right:  parent.right
                    width:          48
                    height:         48
                    z:              61
                    source:         "qrc:/resources/images/exit.png"

                    MouseArea {
                        id:           complexitySelectionExitButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            pigletPage.gameFinished("piglet_feed");

                            mainPageStack.replace(pigletPage);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id:           pauseRectangle
        anchors.fill: parent
        z:            70
        color:        "black"
        visible:      false

        MouseArea {
            id:           pauseRectangleMouseArea
            anchors.fill: parent

            Image {
                id:               pauseRectangleImage
                anchors.centerIn: parent
                source:           "qrc:/resources/images/game_pause.png"
            }
        }
    }

    QueryDialog {
        id:               helpQueryDialog
        titleText:        "Feed the Piglet"
        icon:             "qrc:/resources/images/dialog_info.png"
        message:          "Your piglet is hungry! Remember sandwich recipe and add the ingredients in the right order to make the perfect sandwich for your favorite pet."
        acceptButtonText: "OK"
    }

    QueryDialog {
        id:        newLevelQueryDialog
        titleText: "Feed the Piglet"
        icon:      "qrc:/resources/images/dialog_info.png"
        message:   "Level " + pigletFeedPage.currentLevel + " of " + pigletFeedPage.maximumLevel + ". Get ready to remember a sandwich recipe..."

        onStatusChanged: {
            if (status === DialogStatus.Open) {
                pigletFeedPage.playAudio("../../sound/piglet_feed/new_level.wav");

                newLevelBeginTimer.start();
            }
        }

        onRejected: {
            newLevelBeginTimer.stop();

            pigletFeedPage.allowLevelRestart = true;

            sandwich.newSandwich(currentLevel + 2);
            refrigerator.beginOrder(currentLevel + 2);
        }
    }

    QueryDialog {
        id:               gameCompleteQueryDialog
        titleText:        "Feed the Piglet"
        icon:             "qrc:/resources/images/dialog_question.png"
        message:          "Congratulations, you have just won the game! Do you want to play again?"
        acceptButtonText: "Play"
        rejectButtonText: "Quit"

        onStatusChanged: {
            if (status === DialogStatus.Open) {
                pigletFeedPage.playAudio("../../sound/piglet_feed/game_complete.wav");
            }
        }

        onAccepted: {
            complexitySelectionRectangle.visible = true;
        }

        onRejected: {
            pigletPage.gameFinished("piglet_feed");

            mainPageStack.replace(pigletPage);
        }
    }

    QueryDialog {
        id:               gameOverQueryDialog
        titleText:        "Feed the Piglet"
        icon:             "qrc:/resources/images/dialog_question.png"
        message:          "Game over. Do you want to play again?"
        acceptButtonText: "Play"
        rejectButtonText: "Quit"

        onStatusChanged: {
            if (status === DialogStatus.Open) {
                pigletFeedPage.playAudio("../../sound/piglet_feed/game_over.wav");
            }
        }

        onAccepted: {
            complexitySelectionRectangle.visible = true;
        }

        onRejected: {
            pigletPage.gameFinished("piglet_feed");

            mainPageStack.replace(pigletPage);
        }
    }

    Timer {
        id:       gameBeginTimer
        interval: 100

        onTriggered: {
            waitRectangle.visible                = false;
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
            newLevelQueryDialog.reject();
        }
    }
}
