import QtQuick 2.9

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
        width:            Math.min(parent.width, parent.height) - 96
        height:           Math.min(parent.width, parent.height) - 96
        source:           "qrc:/resources/images/dialog/new_diamonds_dialog.png"
        fillMode:         Image.PreserveAspectFit

        property bool geometrySettled: false

        onPaintedWidthChanged: {
            if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                geometrySettled = true;

                width  = paintedWidth;
                height = paintedHeight;
            }
        }

        onPaintedHeightChanged: {
            if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                geometrySettled = true;

                width  = paintedWidth;
                height = paintedHeight;
            }
        }

        Column {
            anchors.centerIn: parent
            spacing:          4

            Image {
                id:       diamondImage
                width:    dialogImage.width  - 120
                height:   dialogImage.height - 120
                source:   "qrc:/resources/images/dialog/new_diamonds_dialog_diamond.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                width:                diamondImage.width
                height:               36
                clip:                 true
                color:                "black"
                horizontalAlignment:  Text.AlignHCenter
                verticalAlignment:    Text.AlignVCenter
                font.pixelSize:       32
                text:                 "+%1".arg(newDiamondsDialog.newDiamondsCount)
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
