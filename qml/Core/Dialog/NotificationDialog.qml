import QtQuick 2.12

MouseArea {
    id:               notificationDialog
    anchors.centerIn: parent
    visible:          false

    readonly property int parentWidth:  parent.width
    readonly property int parentHeight: parent.height

    property string text:               ""

    signal opened()
    signal closed()

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

        closed();
    }

    Image {
        anchors.centerIn: parent
        source:           "qrc:/resources/images/dialog/dialog.png"

        Text {
            anchors.fill:        parent
            anchors.margins:     16
            text:                notificationDialog.text
            color:               "black"
            font.pointSize:      24
            font.family:         "Helvetica"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            wrapMode:            Text.Wrap
            fontSizeMode:        Text.Fit
            minimumPointSize:    8
        }
    }
}
