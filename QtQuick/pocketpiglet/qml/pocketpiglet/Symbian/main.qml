import QtQuick 1.1
import com.nokia.symbian 1.0

import "Core"

import "Settings.js" as SettingsScript

Window {
    id: mainWindow

    property string targetPlatform: "symbian"

    function setSetting(key, value) {
        SettingsScript.setSetting(key, value);
    }

    function getSetting(key, defaultValue) {
        return SettingsScript.getSetting(key, defaultValue);
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        PageStack {
            id:           mainPageStack
            anchors.fill: parent
        }

        PigletPage {
            id: pigletPage
        }

        PigletFeedPage {
            id: pigletFeedPage
        }

        PigletWashPage {
            id: pigletWashPage
        }

        PigletPuzzlePage {
            id: pigletPuzzlePage
        }

        HelpPage {
            id: helpPage
        }

        MouseArea {
            id:           screenLockMouseArea
            anchors.fill: parent
            z:            100
            enabled:      mainPageStack.busy
        }
    }

    Component.onCompleted: {
        mainPageStack.push(pigletPage);
    }
}
