import QtQuick 2.12

Rectangle {
    id:     foodItem
    width:  foodItemImage.sourceSize.width  * parent.refrigeratorScale
    height: foodItemImage.sourceSize.height * parent.refrigeratorScale
    color:  "transparent"

    property bool itemClickable: false

    property string itemType:    ""

    signal itemClicked()
    signal hideAnimationDone()

    function hideItem() {
        foodItemHideAnimation.start();
    }

    MouseArea {
        id:           foodItemMouseArea
        anchors.fill: parent
        enabled:      foodItem.itemClickable

        onClicked: {
            foodItemSelectAnimation.start();

            foodItem.itemClicked();
        }

        Image {
            id:           foodItemImage
            anchors.fill: parent
            source:       imageSource(foodItem.itemType)
            fillMode:     Image.PreserveAspectFit

            function imageSource(item_type) {
                if (item_type === "cheese") {
                    return "qrc:/resources/images/piglet_feed/food_cheese.png";
                } else if (item_type === "cucumber") {
                    return "qrc:/resources/images/piglet_feed/food_cucumber.png";
                } else if (item_type === "fish") {
                    return "qrc:/resources/images/piglet_feed/food_fish.png";
                } else if (item_type === "ketchup") {
                    return "qrc:/resources/images/piglet_feed/food_ketchup.png";
                } else if (item_type === "mayonnaise") {
                    return "qrc:/resources/images/piglet_feed/food_mayonnaise.png";
                } else if (item_type === "olives") {
                    return "qrc:/resources/images/piglet_feed/food_olives.png";
                } else if (item_type === "salad") {
                    return "qrc:/resources/images/piglet_feed/food_salad.png";
                } else if (item_type === "tomato") {
                    return "qrc:/resources/images/piglet_feed/food_tomato.png";
                } else {
                    return "";
                }
            }
        }
    }

    SequentialAnimation {
        id: foodItemSelectAnimation

        PropertyAnimation {
            target:   foodItemImage
            property: "opacity"
            from:     1.0
            to:       0.25
            duration: 200
        }

        PropertyAnimation {
            target:   foodItemImage
            property: "opacity"
            from:     0.25
            to:       1.0
            duration: 200
        }
    }

    SequentialAnimation {
        id: foodItemHideAnimation

        PropertyAnimation {
            target:      foodItemImage
            property:    "opacity"
            from:        1.0
            to:          0.25
            duration:    500
            easing.type: Easing.OutExpo
        }

        PropertyAnimation {
            target:      foodItemImage
            property:    "opacity"
            from:        0.25
            to:          1.0
            duration:    500
            easing.type: Easing.InExpo
        }

        ScriptAction {
            script: {
                foodItem.hideAnimationDone();
            }
        }
    }
}
