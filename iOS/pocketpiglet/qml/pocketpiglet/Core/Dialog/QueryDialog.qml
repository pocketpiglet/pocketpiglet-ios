import QtQuick 2.9
import QtQuick.Controls 2.2

MouseArea {
    id:               dialogScreenLockMouseArea
    anchors.centerIn: parent
    visible:          false

    property string text: ""

    signal opened()
    signal closed()

    signal yes()
    signal no()

    function open() {
        visible = true;

        opened();
    }

    function close() {
        visible = false;

        no();
        closed();
    }

    Rectangle {
        anchors.centerIn: parent
        width:            parent.width < parent.height ? parent.width * 0.85 : parent.height * 0.85
        height:           parent.width < parent.height ? parent.width * 0.85 : parent.height * 0.85
        color:            "white"

        Text {
            anchors.top:         parent.top
            anchors.bottom:      dialogButtonRow.top
            anchors.left:        parent.left
            anchors.right:       parent.right
            color:               "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            wrapMode:            Text.Wrap
            text:                dialogScreenLockMouseArea.text
        }

        Row {
            id:                       dialogButtonRow
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing:                  16

            Button {
                text: "Yes"

                onClicked: {
                    dialogScreenLockMouseArea.visible = false;

                    dialogScreenLockMouseArea.yes();
                    dialogScreenLockMouseArea.closed();
                }
            }

            Button {
                text: "No"

                onClicked: {
                    dialogScreenLockMouseArea.visible = false;

                    dialogScreenLockMouseArea.no();
                    dialogScreenLockMouseArea.closed();
                }
            }
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
