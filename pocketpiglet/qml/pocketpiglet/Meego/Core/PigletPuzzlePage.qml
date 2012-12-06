import QtQuick 1.1
import QtMultimediaKit 1.1
import com.nokia.meego 1.0

import "PigletPuzzlePage.js" as PigletPuzzlePageScript

Page {
    id:              pigletPuzzlePage
    anchors.fill:    parent
    orientationLock: PageOrientation.LockLandscape

    property bool appInForeground:    Qt.application.active
    property bool audioActive:        false
    property bool puzzleSolved:       false

    property real screenFactorX:      backgroundImage.paintedWidth / backgroundImage.sourceSize.width
    property real screenFactorY:      backgroundImage.paintedHeight / backgroundImage.sourceSize.height

    property string puzzleType:       "watering_flowers"
    property string puzzleComplexity: ""

    onStatusChanged: {
        if (status === PageStatus.Active) {
            waitRectangle.visible = true;

            gameBeginTimer.start();
        } else {
            if (audioActive) {
                audio.stop();
            }
        }
    }

    onAppInForegroundChanged: {
        if (appInForeground) {
            pauseRectangle.visible = false;
        } else {
            pauseRectangle.visible = true;
        }
    }

    function beginGame() {
        puzzleSolved = false;

        PigletPuzzlePageScript.createMap(pigletPuzzlePage.puzzleComplexity);

        pigletPuzzlePage.playAudio("../../sound/piglet_puzzle/game_start.wav");
    }

    function elementClicked(element) {
        if (PigletPuzzlePageScript.moveElement(puzzleComplexity, element)) {
            puzzleSolved = true;

            originalImage.blink();

            pigletPuzzlePage.playAudio("../../sound/piglet_puzzle/game_complete.wav");
        }
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
        muted:  pigletPuzzlePage.appInForeground ? false : true

        onStarted: {
            pigletPuzzlePage.audioActive = true;
        }

        onStopped: {
            pigletPuzzlePage.audioActive = false;
        }
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        Image {
            id:           backgroundImage
            anchors.fill: parent
            source:       "qrc:/resources/images/background.png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true
        }

        Image {
            id:           originalSampleImageThumbnail
            anchors.top:  parent.top
            anchors.left: parent.left
            width:        120 * pigletPuzzlePage.screenFactorX
            height:       120 * pigletPuzzlePage.screenFactorY
            z:            2
            source:       "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/original_thumbnail.png"
            fillMode:     Image.PreserveAspectFit
            smooth:       true

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
            width:            360 * pigletPuzzlePage.screenFactorX
            height:           360 * pigletPuzzlePage.screenFactorY
            z:                2
            color:            "transparent"

            property list<Image> puzzleElementsMedium: [
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        0   * pigletPuzzlePage.screenFactorX
                    y:        0   * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   pigletPuzzlePage.puzzleSolved ? "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/9.png"
                                                            : "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/0.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        120 * pigletPuzzlePage.screenFactorX
                    y:        0   * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/1.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        240 * pigletPuzzlePage.screenFactorX
                    y:        0   * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/2.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        0   * pigletPuzzlePage.screenFactorX
                    y:        120 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/3.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        120 * pigletPuzzlePage.screenFactorX
                    y:        120 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/4.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        240 * pigletPuzzlePage.screenFactorX
                    y:        120 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/5.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        0   * pigletPuzzlePage.screenFactorX
                    y:        240 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/6.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        120 * pigletPuzzlePage.screenFactorX
                    y:        240 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/7.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    120 * pigletPuzzlePage.screenFactorX
                    height:   120 * pigletPuzzlePage.screenFactorY
                    x:        240 * pigletPuzzlePage.screenFactorX
                    y:        240 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "medium"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/medium/8.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90 * pigletPuzzlePage.screenFactorX
                    height:   90 * pigletPuzzlePage.screenFactorY
                    x:        0  * pigletPuzzlePage.screenFactorX
                    y:        0  * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   pigletPuzzlePage.puzzleSolved ? "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/16.png"
                                                            : "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/0.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

                    MouseArea {
                        anchors.fill: parent
                        enabled:      pigletPuzzlePage.puzzleSolved ? false : true
                    }
                },
                Image {
                    parent:   gameFieldRectangle
                    width:    90 * pigletPuzzlePage.screenFactorX
                    height:   90 * pigletPuzzlePage.screenFactorY
                    x:        90 * pigletPuzzlePage.screenFactorX
                    y:        0  * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/1.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        180 * pigletPuzzlePage.screenFactorX
                    y:        0   * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/2.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        270 * pigletPuzzlePage.screenFactorX
                    y:        0   * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/3.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90 * pigletPuzzlePage.screenFactorX
                    height:   90 * pigletPuzzlePage.screenFactorY
                    x:        0  * pigletPuzzlePage.screenFactorX
                    y:        90 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/4.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90 * pigletPuzzlePage.screenFactorX
                    height:   90 * pigletPuzzlePage.screenFactorY
                    x:        90 * pigletPuzzlePage.screenFactorX
                    y:        90 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/5.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        180 * pigletPuzzlePage.screenFactorX
                    y:        90  * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/6.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        270 * pigletPuzzlePage.screenFactorX
                    y:        90  * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/7.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        0   * pigletPuzzlePage.screenFactorX
                    y:        180 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/8.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        90  * pigletPuzzlePage.screenFactorX
                    y:        180 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/9.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        180 * pigletPuzzlePage.screenFactorX
                    y:        180 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/10.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        270 * pigletPuzzlePage.screenFactorX
                    y:        180 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/11.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        0   * pigletPuzzlePage.screenFactorX
                    y:        270 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/12.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        90  * pigletPuzzlePage.screenFactorX
                    y:        270 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/13.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        180 * pigletPuzzlePage.screenFactorX
                    y:        270 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/14.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                    width:    90  * pigletPuzzlePage.screenFactorX
                    height:   90  * pigletPuzzlePage.screenFactorY
                    x:        270 * pigletPuzzlePage.screenFactorX
                    y:        270 * pigletPuzzlePage.screenFactorY
                    visible:  pigletPuzzlePage.puzzleComplexity === "hard"
                    source:   "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/hard/15.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:   true

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
                z:            3
                visible:      false
                source:       "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/original.png"
                fillMode:     Image.PreserveAspectFit
                smooth:       true
                opacity:      0.0

                function blink() {
                    visible = true;

                    originalImageIncOpacityPropertyAnimation.start();
                }

                MouseArea {
                    id:           originalImageMouseArea
                    anchors.fill: parent
                }

                PropertyAnimation {
                    id:          originalImageIncOpacityPropertyAnimation
                    target:      originalImage
                    property:    "opacity"
                    from:        0.0
                    to:          1.0
                    duration:    500
                    easing.type: Easing.InExpo

                    onRunningChanged: {
                        if (!running) {
                            originalImageDecOpacityPropertyAnimation.start();
                        }
                    }
                }

                PropertyAnimation {
                    id:          originalImageDecOpacityPropertyAnimation
                    target:      originalImage
                    property:    "opacity"
                    from:        1.0
                    to:          0.0
                    duration:    500
                    easing.type: Easing.OutExpo

                    onRunningChanged: {
                        if (!running) {
                            originalImage.visible = false;
                        }
                    }
                }
            }
        }

        Image {
            id:             refreshButtonImage
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            width:          48
            height:         48
            z:              10
            source:         "qrc:/resources/images/refresh.png"

            MouseArea {
                id:           refreshButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    waitRectangle.visible = true;

                    gameBeginTimer.start();
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
                    pigletPage.gameFinished("piglet_puzzle");

                    mainPageStack.replace(pigletPage);
                }
            }
        }
    }

    Rectangle {
        id:           originalSampleImageRectangle
        anchors.fill: parent
        z:            40
        color:        "transparent"
        visible:      false

        Image {
            id:               originalSampleImage
            anchors.centerIn: parent
            width:            360 * pigletPuzzlePage.screenFactorX
            height:           360 * pigletPuzzlePage.screenFactorY
            source:           "../../images/piglet_puzzle/" + pigletPuzzlePage.puzzleType + "/original.png"
            fillMode:         Image.PreserveAspectFit
            smooth:           true
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
                            pigletPage.gameFinished("piglet_puzzle");

                            mainPageStack.replace(pigletPage);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id:           puzzleSelectionRectangle
        anchors.fill: parent
        z:            60
        color:        "black"
        visible:      false

        MouseArea {
            id:           puzzleSelectionRectangleMouseArea
            anchors.fill: parent

            Image {
                id:           puzzleSelectionBackgroundImage
                anchors.fill: parent
                source:       "qrc:/resources/images/background.png"
                fillMode:     Image.PreserveAspectFit
                smooth:       true

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
                            source: "../../images/piglet_puzzle/heart_balloon/original_thumbnail.png"

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
                            source: "../../images/piglet_puzzle/piglet_on_potty/original_thumbnail.png"

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
                            source: "../../images/piglet_puzzle/watering_flowers/original_thumbnail.png"

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
                    id:             puzzleSelectionHelpButtonImage
                    anchors.bottom: parent.bottom
                    anchors.left:   parent.left
                    width:          48
                    height:         48
                    z:              61
                    source:         "qrc:/resources/images/help.png"

                    MouseArea {
                        id:           puzzleSelectionHelpButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            helpQueryDialog.open();
                        }
                    }
                }

                Image {
                    id:             puzzleSelectionExitButtonImage
                    anchors.bottom: parent.bottom
                    anchors.right:  parent.right
                    width:          48
                    height:         48
                    z:              61
                    source:         "qrc:/resources/images/exit.png"

                    MouseArea {
                        id:           puzzleSelectionExitButtonMouseArea
                        anchors.fill: parent

                        onClicked: {
                            pigletPage.gameFinished("piglet_puzzle");

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
        titleText:        "Piglet Puzzle"
        icon:             "qrc:/resources/images/dialog_info.png"
        message:          "Your piglet is trying to solve a puzzle! Help him to solve a sliding puzzle as fast as you can."
        acceptButtonText: "OK"
    }

    Timer {
        id:       gameBeginTimer
        interval: 100

        onTriggered: {
            waitRectangle.visible                = false;
            puzzleSelectionRectangle.visible     = false;
            complexitySelectionRectangle.visible = true;
        }
    }
}
