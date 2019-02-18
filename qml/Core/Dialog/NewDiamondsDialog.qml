import QtQuick 2.12

MouseArea {
    id:               newDiamondsDialog
    anchors.centerIn: parent
    visible:          false

    property int parentWidth:      parent.width
    property int parentHeight:     parent.height
    property int newDiamondsCount: 0

    signal opened()
    signal closed()

    signal ok()

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
                width:    120
                height:   120
                source:   "qrc:/resources/images/dialog/new_diamonds_dialog_diamond.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                width:                dialogImage.width - 32
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
        width:                    64
        height:                   64
        z:                        dialogImage.z + 1
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
