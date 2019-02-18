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
        source:           "qrc:/resources/images/dialog/dialog.png"

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
        spacing:                  dialogImage.width - yesButtonImage.width * 1.5 - noButtonImage.width * 1.5

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
