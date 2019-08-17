function createBubbles(count) {
    var component = Qt.createComponent("PigletWash/Bubble.qml");

    for (var i = 0; i < count; i++) {
        var bubble = component.createObject(backgroundRectangle, {"z": 5});

        bubble.bubbleBursted.connect(handleBubbleBurst);
        bubble.bubbleMissed.connect(handleBubbleMiss);
        bubble.bubbleDestroyed.connect(handleBubbleDestruction);

        pigletWashPage.bubbleCleanupRequested.connect(bubble.destroyBubble);

        pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount + 1;
    }
}

function handleBubbleBurst() {
    pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount - 1;
    pigletWashPage.burstedBubblesCount = pigletWashPage.burstedBubblesCount + 1;
}

function handleBubbleMiss() {
    pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount - 1;
    pigletWashPage.missedBubblesCount  = pigletWashPage.missedBubblesCount  + 1;
}

function handleBubbleDestruction() {
    pigletWashPage.visibleBubblesCount = pigletWashPage.visibleBubblesCount - 1;
}
