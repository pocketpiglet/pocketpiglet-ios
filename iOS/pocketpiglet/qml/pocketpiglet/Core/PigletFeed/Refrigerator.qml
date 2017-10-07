import QtQuick 2.9

import "Refrigerator.js" as RefrigeratorScript

Rectangle {
    id:     refrigerator
    width:  refrigeratorImage.sourceSize.width  * pigletFeedPage.screenFactorX
    height: refrigeratorImage.sourceSize.height * pigletFeedPage.screenFactorY
    color:  "transparent"

    property bool foodItemsClickable:   false

    property int currentFoodItemNum:    0
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:            fishFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 156 * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 20  * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "fish"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
            }
        },
        FoodItem {
            id:            cucumberFoodItemHard
            parent:        refrigerator
            x:             pigletFeedPage.screenDeltaX + 20  * pigletFeedPage.screenFactorX
            y:             pigletFeedPage.screenDeltaY + 100 * pigletFeedPage.screenFactorY
            z:             refrigerator.z + 1
            visible:       refrigerator.refrigeratorType === "hard"
            itemClickable: refrigerator.foodItemsClickable
            itemType:      "cucumber"

            onItemClicked: {
                refrigerator.validateSelectedFoodItem(itemType);
            }

            onHideAnimationDone: {
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
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
                orderIntervalTimer.start();
            }
        }
    ]

    signal validFoodItemSelected(string item_type, bool last_item)
    signal invalidFoodItemSelected()

    onRefrigeratorTypeChanged: {
        if (refrigeratorType === "easy") {
            refrigeratorImage.source = "qrc:/resources/images/piglet_feed/refrigerator_easy.png";
        } else if (refrigeratorType === "medium") {
            refrigeratorImage.source = "qrc:/resources/images/piglet_feed/refrigerator_medium.png";
        } else if (refrigeratorType === "hard") {
            refrigeratorImage.source = "qrc:/resources/images/piglet_feed/refrigerator_hard.png";
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

    function beginOrder(items_to_order) {
        foodItemsClickable    = false;
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