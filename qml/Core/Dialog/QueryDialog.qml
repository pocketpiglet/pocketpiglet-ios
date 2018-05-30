import QtQuick 2.9

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
        width:            Math.min(parent.width, parent.height) - 16
        height:           Math.min(parent.width, parent.height) - 72
        source:           "qrc:/resources/images/dialog/dialog.png"
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

        Text {
            anchors.fill:         parent
            anchors.margins:      16
            anchors.bottomMargin: 40
            clip:                 true
            color:                "black"
            horizontalAlignment:  Text.AlignHCenter
            verticalAlignment:    Text.AlignVCenter
            wrapMode:             Text.Wrap
            text:                 queryDialog.text
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
