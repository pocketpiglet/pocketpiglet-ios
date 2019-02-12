import QtQuick 2.9

MouseArea {
    id:               parentalGateDialog
    anchors.centerIn: parent
    visible:          false

    property int parentWidth:  parent.width
    property int parentHeight: parent.height

    signal opened()
    signal closed()

    signal pass()
    signal cancel()

    onParentWidthChanged: {
        if (typeof(parent) !== "undefined" && parent !== null) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    onParentHeightChanged: {
        if (typeof(parent) !== "undefined" && parent !== null) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    onRotationChanged: {
        if (typeof(parent) !== "undefined" && parent !== null) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    function open() {
        visible = true;

        opened();
    }

    function close() {
        visible = false;

        cancel();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        width:            calculateWidth (sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        height:           calculateHeight(sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        source:           "qrc:/resources/images/dialog/parental_gate_dialog.png"
        fillMode:         Image.PreserveAspectFit

        function calculateWidth(src_width, src_height, dst_width, dst_height) {
            if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                if (dst_width / dst_height > src_width / src_height) {
                    return src_width * dst_height / src_height;
                } else {
                    return dst_width;
                }
            } else {
                return 0;
            }
        }

        function calculateHeight(src_width, src_height, dst_width, dst_height) {
            if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                if (dst_width / dst_height > src_width / src_height) {
                    return dst_height;
                } else {
                    return src_height * dst_width / src_width;
                }
            } else {
                return 0;
            }
        }

        MultiPointTouchArea {
            anchors.fill:       parent
            minimumTouchPoints: 2

            touchPoints: [
                TouchPoint { id: touchPoint1 },
                TouchPoint { id: touchPoint2 }
            ]

            onReleased: {
                if (Math.sqrt(Math.pow(touchPoint1.x - touchPoint1.startX, 2) + Math.pow(touchPoint1.y - touchPoint1.startY, 2)) > Math.min(width, height) / 2 &&
                    Math.sqrt(Math.pow(touchPoint2.x - touchPoint2.startX, 2) + Math.pow(touchPoint2.y - touchPoint2.startY, 2)) > Math.min(width, height) / 2) {
                    parentalGateDialog.visible = false;

                    parentalGateDialog.pass();
                    parentalGateDialog.closed();
                }
            }

            Text {
                anchors.fill:         parent
                anchors.margins:      16
                anchors.bottomMargin: 40
                clip:                 true
                color:                "black"
                horizontalAlignment:  Text.AlignHCenter
                verticalAlignment:    Text.AlignVCenter
                wrapMode:             Text.Wrap
                text:                 qsTr("Slide with two fingers over this dialog to continue")
            }
        }
    }

    Image {
        id:                       cancelButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        width:                    64
        height:                   64
        z:                        dialogImage.z + 1
        source:                   "qrc:/resources/images/dialog/cancel.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                parentalGateDialog.visible = false;

                parentalGateDialog.cancel();
                parentalGateDialog.closed();
            }
        }
    }
}
