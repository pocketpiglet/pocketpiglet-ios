import QtQuick 2.12

import "../../Util.js" as UtilScript

Column {
    id: currencyButton

    property int imageWidth:        0
    property int imageHeight:       0
    property int amount:            0

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal clicked()

    Image {
        id:       currencyButtonImage
        width:    currencyButton.imageWidth
        height:   currencyButton.imageHeight
        source:   imageSource(currencyButton.amount, currencyButton.sourceNormal, currencyButton.sourceHighlighted)
        fillMode: Image.PreserveAspectFit

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
                currencyButton.clicked();
            }
        }
    }

    Rectangle {
        width:  currencyButton.imageWidth
        height: UtilScript.dp(24)
        color:  "white"
        radius: UtilScript.dp(16)

        Text {
            id:                  currencyButtonAmountText
            anchors.fill:        parent
            anchors.margins:     UtilScript.dp(4)
            text:                currencyButton.amount
            color:               "black"
            font.pointSize:      16
            font.family:         "Helvetica"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            fontSizeMode:        Text.Fit
            minimumPointSize:    8
        }
    }
}
