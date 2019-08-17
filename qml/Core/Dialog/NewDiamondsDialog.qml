import QtQuick 2.12

MultiPointTouchArea {
    id:               newDiamondsDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    property int newDiamondsCount: 0

    signal opened()
    signal closed()

    signal ok()

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

    function open(new_diamonds_count) {
        visible          = true;
        newDiamondsCount = new_diamonds_count;

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
        source:           "qrc:/resources/images/dialog/new_diamonds_dialog.png"

        Column {
            anchors.centerIn: parent
            spacing:          4

            Image {
                id:       diamondImage
                width:    dialogImage.width  - 80
                height:   dialogImage.height - 120
                source:   "qrc:/resources/images/dialog/new_diamonds_dialog_diamond.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                width:                diamondImage.width
                height:               48
                text:                 "+ %1".arg(newDiamondsDialog.newDiamondsCount)
                color:                "black"
                font.pixelSize:       32
                font.family:          "Helvetica"
                horizontalAlignment:  Text.AlignHCenter
                verticalAlignment:    Text.AlignVCenter
                fontSizeMode:         Text.Fit
                minimumPixelSize:     8
            }
        }
    }

    Image {
        id:                       okButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        z:                        1
        width:                    64
        height:                   64
        source:                   "qrc:/resources/images/dialog/ok.png"

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
