import QtQuick 2.12

import "../../Util.js" as UtilScript

MultiPointTouchArea {
    id:               queryDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    property string text: ""

    signal opened()
    signal closed()

    signal yes()
    signal no()

    function dialogWidth(rotation, parent_width, parent_height) {
        if (rotation === 90 || rotation === 270) {
            return parent_height;
        } else {
            return parent_width;
        }
    }

    function dialogHeight(rotation, parent_width, parent_height) {
        if (rotation === 90 || rotation === 270) {
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

        no();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        width:            UtilScript.pt(sourceSize.width)
        height:           UtilScript.pt(sourceSize.height)
        source:           "qrc:/resources/images/dialog/dialog.png"
        fillMode:         Image.PreserveAspectFit

        Text {
            anchors.fill:         parent
            anchors.margins:      UtilScript.pt(16)
            anchors.bottomMargin: UtilScript.pt(40)
            text:                 queryDialog.text
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

    Row {
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        z:                        1
        spacing:                  dialogImage.width - yesButtonImage.width * 1.5 - noButtonImage.width * 1.5

        Image {
            id:       yesButtonImage
            width:    UtilScript.pt(64)
            height:   UtilScript.pt(64)
            source:   "qrc:/resources/images/dialog/yes.png"
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    queryDialog.visible = false;

                    queryDialog.yes();
                    queryDialog.closed();
                }
            }
        }

        Image {
            id:       noButtonImage
            width:    UtilScript.pt(64)
            height:   UtilScript.pt(64)
            source:   "qrc:/resources/images/dialog/no.png"
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    queryDialog.visible = false;

                    queryDialog.no();
                    queryDialog.closed();
                }
            }
        }
    }
}
