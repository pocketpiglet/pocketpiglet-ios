TARGET = PocketPiglet
VERSION = 1.2.2

TEMPLATE = app
QT += core gui declarative opengl
CONFIG += qt-components mobility
MOBILITY += sensors multimedia

SOURCES += main.cpp \
    csapplication.cpp
HEADERS += \
    csapplication.h
RESOURCES += \
    pocketpiglet.qrc
OTHER_FILES += \
    doc/help.html \
    doc/piglet.png \
    doc/shake_phone.png \
    images/piglet/action_cake.png \
    images/piglet/action_cake_disabled.png \
    images/piglet/action_candy.png \
    images/piglet/action_candy_disabled.png \
    images/piglet/game_piglet_feed.png \
    images/piglet/game_piglet_feed_highlighted.png \
    images/piglet/game_piglet_puzzle.png \
    images/piglet/game_piglet_puzzle_highlighted.png \
    images/piglet/game_piglet_wash.png \
    images/piglet/game_piglet_wash_highlighted.png \
    images/piglet/piglet_idle_meego.png \
    images/piglet/piglet_idle_symbian.png \
    images/piglet_feed/background.gif \
    images/piglet_feed/background_eat.gif \
    images/piglet_feed/complexity_easy.png \
    images/piglet_feed/complexity_hard.png \
    images/piglet_feed/complexity_medium.png \
    images/piglet_feed/complexity_selection_background.png \
    images/piglet_feed/food_cheese.png \
    images/piglet_feed/food_cucumber.png \
    images/piglet_feed/food_fish.png \
    images/piglet_feed/food_ketchup.png \
    images/piglet_feed/food_mayonnaise.png \
    images/piglet_feed/food_olives.png \
    images/piglet_feed/food_salad.png \
    images/piglet_feed/food_tomato.png \
    images/piglet_feed/refrigerator_easy.png \
    images/piglet_feed/refrigerator_hard.png \
    images/piglet_feed/refrigerator_medium.png \
    images/piglet_feed/sandwich_bread_bottom.png \
    images/piglet_feed/sandwich_bread_top.png \
    images/piglet_feed/sandwich_cheese.png \
    images/piglet_feed/sandwich_cucumber.png \
    images/piglet_feed/sandwich_fish.png \
    images/piglet_feed/sandwich_ketchup.png \
    images/piglet_feed/sandwich_mayonnaise.png \
    images/piglet_feed/sandwich_olives.png \
    images/piglet_feed/sandwich_salad.png \
    images/piglet_feed/sandwich_tomato.png \
    images/piglet_puzzle/complexity_hard.png \
    images/piglet_puzzle/complexity_medium.png \
    images/piglet_puzzle/complexity_selection_background.png \
    images/piglet_puzzle/puzzle_selection_background.png \
    images/piglet_wash/background_0_missed.gif \
    images/piglet_wash/background_1_missed.gif \
    images/piglet_wash/background_2_missed.gif \
    images/piglet_wash/background_3_missed.gif \
    images/piglet_wash/bubble_1.png \
    images/piglet_wash/bubble_2.png \
    images/piglet_wash/bubble_3.png \
    images/piglet_wash/bubble_bursted.png \
    images/piglet_wash/missed_bubble.png \
    images/piglet_wash/missed_bubble_grayed.png \
    images/piglet_wash/missed_bubble_red.png \
    images/piglet_wash/missed_bubbles_background.png \
    images/background.png \
    images/busy_indicator.png \
    images/dialog_info.png \
    images/dialog_question.png \
    images/exit.png \
    images/game_pause.png \
    images/help.png \
    images/ok.png \
    images/refresh.png \
    icon.png \
    icon.svg

symbian: {
    DEFINES += SYMBIAN_TARGET

    #TARGET.UID3 = 0xE0EC60F9
    TARGET.UID3 = 0x2004B226
    TARGET.EPOCSTACKSIZE = 0x14000
    TARGET.EPOCHEAPSIZE = 0x020000 0x8000000
    TARGET.CAPABILITY += ReadDeviceData

    ICON = icon.svg

    # SIS header: name, uid, version
    packageheader = "$${LITERAL_HASH}{\"PocketPiglet\"}, (0x2004B226), 1, 2, 1, TYPE=SA"
    # Vendor info: localised and non-localised vendor names
    vendorinfo = "%{\"Oleg Derevenetz\"}" ":\"Oleg Derevenetz\""

    my_deployment.pkg_prerules = packageheader vendorinfo
    DEPLOYMENT += my_deployment

    # SIS installer header: uid
    DEPLOYMENT.installer_header = 0x2002CCCF
}

contains(MEEGO_EDITION,harmattan) {
    DEFINES += MEEGO_TARGET

    target.path = /opt/pocketpiglet/bin

    launchericon.files = pocketpiglet.svg
    launchericon.path = /usr/share/themes/base/meegotouch/icons/

    INSTALLS += target launchericon
}

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# QML deployment
folder_qml.source = qml/pocketpiglet
folder_qml.target = qml
DEPLOYMENTFOLDERS = folder_qml

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

contains(MEEGO_EDITION,harmattan) {
    desktopfile.files = pocketpiglet.desktop
    desktopfile.path = /usr/share/applications
    INSTALLS += desktopfile
}
