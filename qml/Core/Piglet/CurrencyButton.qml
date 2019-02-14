import QtQuick 2.12

Column {
    id: currencyButton

    property int imageWidth:        0
    property int imageHeight:       0
    property int amount:            0

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal addCurrency()

    onAmountChanged: {
        if (amount > 0) {
            currencyButtonImage.source = sourceNormal;
        } else {
            currencyButtonImage.source = sourceHighlighted;
        }
    }

    Image {
        id:     currencyButtonImage
        width:  currencyButton.imageWidth
        height: currencyButton.imageHeight

        MouseArea {
            anchors.fill: parent

            onClicked: {
                currencyButton.addCurrency();
            }
        }
    }

    Rectangle {
        color:  "white"
        width:  currencyButton.imageWidth
        height: currencyButtonAmountText.height + currencyButtonAmountText.anchors.margins * 2
        radius: 16

        Text {
            id:                  currencyButtonAmountText
            anchors.left:        parent.left
            anchors.right:       parent.right
            anchors.top:         parent.top
            anchors.margins:     4
            text:                currencyButton.amount
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            font.pixelSize:      16
            color:               "black"
        }
    }

    Component.onCompleted: {
        if (amount > 0) {
            currencyButtonImage.source = sourceNormal;
        } else {
            currencyButtonImage.source = sourceHighlighted;
        }
    }
}
