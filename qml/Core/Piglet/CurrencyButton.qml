import QtQuick 2.12

Column {
    id: currencyButton

    property int imageWidth:        0
    property int imageHeight:       0
    property int amount:            0

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal addCurrency()

    Image {
        id:     currencyButtonImage
        width:  currencyButton.imageWidth
        height: currencyButton.imageHeight
        source: imageSource(currencyButton.amount, currencyButton.sourceNormal, currencyButton.sourceHighlighted)

        function imageSource(amount, source_normal, source_highlighted) {
            if (amount > 0) {
                return source_normal;
            } else {
                return source_highlighted;
            }
        }

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
        height: 24
        radius: 16

        Text {
            id:                  currencyButtonAmountText
            anchors.fill:        parent
            anchors.margins:     4
            text:                currencyButton.amount
            color:               "black"
            font.pixelSize:      16
            font.family:         "Helvetica"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            fontSizeMode:        Text.Fit
            minimumPixelSize:    8
        }
    }
}
