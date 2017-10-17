import QtQuick 2.9

MouseArea {
    id:               dialogScreenLockMouseArea
    anchors.centerIn: parent
    visible:          false

    property string text: ""

    signal opened()
    signal closed()

    function open() {
        visible = true;

        opened();
    }

    function close() {
        visible = false;

        closed();
    }

    Image {
        anchors.centerIn: parent
        width:            (parent.width < parent.height ? parent.width : parent.height) - 16
        height:           (parent.width < parent.height ? parent.width : parent.height) - 72
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
            anchors.fill:        parent
            anchors.margins:     16
            clip:                true
            color:               "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            wrapMode:            Text.Wrap
            text:                dialogScreenLockMouseArea.text
        }
    }

    Component.onCompleted: {
        if (rotation === 0 || rotation === 180) {
            width  = parent.width;
            height = parent.height;
        } else if (rotation === 90 || rotation === 270) {
            width  = parent.height;
            height = parent.width;
        }
    }
}
