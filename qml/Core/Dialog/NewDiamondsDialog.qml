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
        width:            calculateWidth (sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        height:           calculateHeight(sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        source:           "qrc:/resources/images/dialog/new_diamonds_dialog.png"
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
                text:                 "+ %1".arg(newDiamondsDialog.newDiamondsCount)
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
