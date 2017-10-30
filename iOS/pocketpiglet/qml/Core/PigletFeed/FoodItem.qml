import QtQuick 2.9

Rectangle {
    id:     foodItem
    width:  foodItemImage.sourceSize.width  * parent.refrigeratorFactor
    height: foodItemImage.sourceSize.height * parent.refrigeratorFactor
    color:  "transparent"

    property bool itemClickable: false

    property string itemType:    ""

    signal itemClicked()
    signal hideAnimationDone()

    onItemTypeChanged: {
        if (itemType === "cheese") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_cheese.png"
        } else if (itemType === "cucumber") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_cucumber.png"
        } else if (itemType === "fish") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_fish.png"
        } else if (itemType === "ketchup") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_ketchup.png"
        } else if (itemType === "mayonnaise") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_mayonnaise.png"
        } else if (itemType === "olives") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_olives.png"
        } else if (itemType === "salad") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_salad.png"
        } else if (itemType === "tomato") {
            foodItemImage.source = "qrc:/resources/images/piglet_feed/food_tomato.png"
        }
    }

    function hideItem() {
        foodItemHideAnimationItem.start();
    }

    MouseArea {
        id:           foodItemMouseArea
        anchors.fill: parent
        enabled:      foodItem.itemClickable

        onClicked: {
            foodItemSelectAnimationItem.start();

            foodItem.itemClicked();
        }

        Image {
            id:           foodItemImage
            anchors.fill: parent
            fillMode:     Image.PreserveAspectFit
        }
    }

    Item {
        id: foodItemSelectAnimationItem

        property bool animationRunning: false

        function start() {
            if (!animationRunning) {
                animationRunning = true;

                foodItemSelectDecOpacityPropertyAnimation.start();
            }
        }

        PropertyAnimation {
            id:       foodItemSelectDecOpacityPropertyAnimation
            target:   foodItemImage
            property: "opacity"
            from:     1.0
            to:       0.25
            duration: 200

            onRunningChanged: {
                if (foodItemSelectAnimationItem.animationRunning && !running) {
                    foodItemSelectIncOpacityPropertyAnimation.start();
                }
            }
        }

        PropertyAnimation {
            id:       foodItemSelectIncOpacityPropertyAnimation
            target:   foodItemImage
            property: "opacity"
            from:     0.25
            to:       1.0
            duration: 200

            onRunningChanged: {
                if (foodItemSelectAnimationItem.animationRunning && !running) {
                    foodItemSelectAnimationItem.animationRunning = false;
                }
            }
        }
    }

    Item {
        id: foodItemHideAnimationItem

        property bool animationRunning: false

        function start() {
            if (!animationRunning) {
                animationRunning = true;

                foodItemHideDecOpacityPropertyAnimation.start();
            }
        }

        PropertyAnimation {
            id:          foodItemHideDecOpacityPropertyAnimation
            target:      foodItemImage
            property:    "opacity"
            from:        1.0
            to:          0.25
            duration:    500
            easing.type: Easing.OutExpo

            onRunningChanged: {
                if (foodItemHideAnimationItem.animationRunning && !running) {
                    foodItemHideIncOpacityPropertyAnimation.start();
                }
            }
        }

        PropertyAnimation {
            id:          foodItemHideIncOpacityPropertyAnimation
            target:      foodItemImage
            property:    "opacity"
            from:        0.25
            to:          1.0
            duration:    500
            easing.type: Easing.InExpo

            onRunningChanged: {
                if (foodItemHideAnimationItem.animationRunning && !running) {
                    foodItemHideAnimationItem.animationRunning = false;

                    foodItem.hideAnimationDone();
                }
            }
        }
    }
}
