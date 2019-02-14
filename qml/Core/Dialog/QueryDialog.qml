import QtQuick 2.12

MouseArea {
    id:               queryDialog
    anchors.centerIn: parent
    visible:          false

    property int parentWidth:  parent.width
    property int parentHeight: parent.height

    property string text:      ""

    signal opened()
    signal closed()

    signal yes()
    signal no()

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

        no();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        width:            calculateWidth (sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        height:           calculateHeight(sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        source:           "qrc:/resources/images/dialog/dialog.png"
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

        Text {
            anchors.fill:         parent
            anchors.margins:      16
            anchors.bottomMargin: 40
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
        spacing:                  dialogImage.width - yesButtonImage.width * 2 - noButtonImage.width * 2

        Image {
            id:     yesButtonImage
            width:  64
            height: 64
            z:      dialogImage.z + 1
            source: "qrc:/resources/images/dialog/yes.png"

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
            id:     noButtonImage
            width:  64
            height: 64
            z:      dialogImage.z + 1
            source: "qrc:/resources/images/dialog/no.png"

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
