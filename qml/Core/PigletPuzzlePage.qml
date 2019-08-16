import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12

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

    function screenOrientationUpdated(orientation) {
        if (pigletPuzzlePage) {
            if (orientation === Qt.LandscapeOrientation) {
                screenRotation = 90;
            } else if (orientation === Qt.InvertedLandscapeOrientation) {
                screenRotation = 270;
            }
        }
    }

    function beginGame() {
        puzzleSolved = false;

        PigletPuzzlePageScript.createMap(pigletPuzzlePage.puzzleComplexity);

        audio.playAudio("qrc:/resources/sound/piglet_puzzle/game_start.wav");
    }

    function elementClicked(element) {
        if (PigletPuzzlePageScript.moveElement(puzzleComplexity, element)) {
            puzzleSolved = true;

            originalImage.blink();

            audio.playAudio("qrc:/resources/sound/piglet_puzzle/game_complete.wav");
        }
    }

    Audio {
        id:     audio
        volume: 1.0
        muted:  !pigletPuzzlePage.appInForeground || !pigletPuzzlePage.pageActive

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
        rotation:         pigletPuzzlePage.screenRotation
        color:            "black"

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
            width:        120 * pigletPuzzlePage.screenScale
            height:       120 * pigletPuzzlePage.screenScale
            z:            1
            source:       "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/original_thumbnail.png"
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
            width:            360 * pigletPuzzlePage.screenScale
            height:           360 * pigletPuzzlePage.screenScale
            z:                2
            color:            "transparent"

            property list<Image> puzzleElementsMedium: [
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   pigletPuzzlePage.puzzleSolved ? "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/9.png"
                                                            : "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/0.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        120 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/1.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(1);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        240 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/2.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(2);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        120 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/3.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(3);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        120 * pigletPuzzlePage.screenScale
                    y:        120 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/4.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(4);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        240 * pigletPuzzlePage.screenScale
                    y:        120 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/5.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(5);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        240 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/6.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(6);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        120 * pigletPuzzlePage.screenScale
                    y:        240 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/7.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(7);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenScale
                    height:   120 * pigletPuzzlePage.screenScale
                    x:        240 * pigletPuzzlePage.screenScale
                    y:        240 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/8.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(8);
                        }
                    }
                }
            ]

            property list<Image> puzzleElementsHard: [
                Image {
                    parent:   gameFieldRectangle
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    x:        0  * pigletPuzzlePage.screenScale
                    y:        0  * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   pigletPuzzlePage.puzzleSolved ? "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/16.png"
                                                            : "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/0.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    x:        90 * pigletPuzzlePage.screenScale
                    y:        0  * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/1.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(1);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/2.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(2);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        0   * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/3.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(3);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    x:        0  * pigletPuzzlePage.screenScale
                    y:        90 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/4.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(4);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90 * pigletPuzzlePage.screenScale
                    height:   90 * pigletPuzzlePage.screenScale
                    x:        90 * pigletPuzzlePage.screenScale
                    y:        90 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/5.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(5);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        90  * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/6.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(6);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        90  * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/7.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(7);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/8.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(8);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        90  * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/9.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(9);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/10.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(10);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        180 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/11.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(11);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        0   * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/12.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(12);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        90  * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/13.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(13);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        180 * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/14.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

                        onClicked: {
                            pigletPuzzlePage.elementClicked(14);
                        }
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90  * pigletPuzzlePage.screenScale
                    height:   90  * pigletPuzzlePage.screenScale
                    x:        270 * pigletPuzzlePage.screenScale
                    y:        270 * pigletPuzzlePage.screenScale
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/15.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true

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
                visible:      false
                source:       "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/original.png"
                fillMode:     Image.PreserveAspectFit
                opacity:      0.0

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

                    PropertyAnimation {
                        target:      originalImage
                        property:    "opacity"
                        from:        0.0
                        to:          1.0
                        duration:    500
                        easing.type: Easing.InExpo
                    }

                    PropertyAnimation {
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
            anchors.rightMargin: 30
            width:               64
            height:              64
            z:                   5
            source:              "qrc:/resources/images/back.png"

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
        width:            parent.height
        height:           parent.width
        rotation:         pigletPuzzlePage.screenRotation
        z:                1
        color:            "transparent"
        visible:          false

        Image {
            id:               originalSampleImage
            anchors.centerIn: parent
            width:            360 * pigletPuzzlePage.screenScale
            height:           360 * pigletPuzzlePage.screenScale
            source:           "qrc:/resources/images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/original.png"
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
        width:            parent.height
        height:           parent.width
        rotation:         pigletPuzzlePage.screenRotation
        z:                2
        color:            "black"

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
                    width:            434
                    height:           160
                    source:           "qrc:/resources/images/piglet_puzzle/complexity_selection_background.png"

                    Row {
                        id:               complexitySelectionRow
                        anchors.centerIn: parent
                        spacing:          10

                        Image {
                            id:     mediumComplexityButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_puzzle/complexity_medium.png"

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
                            id:     hardComplexityButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_puzzle/complexity_hard.png"

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
                    anchors.rightMargin: 30
                    width:               64
                    height:              64
                    z:                   1
                    source:              "qrc:/resources/images/back.png"

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
        width:            parent.height
        height:           parent.width
        rotation:         pigletPuzzlePage.screenRotation
        z:                2
        color:            "black"
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
                    width:            434
                    height:           160
                    source:           "qrc:/resources/images/piglet_puzzle/puzzle_selection_background.png"

                    Row {
                        id:               puzzleSelectionRow
                        anchors.centerIn: parent
                        spacing:          10

                        Image {
                            id:     heartBalloonPuzzleButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_puzzle/heart_balloon/original_thumbnail.png"

                            MouseArea {
                                id:           heartBalloonImageButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleType      = "heart_balloon";
                                    puzzleSelectionRectangle.visible = false;

                                    beginGame();
                                }
                            }
                        }

                        Image {
                            id:     pigletOnPottyPuzzleButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_puzzle/piglet_on_potty/original_thumbnail.png"

                            MouseArea {
                                id:           pigletOnPottyPuzzleButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleType      = "piglet_on_potty";
                                    puzzleSelectionRectangle.visible = false;

                                    beginGame();
                                }
                            }
                        }

                        Image {
                            id:     wateringFlowersPuzzleButtonImage
                            width:  120
                            height: 120
                            source: "qrc:/resources/images/piglet_puzzle/watering_flowers/original_thumbnail.png"

                            MouseArea {
                                id:           wateringFlowersPuzzleButtonMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    pigletPuzzlePage.puzzleType      = "watering_flowers";
                                    puzzleSelectionRectangle.visible = false;

                                    beginGame();
                                }
                            }
                        }
                    }
                }

                Image {
                    id:                  puzzleSelectionBackButtonImage
                    anchors.bottom:      parent.bottom
                    anchors.right:       parent.right
                    anchors.rightMargin: 30
                    width:               64
                    height:              64
                    z:                   1
                    source:              "qrc:/resources/images/back.png"

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
