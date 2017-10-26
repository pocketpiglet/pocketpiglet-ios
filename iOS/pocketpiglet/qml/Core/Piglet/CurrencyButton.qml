import QtQuick 2.6

Image {
    id: currencyButton

    property int amount:    0
    property int maxAmount: 0

    signal addCurrency()

    MouseArea {
        id:           currencyButtonMouseArea
        anchors.fill: parent

        onClicked: {
            if (amount < maxAmount) {
                currencyButton.addCurrency();
            }
        }

        Text {
            id:                  amountText
            anchors.centerIn:    parent
            width:               Math.min(parent.width, parent.height) / Math.sqrt(2.0)
            height:              Math.min(parent.width, parent.height) / Math.sqrt(2.0)
            text:                currencyButton.amount
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            fontSizeMode:        Text.Fit
            font.pixelSize:      width
            color:               "white"
        }
    }
}
