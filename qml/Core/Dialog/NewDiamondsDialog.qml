import QtQuick 2.12

import "../../Util.js" as UtilScript

MultiPointTouchArea {
    id:               newDiamondsDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    property int newDiamondsAmount: 0

    signal opened()
    signal closed()

    signal ok()

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

    function open(new_diamonds_amount) {
        visible           = true;
        newDiamondsAmount = new_diamonds_amount;

        opened();
    }

    function close() {
        visible = false;

        ok();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        width:            UtilScript.pt(sourceSize.width)
        height:           UtilScript.pt(sourceSize.height)
        source:           "qrc:/resources/images/dialog/new_diamonds_dialog.png"
        fillMode:         Image.PreserveAspectFit

        Column {
            anchors.centerIn: parent
            spacing:          UtilScript.pt(4)

            Image {
                id:       diamondImage
                width:    dialogImage.width  - UtilScript.pt(80)
                height:   dialogImage.height - UtilScript.pt(120)
                source:   "qrc:/resources/images/dialog/new_diamonds_dialog_diamond.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                width:                diamondImage.width
                height:               UtilScript.pt(48)
                text:                 "+ %1".arg(newDiamondsDialog.newDiamondsAmount)
                color:                "black"
                font.pointSize:       32
                font.family:          "Helvetica"
                horizontalAlignment:  Text.AlignHCenter
                verticalAlignment:    Text.AlignVCenter
                fontSizeMode:         Text.Fit
                minimumPointSize:     8
            }
        }
    }

    Image {
        id:                       okButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        z:                        1
        width:                    UtilScript.pt(64)
        height:                   UtilScript.pt(64)
        source:                   "qrc:/resources/images/dialog/ok.png"
        fillMode:                 Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent

            onClicked: {
                newDiamondsDialog.visible = false;

                newDiamondsDialog.ok();
                newDiamondsDialog.closed();
            }
        }
    }
}
