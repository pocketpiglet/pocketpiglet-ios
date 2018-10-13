import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.0
import QtPurchasing 1.0

import "Core"

ApplicationWindow {
    id:                           mainWindow
    title:                        qsTr("Piglet")
    visible:                      true
    visibility:                   Window.FullScreen
    Screen.orientationUpdateMask: Qt.PortraitOrientation         | Qt.LandscapeOrientation |
                                  Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation

    property bool fullVersion:      false

    property int screenOrientation: Screen.orientation

    signal screenOrientationUpdated(int orientation)

    onFullVersionChanged: {
        setSetting("FullVersion", fullVersion ? "true" : "false");
    }

    onScreenOrientationChanged: {
        screenOrientationUpdated(screenOrientation);
    }

    function setSetting(key, value) {
        var db = LocalStorage.openDatabaseSync("PocketPigletDB", "1.0", "PocketPigletDB", 1000000);

        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS SETTINGS(KEY TEXT PRIMARY KEY, VALUE TEXT)");

            tx.executeSql("REPLACE INTO SETTINGS (KEY, VALUE) VALUES (?, ?)", [key, value]);
        });
    }

    function getSetting(key, defaultValue) {
        var value = defaultValue;
        var db    = LocalStorage.openDatabaseSync("PocketPigletDB", "1.0", "PocketPigletDB", 1000000);

        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS SETTINGS(KEY TEXT PRIMARY KEY, VALUE TEXT)");

            var res = tx.executeSql("SELECT VALUE FROM SETTINGS WHERE KEY=?", [key]);

            if (res.rows.length > 0) {
                value = res.rows.item(0).VALUE;
            }
        });

        return value;
    }

    function purchaseFullVersion() {
        fullVersionProduct.purchase();
    }

    function restorePurchases() {
        store.restorePurchases();
    }

    Store {
        id: store

        Product {
            id:         fullVersionProduct
            identifier: "pocketpiglet.version.full"
            type:       Product.Unlockable

            onPurchaseSucceeded: {
                mainWindow.fullVersion = true;

                transaction.finalize();
            }

            onPurchaseRestored: {
                mainWindow.fullVersion = true;

                transaction.finalize();
            }

            onPurchaseFailed: {
                if (transaction.failureReason === Transaction.ErrorOccurred) {
                    console.log(transaction.errorString);
                }

                transaction.finalize();
            }
        }
    }

    StackView {
        id:           mainStackView
        anchors.fill: parent

        onCurrentItemChanged: {
            for (var i = 0; i < depth; i++) {
                var item = get(i, false);

                if (item !== null) {
                    item.focus = false;

                    if (item.hasOwnProperty("pageActive")) {
                        item.pageActive = false;
                    }
                }
            }

            if (depth > 0) {
                currentItem.forceActiveFocus();

                if (currentItem.hasOwnProperty("pageActive")) {
                    currentItem.pageActive = true;
                }

                if (currentItem.hasOwnProperty("screenOrientationUpdated")) {
                    mainWindow.screenOrientationUpdated.connect(currentItem.screenOrientationUpdated);

                    mainWindow.screenOrientationUpdated(mainWindow.screenOrientation);
                }
            }
        }
    }

    PigletPage {
        id: pigletPage
    }

    MouseArea {
        id:           screenLockMouseArea
        anchors.fill: parent
        z:            100
        enabled:      mainStackView.busy
    }

    Component.onCompleted: {
        fullVersion = (getSetting("FullVersion", "false") === "true");

        mainStackView.push(pigletPage);
    }
}
