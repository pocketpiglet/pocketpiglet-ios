function createBubbles(count) {
    var component = Qt.createComponent("PigletWash/Bubble.qml");

    for (var i = 0; i < count; i++) {
        var bubble = component.createObject(backgroundRectangle, {"z": 5});

        bubble.bubbleBursted.connect(bubbleBursted);
        bubble.bubbleMissed.connect(bubbleMissed);
        bubble.bubbleDestroyed.connect(bubbleDestroyed);

        pigletWashPage.destroyBubbles.connect(bubble.destroyBubble);

        pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount + 1;
    }
}

function bubbleBursted() {
    pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount - 1;
    pigletWashPage.burstedBubblesCount = pigletWashPage.burstedBubblesCount + 1;
}

function bubbleMissed() {
    pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount - 1;
    pigletWashPage.missedBubblesCount  = pigletWashPage.missedBubblesCount  + 1;
}

function bubbleDestroyed() {
    pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount - 1;
}
