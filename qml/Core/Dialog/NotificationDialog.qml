import QtQuick 2.12

MultiPointTouchArea {
    id:               notificationDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    property string text: ""

    signal opened()
    signal closed()

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
