import QtQuick 2.9

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

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        width:            parent.width < parent.height ? parent.width : parent.height
        fillMode:         Image.PreserveAspectFit
        source:           "qrc:/resources/images/dialog/dialog.png"

        Text {
            anchors.fill:         parent
            anchors.margins:      16
            anchors.bottomMargin: 40
            clip:                 true
            color:                "black"
            horizontalAlignment:  Text.AlignHCenter
            verticalAlignment:    Text.AlignVCenter
            wrapMode:             Text.Wrap
            text:                 dialogScreenLockMouseArea.text
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
                    dialogScreenLockMouseArea.visible = false;

                    dialogScreenLockMouseArea.yes();
                    dialogScreenLockMouseArea.closed();
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
