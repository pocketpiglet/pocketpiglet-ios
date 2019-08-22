import QtQuick 2.12

import "Refrigerator.js" as RefrigeratorScript

Rectangle {
    id:     refrigerator
    width:  refrigeratorWidth(refrigeratorImage.sourceSize.width,
                              refrigeratorImage.sourceSize.height,
                              parent.width, parent.height)
    height: refrigeratorHeight(refrigeratorImage.sourceSize.width,
                               refrigeratorImage.sourceSize.height,
                               parent.width, parent.height)
    color:  "transparent"

    readonly property real refrigeratorScale: refrigeratorImage.paintedWidth / refrigeratorImage.sourceSize.width

    property bool foodItemsEnabled:           false

    property int currentFoodItemNum:          0
    property int orderedFoodItemsCount:       0

    property string refrigeratorType:         ""

    property list<FoodItem> foodItemsEasy: [
        FoodItem {
            id:       saladFoodItemEasy
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        100 * refrigerator.refrigeratorScale
            itemType: "salad"
            visible:  refrigerator.refrigeratorType === "easy"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       tomatoFoodItemEasy
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        100 * refrigerator.refrigeratorScale
            itemType: "tomato"
            visible:  refrigerator.refrigeratorType === "easy"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       fishFoodItemEasy
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        260 * refrigerator.refrigeratorScale
            itemType: "fish"
            visible:  refrigerator.refrigeratorType === "easy"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       cheeseFoodItemEasy
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        260 * refrigerator.refrigeratorScale
            itemType: "cheese"
            visible:  refrigerator.refrigeratorType === "easy"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        }
    ]

    property list<FoodItem> foodItemsMedium: [
        FoodItem {
            id:       saladFoodItemMedium
            parent:   refrigerator
            x:        20 * refrigerator.refrigeratorScale
            y:        50 * refrigerator.refrigeratorScale
            itemType: "salad"
            visible:  refrigerator.refrigeratorType === "medium"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       tomatoFoodItemMedium
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        50  * refrigerator.refrigeratorScale
            itemType: "tomato"
            visible:  refrigerator.refrigeratorType === "medium"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       fishFoodItemMedium
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        160 * refrigerator.refrigeratorScale
            itemType: "fish"
            visible:  refrigerator.refrigeratorType === "medium"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       cheeseFoodItemMedium
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        160 * refrigerator.refrigeratorScale
            itemType: "cheese"
            visible:  refrigerator.refrigeratorType === "medium"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       cucumberFoodItemMedium
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        260 * refrigerator.refrigeratorScale
            itemType: "cucumber"
            visible:  refrigerator.refrigeratorType === "medium"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       olivesFoodItemMedium
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        260 * refrigerator.refrigeratorScale
            itemType: "olives"
            visible:  refrigerator.refrigeratorType === "medium"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        }
    ]

    property list<FoodItem> foodItemsHard: [
        FoodItem {
            id:       saladFoodItemHard
            parent:   refrigerator
            x:        20 * refrigerator.refrigeratorScale
            y:        20 * refrigerator.refrigeratorScale
            itemType: "salad"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       fishFoodItemHard
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        20  * refrigerator.refrigeratorScale
            itemType: "fish"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       cucumberFoodItemHard
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        100 * refrigerator.refrigeratorScale
            itemType: "cucumber"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       olivesFoodItemHard
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        100 * refrigerator.refrigeratorScale
            itemType: "olives"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       cheeseFoodItemHard
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        180 * refrigerator.refrigeratorScale
            itemType: "cheese"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       tomatoFoodItemHard
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        180 * refrigerator.refrigeratorScale
            itemType: "tomato"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       ketchupFoodItemHard
            parent:   refrigerator
            x:        20  * refrigerator.refrigeratorScale
            y:        260 * refrigerator.refrigeratorScale
            itemType: "ketchup"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:       mayonnaiseFoodItemHard
            parent:   refrigerator
            x:        156 * refrigerator.refrigeratorScale
            y:        260 * refrigerator.refrigeratorScale
            itemType: "mayonnaise"
            visible:  refrigerator.refrigeratorType === "hard"
            enabled:  refrigerator.foodItemsEnabled

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        }
    ]

    signal validFoodItemSelected(string item_type, bool last_item)
    signal invalidFoodItemSelected()

    function refrigeratorWidth(src_width, src_height, dst_width, dst_height) {
        if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
            if (dst_width / dst_height > src_width / src_height) {
                return src_width * dst_height / src_height;
            } else {
                return dst_width;
            }
        } else {
            return 0;
        }
    }

    function refrigeratorHeight(src_width, src_height, dst_width, dst_height) {
        if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
            if (dst_width / dst_height > src_width / src_height) {
                return dst_height;
            } else {
                return src_height * dst_width / src_width;
            }
        } else {
            return 0;
        }
    }

    function prepareOrder(items_to_order) {
        RefrigeratorScript.OrderedFood = [];

        for (var i = 0; i < items_to_order; i++) {
            if (refrigeratorType === "easy") {
                RefrigeratorScript.OrderedFood[i] = Math.floor(Math.random() * foodItemsEasy.length);
            } else if (refrigeratorType === "medium") {
                RefrigeratorScript.OrderedFood[i] = Math.floor(Math.random() * foodItemsMedium.length);
            } else if (refrigeratorType === "hard") {
                RefrigeratorScript.OrderedFood[i] = Math.floor(Math.random() * foodItemsHard.length);
            }

            for (var j = Math.max(0, i - 2); j < i; j++) {
                if (RefrigeratorScript.OrderedFood[i] === RefrigeratorScript.OrderedFood[j]) {
                    i = i - 1;

                    break;
                }
            }
        }
    }

    function startOrder(items_to_order) {
        foodItemsEnabled      = false;
        orderedFoodItemsCount = items_to_order;
        currentFoodItemNum    = 0;

        orderIntervalTimer.start();
    }

    function nextOrder() {
        if (currentFoodItemNum < orderedFoodItemsCount) {
            if (refrigeratorType === "easy") {
                foodItemsEasy[RefrigeratorScript.OrderedFood[currentFoodItemNum]].hideItem();
            } else if (refrigeratorType === "medium") {
                foodItemsMedium[RefrigeratorScript.OrderedFood[currentFoodItemNum]].hideItem();
            } else if (refrigeratorType === "hard") {
                foodItemsHard[RefrigeratorScript.OrderedFood[currentFoodItemNum]].hideItem();
            }

            currentFoodItemNum = currentFoodItemNum + 1;
        } else {
            foodItemsEnabled   = true;
            currentFoodItemNum = 0;
        }
    }

    function cancelOrder() {
        foodItemsEnabled      = false;
        orderedFoodItemsCount = 0;
        currentFoodItemNum    = 0;

        orderIntervalTimer.stop();
    }

    function validateSelectedFoodItem(item_type) {
        if (currentFoodItemNum < orderedFoodItemsCount) {
            if (refrigeratorType === "easy") {
                if (item_type === foodItemsEasy[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                    currentFoodItemNum = currentFoodItemNum + 1;

                    if (currentFoodItemNum >= orderedFoodItemsCount) {
                        validFoodItemSelected(item_type, true);
                    } else {
                        validFoodItemSelected(item_type, false);
                    }
                } else {
                    invalidFoodItemSelected();
                }
            } else if (refrigeratorType === "medium") {
                if (item_type === foodItemsMedium[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                    currentFoodItemNum = currentFoodItemNum + 1;

                    if (currentFoodItemNum >= orderedFoodItemsCount) {
                        validFoodItemSelected(item_type, true);
                    } else {
                        validFoodItemSelected(item_type, false);
                    }
                } else {
                    invalidFoodItemSelected();
                }
            } else if (refrigeratorType === "hard") {
                if (item_type === foodItemsHard[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                    currentFoodItemNum = currentFoodItemNum + 1;

                    if (currentFoodItemNum >= orderedFoodItemsCount) {
                        validFoodItemSelected(item_type, true);
                    } else {
                        validFoodItemSelected(item_type, false);
                    }
                } else {
                    invalidFoodItemSelected();
                }
            }

            if (currentFoodItemNum >= orderedFoodItemsCount) {
                foodItemsEnabled = false;
            }
        }
    }

    Image {
        id:           refrigeratorImage
        anchors.fill: parent
        source:       imageSource(refrigerator.refrigeratorType)
        fillMode:     Image.PreserveAspectFit

        function imageSource(refrigerator_type) {
            if (refrigerator_type === "easy") {
                return "qrc:/resources/images/piglet_feed/refrigerator_easy.png";
            } else if (refrigerator_type === "medium") {
                return "qrc:/resources/images/piglet_feed/refrigerator_medium.png";
            } else if (refrigerator_type === "hard") {
                return "qrc:/resources/images/piglet_feed/refrigerator_hard.png";
            } else {
                return "";
            }
        }
    }

    Timer {
        id:       orderIntervalTimer
        interval: 500

        onTriggered: {
            refrigerator.nextOrder();
        }
    }
}
