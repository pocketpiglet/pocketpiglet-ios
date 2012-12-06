import QtQuick 1.1

import "Refrigerator.js" as RefrigeratorScript

Rectangle {
    id:     refrigerator
    width:  refrigeratorImage.sourceSize.width  * pigletFeedPage.screenFactorX
    height: refrigeratorImage.sourceSize.height * pigletFeedPage.screenFactorY
    color:  "transparent"

    property bool foodItemsClickable:   false

    property int currentFoodItemNum:    0
    property int visibleFoodItemsCount: 0
    property int orderedFoodItemsCount: 0

    property string refrigeratorType:   ""

    property list<FoodItem> foodItemsEasy: [
        FoodItem {
            id:            saladFoodItemEasy
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 100 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "easy"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "salad"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            tomatoFoodItemEasy
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 100 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "easy"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "tomato"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            fishFoodItemEasy
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 260 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "easy"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "fish"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            cheeseFoodItemEasy
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 260 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "easy"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "cheese"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        }
    ]

    property list<FoodItem> foodItemsMedium: [
        FoodItem {
            id:            saladFoodItemMedium
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 50 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "medium"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "salad"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            tomatoFoodItemMedium
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 50  * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "medium"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "tomato"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            fishFoodItemMedium
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 160 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "medium"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "fish"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            cheeseFoodItemMedium
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 160 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "medium"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "cheese"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            cucumberFoodItemMedium
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 260 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "medium"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "cucumber"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            olivesFoodItemMedium
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 260 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "medium"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "olives"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        }
    ]

    property list<FoodItem> foodItemsHard: [
        FoodItem {
            id:            saladFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 20 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "salad"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            cucumberFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 20  * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "cucumber"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            fishFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 100 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "fish"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            olivesFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 100 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "olives"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            cheeseFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 180 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "cheese"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            tomatoFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 180 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "tomato"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            ketchupFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 260 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "ketchup"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        },
        FoodItem {
            id:            mayonnaiseFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 260 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "mayonnaise"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                refrigerator.visibleFoodItemsCount = refrigerator.visibleFoodItemsCount + 1;
            }
        }
    ]

    signal validFoodItemSelected(string itemType, bool lastItem)
    signal invalidFoodItemSelected()

    onVisibleFoodItemsCountChanged: {
        if (refrigeratorType === "easy") {
            if (visibleFoodItemsCount >= foodItemsEasy.length - 1) {
                orderIntervalTimer.start();
            }
        } else if (refrigeratorType === "medium") {
            if (visibleFoodItemsCount >= foodItemsMedium.length - 1) {
                orderIntervalTimer.start();
            }
        } else if (refrigeratorType === "hard") {
            if (visibleFoodItemsCount >= foodItemsHard.length - 1) {
                orderIntervalTimer.start();
            }
        }
    }

    onRefrigeratorTypeChanged: {
        if (refrigeratorType === "easy") {
            refrigeratorImage.source = "qrc:/resources/images/piglet_feed/refrigerator_easy.png";
        } else if (refrigeratorType === "medium") {
            refrigeratorImage.source = "qrc:/resources/images/piglet_feed/refrigerator_medium.png";
        } else if (refrigeratorType === "hard") {
            refrigeratorImage.source = "qrc:/resources/images/piglet_feed/refrigerator_hard.png";
        }
    }

    function prepareOrder(itemsToOrder) {
        RefrigeratorScript.OrderedFood = [];

        for (var i = 0; i < itemsToOrder; i++) {
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

    function beginOrder(itemsToOrder) {
        foodItemsClickable    = false;
        orderedFoodItemsCount = itemsToOrder;
        currentFoodItemNum    = 0;

        orderIntervalTimer.start();
    }

    function nextOrder() {
        if (currentFoodItemNum < orderedFoodItemsCount) {
            visibleFoodItemsCount = 0;

            if (refrigeratorType === "easy") {
                for (var i = 0; i < foodItemsEasy.length; i++) {
                    if (foodItemsEasy[i].itemType !== foodItemsEasy[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                        foodItemsEasy[i].hideItem();
                    }
                }
            } else if (refrigeratorType === "medium") {
                for (var i = 0; i < foodItemsMedium.length; i++) {
                    if (foodItemsMedium[i].itemType !== foodItemsMedium[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                        foodItemsMedium[i].hideItem();
                    }
                }
            } else if (refrigeratorType === "hard") {
                for (var i = 0; i < foodItemsHard.length; i++) {
                    if (foodItemsHard[i].itemType !== foodItemsHard[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                        foodItemsHard[i].hideItem();
                    }
                }
            }

            currentFoodItemNum = currentFoodItemNum + 1;
        } else {
            foodItemsClickable = true;
            currentFoodItemNum = 0;
        }
    }

    function cancelOrder() {
        foodItemsClickable    = false;
        orderedFoodItemsCount = 0;
        currentFoodItemNum    = 0;

        orderIntervalTimer.stop();
    }

    function validateSelectedFoodItem(itemType) {
        if (currentFoodItemNum < orderedFoodItemsCount) {
            if (refrigeratorType === "easy") {
                if (itemType === foodItemsEasy[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                    currentFoodItemNum = currentFoodItemNum + 1;

                    if (currentFoodItemNum >= orderedFoodItemsCount) {
                        validFoodItemSelected(itemType, true);
                    } else {
                        validFoodItemSelected(itemType, false);
                    }
                } else {
                    invalidFoodItemSelected();
                }
            } else if (refrigeratorType === "medium") {
                if (itemType === foodItemsMedium[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                    currentFoodItemNum = currentFoodItemNum + 1;

                    if (currentFoodItemNum >= orderedFoodItemsCount) {
                        validFoodItemSelected(itemType, true);
                    } else {
                        validFoodItemSelected(itemType, false);
                    }
                } else {
                    invalidFoodItemSelected();
                }
            } else if (refrigeratorType === "hard") {
                if (itemType === foodItemsHard[RefrigeratorScript.OrderedFood[currentFoodItemNum]].itemType) {
                    currentFoodItemNum = currentFoodItemNum + 1;

                    if (currentFoodItemNum >= orderedFoodItemsCount) {
                        validFoodItemSelected(itemType, true);
                    } else {
                        validFoodItemSelected(itemType, false);
                    }
                } else {
                    invalidFoodItemSelected();
                }
            }

            if (currentFoodItemNum >= orderedFoodItemsCount) {
                foodItemsClickable = false;
            }
        }
    }

    Image {
        id:           refrigeratorImage
        anchors.fill: parent
        fillMode:     Image.PreserveAspectFit
        smooth:       true
    }

    Timer {
        id:       orderIntervalTimer
        interval: 500

        onTriggered: {
            refrigerator.nextOrder();
        }
    }
}
