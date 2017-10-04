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

    Rectangle {
        anchors.centerIn: parent
        width:            parent.width < parent.height ? parent.width * 0.85 : parent.height * 0.85
        height:           parent.width < parent.height ? parent.width * 0.85 : parent.height * 0.85
        color:            "white"

        Text {
            anchors.fill:        parent
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
