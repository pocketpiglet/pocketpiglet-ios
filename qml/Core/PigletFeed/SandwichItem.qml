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

        sandwichItemFallAnimation.start();
    }

    function eatItem() {
        sandwichItemEatAnimation.start();
    }

    function clearItem() {
        sandwichItemImage.visible = false;
        sandwichItemImage.opacity = 1.0;
    }

    Image {
        id:           sandwichItemImage
        anchors.fill: parent
        source:       imageSource(sandwichItem.itemType)
        fillMode:     Image.PreserveAspectFit
        visible:      false

        function imageSource(item_type) {
            if (item_type === "bread_bottom") {
                return "qrc:/resources/images/piglet_feed/sandwich_bread_bottom.png";
            } else if (item_type === "bread_top") {
                return "qrc:/resources/images/piglet_feed/sandwich_bread_top.png";
            } else if (item_type === "cheese") {
                return "qrc:/resources/images/piglet_feed/sandwich_cheese.png";
            } else if (item_type === "cucumber") {
                return "qrc:/resources/images/piglet_feed/sandwich_cucumber.png";
            } else if (item_type === "fish") {
                return "qrc:/resources/images/piglet_feed/sandwich_fish.png";
            } else if (item_type === "ketchup") {
                return "qrc:/resources/images/piglet_feed/sandwich_ketchup.png";
            } else if (item_type === "mayonnaise") {
                return "qrc:/resources/images/piglet_feed/sandwich_mayonnaise.png";
            } else if (item_type === "olives") {
                return "qrc:/resources/images/piglet_feed/sandwich_olives.png";
            } else if (item_type === "salad") {
                return "qrc:/resources/images/piglet_feed/sandwich_salad.png";
            } else if (item_type === "tomato") {
                return "qrc:/resources/images/piglet_feed/sandwich_tomato.png";
            } else {
                return "";
            }
        }
    }

    SequentialAnimation {
        id: sandwichItemFallAnimation

        NumberAnimation {
            target:   sandwichItem
            property: "y"
            from:     sandwichItem.initialY
            to:       sandwichItem.finalY
            duration: 500
        }

        ScriptAction {
            script: {
                sandwichItem.fallAnimationDone();
            }
        }
    }

    SequentialAnimation {
        id: sandwichItemEatAnimation

        NumberAnimation {
            target:   sandwichItemImage
            property: "opacity"
            from:     1.0
            to:       0.0
            duration: 1000
        }

        ScriptAction {
            script: {
                sandwichItem.eatAnimationDone();
            }
        }
    }
}
