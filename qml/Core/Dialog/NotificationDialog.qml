import QtQuick 2.12

import "../../Util.js" as UtilScript

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
        width:            UtilScript.pt(sourceSize.width)
        height:           UtilScript.pt(sourceSize.height)
        source:           "qrc:/resources/images/dialog/dialog.png"
        fillMode:         Image.PreserveAspectFit

        Text {
            anchors.fill:        parent
            anchors.margins:     UtilScript.pt(16)
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
