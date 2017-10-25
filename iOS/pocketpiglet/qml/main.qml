import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.0

import "Core"

ApplicationWindow {
    id:                           mainWindow
    visible:                      true
    visibility:                   Window.FullScreen
    Screen.orientationUpdateMask: Qt.PortraitOrientation         | Qt.LandscapeOrientation |
                                  Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation

    property int screenOrientation: Screen.orientation

    signal screenOrientationUpdated(int orientation)

    onScreenOrientationChanged: {
        screenOrientationUpdated(screenOrientation);
    }

    function setSetting(key, value) {
        var db = LocalStorage.openDatabaseSync("PocketPigletDB", "1.0", "PocketPigletDB", 1000000);

        db.transaction(
                    function(tx) {
                        tx.executeSql("REPLACE INTO SETTINGS (KEY, VALUE) VALUES (?, ?)", [key, value]);
                    }
        );
    }

    function getSetting(key, defaultValue) {
        var value = defaultValue;
        var db    = LocalStorage.openDatabaseSync("PocketPigletDB", "1.0", "PocketPigletDB", 1000000);

        db.transaction(
                    function(tx) {
                        tx.executeSql("CREATE TABLE IF NOT EXISTS SETTINGS(KEY TEXT PRIMARY KEY, VALUE TEXT)");

                        var res = tx.executeSql("SELECT VALUE FROM SETTINGS WHERE KEY=?", [key]);

                        if (res.rows.length !== 0) {
                            value = res.rows.item(0).VALUE;
                        }
                    }
        );

        return value;
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

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
                    get(depth - 1).forceActiveFocus();

                    if (item.hasOwnProperty("pageActive")) {
                        item.pageActive = true;
                    }

                    if (item.hasOwnProperty("screenOrientationUpdated")) {
                        mainWindow.screenOrientationUpdated.connect(item.screenOrientationUpdated);

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
    }

    Component.onCompleted: {
        AdMobHelper.initialize();

        mainStackView.push(pigletPage);
    }
}
