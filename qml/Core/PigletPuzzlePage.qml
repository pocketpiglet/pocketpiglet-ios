import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12

import "../Util.js"          as UtilScript
import "PigletPuzzlePage.js" as PigletPuzzlePageScript

Item {
    id: pigletPuzzlePage

    readonly property bool appInForeground: Qt.application.state === Qt.ApplicationActive
    readonly property bool pageActive:      StackView.status === StackView.Active

    readonly property real screenScale:     Math.min(backgroundImage.width  / backgroundImage.sourceSize.width,
                                                     backgroundImage.height / backgroundImage.sourceSize.height);

    property bool pageInitialized:          false
    property bool puzzleSolved:             false

    property int screenRotation:            90

    property string puzzleType:             "watering_flowers"
    property string puzzleComplexity:       ""

    signal gameFinished(string game)

    StackView.onRemoved: {
        destroy();
    }

    function handleScreenOrientationUpdate(screen_orientation) {
        if (pigletPuzzlePage) {
            if (screen_orientation === Qt.LandscapeOrientation) {
                screenRotation = 90;
            } else if (screen_orientation === Qt.InvertedLandscapeOrientation) {
                screenRotation = 270;
            }
        }
    }

    function startGame() {
        puzzleSolved = false;

        PigletPuzzlePageScript.createMap(pigletPuzzlePage.puzzleComplexity);

        audio.playAudio("qrc:/resources/sound/piglet_puzzle/game_started.wav");
    }

    function elementClicked(element) {
        if (PigletPuzzlePageScript.moveElement(puzzleComplexity, element)) {
            puzzleSolved = true;

            originalImage.blink();

            audio.playAudio("qrc:/resources/sound/piglet_puzzle/game_completed.wav");
        }
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletPuzzlePage.appInForeground || !pigletPuzzlePage.pageActive

        onError: {
            console.error(errorString);
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
        rotation:         pigletPuzzlePage.screenRotation

        Image {
            id:           backgroundImage
            anchors.fill: parent
            source:       "qrc:/resources/images/background.png"
            fillMode:     Image.PreserveAspectCrop
        }

        Image {
            id:           originalSampleImageThumbnail
            anchors.top:  parent.top
            anchors.left: parent.left
            z:            1
            width:        120 * pigletPuzzlePage.screenScale
            height:       120 * pigletPuzzlePage.screenScale
            source:       "qrc:/resources/images/piglet_puzzle/%1/original_thumbnail.png".arg(pigletPuzzlePage.puzzleType)
            fillMode:     Image.PreserveAspectFit

            MouseArea {
                id:           originalSampleImageThumbnailMouseArea
                anchors.fill: parent

                onClicked: {
                    originalSampleImageRectangle.visible = true;
                }
            }
        }

        Rectangle {
            id:               gameFieldRectangle
            anchors.centerIn: parent
            z:                2
            width:            360 * pigletPuzzlePage.screenScale
            height:           360 * pigletPuzzlePage.screenScale
            color:            "transparent"

            property list<Image> puzzleElementsMedium: [
                Image {
                    parent:   gameFieldRectangle
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   pigletPuzzlePage.puzzleSolved ? "qrc:/resources/images/piglet_puzzle/%1/medium/9.png".arg(pigletPuzzlePage.puzzleType)
                                                            : "qrc:/resources/images/piglet_puzzle/%1/medium/0.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        120 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/1.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(1);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        240 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/2.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(2);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        120 * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/3.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(3);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        120 * pigletPuzzlePage.screenScale
                    y:        120 * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/4.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(4);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        240 * pigletPuzzlePage.screenScale
                    y:        120 * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/5.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(5);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        240 * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/6.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(6);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        120 * pigletPuzzlePage.screenScale
                    y:        240 * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/7.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(7);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        240 * pigletPuzzlePage.screenScale
                    y:        240 * pigletPuzzlePage.screenScale
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/medium/8.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(8);
                        }
                    }
                }
            ]

            property list<Image> puzzleElementsHard: [
                Image {
                    parent:   gameFieldRectangle
                    x:        0  * pigletPuzzlePage.screenScale
                    y:        0  * pigletPuzzlePage.screenScale
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    source:   pigletPuzzlePage.puzzleSolved ? "qrc:/resources/images/piglet_puzzle/%1/hard/16.png".arg(pigletPuzzlePage.puzzleType)
                                                            : "qrc:/resources/images/piglet_puzzle/%1/hard/0.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        90 * pigletPuzzlePage.screenScale
                    y:        0  * pigletPuzzlePage.screenScale
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/1.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(1);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/2.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(2);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/3.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(3);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        0  * pigletPuzzlePage.screenScale
                    y:        90 * pigletPuzzlePage.screenScale
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/4.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(4);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        90 * pigletPuzzlePage.screenScale
                    y:        90 * pigletPuzzlePage.screenScale
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/5.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(5);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        90  * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/6.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(6);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        90  * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/7.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(7);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/8.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(8);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        90  * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/9.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(9);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/10.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(10);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/11.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(11);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/12.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(12);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        90  * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/13.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(13);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/14.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(14);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    source:   "qrc:/resources/images/piglet_puzzle/%1/hard/15.png".arg(pigletPuzzlePage.puzzleType)
                    fillMode: Image.PreserveAspectFit
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    enabled:  !pigletPuzzlePage.puzzleSolved

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.elementClicked(15);
                        }
                    }
                }
            ]

            Image {
                id:           originalImage
                anchors.fill: parent
                z:            1
                source:       "qrc:/resources/images/piglet_puzzle/%1/original.png".arg(pigletPuzzlePage.puzzleType)
                fillMode:     Image.PreserveAspectFit
                opacity:      0.0
                visible:      false

                function blink() {
                    visible = true;

                    originalImageBlinkAnimation.start();
                }

                MultiPointTouchArea {
                    id:           originalImageMultiPointTouchArea
                    anchors.fill: parent
                }

                SequentialAnimation {
                    id: originalImageBlinkAnimation

                    NumberAnimation {
                        target:      originalImage
                        property:    "opacity"
                        from:        0.0
                        to:          1.0
                        duration:    500
                        easing.type: Easing.InExpo
                    }

                    NumberAnimation {
                        target:      originalImage
                        property:    "opacity"
                        from:        1.0
                        to:          0.0
                        duration:    500
                        easing.type: Easing.OutExpo
                    }

                    ScriptAction {
                        script: {
                            originalImage.visible = false;
                        }
                    }
                }
            }
        }

        Image {
            id:                  backButtonImage
            anchors.bottom:      parent.bottom
            anchors.right:       parent.right
            anchors.rightMargin: UtilScript.dp(30)
            z:                   5
            width:               UtilScript.dp(64)
            height:              UtilScript.dp(64)
            source:              "qrc:/resources/images/back.png"
            fillMode:            Image.PreserveAspectFit

            MouseArea {
                id:           backButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    pigletPuzzlePage.gameFinished("piglet_puzzle");

                    mainStackView.pop();
                }
            }
        }
    }

    Rectangle {
        id:               originalSampleImageRectangle
        anchors.centerIn: parent
        z:                1
        width:            parent.height
        height:           parent.width
        color:            "transparent"
        rotation:         pigletPuzzlePage.screenRotation
        visible:          false

        Image {
            id:               originalSampleImage
            anchors.centerIn: parent
            width:            360 * pigletPuzzlePage.screenScale
            height:           360 * pigletPuzzlePage.screenScale
            source:           "qrc:/resources/images/piglet_puzzle/%1/original.png".arg(pigletPuzzlePage.puzzleType)
            fillMode:         Image.PreserveAspectFit
        }

        MouseArea {
            id:           originalSampleImageRectangleMouseArea
            anchors.fill: parent

            onClicked: {
                originalSampleImageRectangle.visible = false;
            }
        }
    }

    Rectangle {
        id:               complexitySelectionRectangle
        anchors.centerIn: parent
        z:                2
        width:            parent.height
        height:           parent.width
        color:            "black"
        rotation:         pigletPuzzlePage.screenRotation

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
                    width:            UtilScript.dp(434)
                    height:           UtilScript.dp(160)
                    source:           "qrc:/resources/images/piglet_puzzle/complexity_selection_background.png"
                    fillMode:         Image.PreserveAspectFit

                    Row {
                        id:               complexitySelectionRow
                        anchors.centerIn: parent
                        spacing:          UtilScript.dp(10)

                        Image {
                            id:       mediumComplexityButtonImage
                            width:    UtilScript.dp(120)
                            height:   UtilScript.dp(120)
                            source:   "qrc:/resources/images/piglet_puzzle/complexity_medium.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           mediumComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleComplexity    = "medium";
                                    complexitySelectionRectangle.visible = false;
                                    puzzleSelectionRectangle.visible     = true;
                                }
                            }
                        }

                        Image {
                            id:       hardComplexityButtonImage
                            width:    UtilScript.dp(120)
                            height:   UtilScript.dp(120)
                            source:   "qrc:/resources/images/piglet_puzzle/complexity_hard.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           hardComplexityButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleComplexity    = "hard";
                                    complexitySelectionRectangle.visible = false;
                                    puzzleSelectionRectangle.visible     = true;
                                }
                            }
                        }
                    }
                }

                Image {
                    id:                  complexitySelectionBackButtonImage
                    anchors.bottom:      parent.bottom
                    anchors.right:       parent.right
                    anchors.rightMargin: UtilScript.dp(30)
                    z:                   1
                    width:               UtilScript.dp(64)
                    height:              UtilScript.dp(64)
                    source:              "qrc:/resources/images/back.png"
                    fillMode:            Image.PreserveAspectFit

                    MouseArea {
                        id:           complexitySelectionBackButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.gameFinished("piglet_puzzle");

                            mainStackView.pop();
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id:               puzzleSelectionRectangle
        anchors.centerIn: parent
        z:                2
        width:            parent.height
        height:           parent.width
        color:            "black"
        rotation:         pigletPuzzlePage.screenRotation
        visible:          false

        MultiPointTouchArea {
            id:           puzzleSelectionRectangleMultiPointTouchArea
            anchors.fill: parent

            Image {
                id:           puzzleSelectionBackgroundImage
                anchors.fill: parent
                source:       "qrc:/resources/images/background.png"
                fillMode:     Image.PreserveAspectCrop

                Image {
                    id:               puzzleSelectionRowBackgroundImage
                    anchors.centerIn: parent
                    width:            UtilScript.dp(434)
                    height:           UtilScript.dp(160)
                    source:           "qrc:/resources/images/piglet_puzzle/puzzle_selection_background.png"
                    fillMode:         Image.PreserveAspectFit

                    Row {
                        id:               puzzleSelectionRow
                        anchors.centerIn: parent
                        spacing:          UtilScript.dp(10)

                        Image {
                            id:       heartBalloonPuzzleButtonImage
                            width:    UtilScript.dp(120)
                            height:   UtilScript.dp(120)
                            source:   "qrc:/resources/images/piglet_puzzle/heart_balloon/original_thumbnail.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           heartBalloonImageButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleType      = "heart_balloon";
                                    puzzleSelectionRectangle.visible = false;

                                    pigletPuzzlePage.startGame();
                                }
                            }
                        }

                        Image {
                            id:       pigletOnPottyPuzzleButtonImage
                            width:    UtilScript.dp(120)
                            height:   UtilScript.dp(120)
                            source:   "qrc:/resources/images/piglet_puzzle/piglet_on_potty/original_thumbnail.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           pigletOnPottyPuzzleButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleType      = "piglet_on_potty";
                                    puzzleSelectionRectangle.visible = false;

                                    pigletPuzzlePage.startGame();
                                }
                            }
                        }

                        Image {
                            id:       wateringFlowersPuzzleButtonImage
                            width:    UtilScript.dp(120)
                            height:   UtilScript.dp(120)
                            source:   "qrc:/resources/images/piglet_puzzle/watering_flowers/original_thumbnail.png"
                            fillMode: Image.PreserveAspectFit

                            MouseArea {
                                id:           wateringFlowersPuzzleButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleType      = "watering_flowers";
                                    puzzleSelectionRectangle.visible = false;

                                    pigletPuzzlePage.startGame();
                                }
                            }
                        }
                    }
                }

                Image {
                    id:                  puzzleSelectionBackButtonImage
                    anchors.bottom:      parent.bottom
                    anchors.right:       parent.right
                    anchors.rightMargin: UtilScript.dp(30)
                    z:                   1
                    width:               UtilScript.dp(64)
                    height:              UtilScript.dp(64)
                    source:              "qrc:/resources/images/back.png"
                    fillMode:            Image.PreserveAspectFit

                    MouseArea {
                        id:           puzzleSelectionBackButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            pigletPuzzlePage.gameFinished("piglet_puzzle");

                            mainStackView.pop();
                        }
                    }
                }
            }
        }
    }
}
