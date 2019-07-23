import QtQuick 2.12

Rectangle {
    id:    sandwich
    color: "transparent"

    readonly property int itemShiftPixels: 4 * sandwichScaleY

    property int maxItemsCount:            0
    property int visibleItemsCount:        0
    property int itemsInPlaceCount:        0
    property int eatenItemsCount:          0

    property real sandwichScaleX:          1.0
    property real sandwichScaleY:          1.0

    property list<SandwichItem> sandwichItems: [
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        1

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        2

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        3

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        4

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        5

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        6

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        7

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        8

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        9

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        10

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        11

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        12

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        13

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        14

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        15

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        16

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        17

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        18

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        19

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        },
        SandwichItem {
            parent:                   sandwich
            anchors.horizontalCenter: parent.horizontalCenter
            z:                        20

            onFallAnimationDone: {
                sandwich.itemsInPlaceCount = sandwich.itemsInPlaceCount + 1;
            }

            onEatAnimationDone: {
                sandwich.eatenItemsCount = sandwich.eatenItemsCount + 1;
            }
        }
    ]

    signal allItemsInPlace()
    signal allItemsEaten()

    onItemsInPlaceCountChanged: {
        if (itemsInPlaceCount === maxItemsCount - 1) {
            addItem("bread_top");
        } else if (itemsInPlaceCount === maxItemsCount) {
            allItemsInPlace();
        }
    }

    onEatenItemsCountChanged: {
        if (eatenItemsCount === maxItemsCount) {
            allItemsEaten();
        }
    }

    function newSandwich(sandwich_thickness) {
        for (var i = 0; i < visibleItemsCount; i++) {
            sandwichItems[i].clearItem();
        }

        visibleItemsCount = 0;
        itemsInPlaceCount = 0;
        eatenItemsCount   = 0;

        if (sandwich_thickness + 2 <= sandwichItems.length) {
            maxItemsCount = sandwich_thickness + 2;
        } else {
            maxItemsCount = 0;
        }

        addItem("bread_bottom");
    }

    function addItem(item_type) {
        if (visibleItemsCount < maxItemsCount) {
            sandwichItems[visibleItemsCount].itemType = item_type;
            sandwichItems[visibleItemsCount].initialY = 0;
            sandwichItems[visibleItemsCount].finalY   = height - sandwichItems[visibleItemsCount].height - itemShiftPixels * visibleItemsCount;

            sandwichItems[visibleItemsCount].dropItem();

            visibleItemsCount = visibleItemsCount + 1;
        }
    }

    function eatSandwich() {
        for (var i = 0; i < visibleItemsCount; i++) {
            sandwichItems[i].eatItem();
        }
    }
}
