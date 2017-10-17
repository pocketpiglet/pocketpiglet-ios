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
        width:            360
        height:           240
        source:           "qrc:/resources/images/dialog/dialog.png"

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
