import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.LocalStorage 2.12
import QtPurchasing 1.0

ApplicationWindow {
    id:                           mainWindow
    title:                        qsTr("Piglet")
    visibility:                   Window.FullScreen
    visible:                      true
    Screen.orientationUpdateMask: Qt.PortraitOrientation         | Qt.LandscapeOrientation |
                                  Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation

    readonly property int screenOrientation: Screen.orientation

    property bool fullVersion:               false

    signal screenOrientationUpdated(int screenOrientation)

    onScreenOrientationChanged: {
        screenOrientationUpdated(screenOrientation);
    }

    onFullVersionChanged: {
        setSetting("FullVersion", fullVersion ? "true" : "false");
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
                    console.error(transaction.errorString);
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
                var item = get(i, StackView.DontLoad);

                if (item) {
                    item.focus = false;
                }
            }

            if (depth > 0) {
                currentItem.forceActiveFocus();

                if (typeof currentItem.handleScreenOrientationUpdate === "function") {
                    mainWindow.screenOrientationUpdated.connect(currentItem.handleScreenOrientationUpdate);

                    mainWindow.screenOrientationUpdated(mainWindow.screenOrientation);
                }
            }
        }
    }

    MultiPointTouchArea {
        anchors.fill: parent
        z:            1
        enabled:      mainStackView.busy
    }

    Component.onCompleted: {
        fullVersion = (getSetting("FullVersion", "false") === "true");

        var component = Qt.createComponent("Core/PigletPage.qml");

        if (component.status === Component.Ready) {
            mainStackView.push(component);
        } else {
            console.error(component.errorString());
        }
    }
}
