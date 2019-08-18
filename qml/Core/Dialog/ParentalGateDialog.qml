import QtQuick 2.12

MultiPointTouchArea {
    id:               parentalGateDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    signal opened()
    signal closed()

    signal passed()
    signal cancelled()

    function dialogWidth(rotation, parent_width, parent_height) {
        if (rotation === 0 || rotation === 180) {
            return parent_width;
        } else if (rotation === 90 || rotation === 270) {
            return parent_height;
        } else {
            return parent_width;
        }
    }

    function dialogHeight(rotation, parent_width, parent_height) {
        if (rotation === 0 || rotation === 180) {
            return parent_height;
        } else if (rotation === 90 || rotation === 270) {
            return parent_width;
        } else {
            return parent_height;
        }
    }

    function open() {
        visible = true;

        opened();
    }

    function close() {
        visible = false;

        cancelled();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        source:           "qrc:/resources/images/dialog/parental_gate_dialog.png"

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

                    parentalGateDialog.passed();
                    parentalGateDialog.closed();
                }
            }

            Text {
                anchors.fill:         parent
                anchors.margins:      16
                anchors.bottomMargin: 40
                text:                 qsTr("Slide with two fingers over this dialog to continue")
                color:                "black"
                font.pointSize:       24
                font.family:          "Helvetica"
                horizontalAlignment:  Text.AlignHCenter
                verticalAlignment:    Text.AlignVCenter
                wrapMode:             Text.Wrap
                fontSizeMode:         Text.Fit
                minimumPointSize:     8
            }
        }
    }

    Image {
        id:                       cancelButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        z:                        1
        width:                    64
        height:                   64
        source:                   "qrc:/resources/images/dialog/cancel.png"
        fillMode:                 Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent

            onClicked: {
                parentalGateDialog.visible = false;

                parentalGateDialog.cancelled();
                parentalGateDialog.closed();
            }
        }
    }
}
