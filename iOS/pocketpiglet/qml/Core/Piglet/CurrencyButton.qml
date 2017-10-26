import QtQuick 2.6

Image {
    id: currencyButton

    property int amount:            0
    property int maxAmount:         0

    property url sourceNormal:      ""
    property url sourceHighlighted: ""

    signal addCurrency()

    onAmountChanged: {
        if (amount > 0) {
            buttonHighlightSequentalAnimation.running = false;
            opacity                                   = 1.0;
            source                                    = sourceNormal;
        } else {
            buttonHighlightSequentalAnimation.running = true;
            opacity                                   = 1.0;
            source                                    = sourceHighlighted;
        }
    }

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
            width:               Math.min(parent.width, parent.height) * 0.95 / Math.sqrt(2.0)
            height:              Math.min(parent.width, parent.height) * 0.95 / Math.sqrt(2.0)
            text:                currencyButton.amount
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            fontSizeMode:        Text.Fit
            font.pixelSize:      width
            color:               "white"
        }
    }

    SequentialAnimation {
        id:    buttonHighlightSequentalAnimation
        loops: Animation.Infinite

        PropertyAnimation {
            target:   currencyButton
            property: "opacity"
            from:     1.0
            to:       0.5
            duration: 500
        }

        PropertyAnimation {
            target:   currencyButton
            property: "opacity"
            from:     0.5
            to:       1.0
            duration: 500
        }
    }

    Component.onCompleted: {
        if (amount > 0) {
            buttonHighlightSequentalAnimation.running = false;
            opacity                                   = 1.0;
            source                                    = sourceNormal;
        } else {
            buttonHighlightSequentalAnimation.running = true;
            opacity                                   = 1.0;
            source                                    = sourceHighlighted;
        }
    }
}
