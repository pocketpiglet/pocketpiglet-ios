import QtQuick 2.12

Rectangle {
    id:     sandwichItem
    width:  sandwichItemImage.sourceSize.width  * parent.sandwichScaleX
    height: sandwichItemImage.sourceSize.height * parent.sandwichScaleY
    color:  "transparent"

    property int initialY:    0
    property int finalY:      0

    property string itemType: ""

    signal fallAnimationDone()
    signal eatAnimationDone()

    function dropItem() {
        sandwichItemImage.visible = true;

        sandwichItemFallPropertyAnimation.start();
    }

    function eatItem() {
        sandwichItemEatPropertyAnimation.start();
    }

    function clearItem() {
        sandwichItemImage.visible = false;
        sandwichItemImage.opacity = 1.0;
    }

    onItemTypeChanged: {
        if (itemType === "bread_bottom") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_bread_bottom.png"
        } else if (itemType === "bread_top") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_bread_top.png"
        } else if (itemType === "cheese") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_cheese.png"
        } else if (itemType === "cucumber") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_cucumber.png"
        } else if (itemType === "fish") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_fish.png"
        } else if (itemType === "ketchup") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_ketchup.png"
        } else if (itemType === "mayonnaise") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_mayonnaise.png"
        } else if (itemType === "olives") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_olives.png"
        } else if (itemType === "salad") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_salad.png"
        } else if (itemType === "tomato") {
            sandwichItemImage.source = "qrc:/resources/images/piglet_feed/sandwich_tomato.png"
        }
    }

    Image {
        id:           sandwichItemImage
        anchors.fill: parent
        visible:      false
        fillMode:     Image.PreserveAspectFit
    }

    PropertyAnimation {
        id:       sandwichItemFallPropertyAnimation
        target:   sandwichItem
        property: "y"
        from:     sandwichItem.initialY
        to:       sandwichItem.finalY
        duration: 500

        onRunningChanged: {
            if (!running) {
                sandwichItem.fallAnimationDone();
            }
        }
    }

    PropertyAnimation {
        id:       sandwichItemEatPropertyAnimation
        target:   sandwichItemImage
        property: "opacity"
        from:     1.0
        to:       0.0
        duration: 1000

        onRunningChanged: {
            if (!running) {
                sandwichItem.eatAnimationDone();
            }
        }
    }
}
