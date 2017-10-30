import QtQuick 2.9

MouseArea {
    id:               purchaseDialog
    anchors.centerIn: parent
    visible:          false

    property bool enableWatchVideoButton: true

    property int parentWidth:             parent.width
    property int parentHeight:            parent.height

    signal opened()
    signal closed()

    signal watchVideo()
    signal purchaseFullVersion()
    signal restorePurchases()
    signal cancel()

    onParentWidthChanged: {
        if (typeof(parent) !== "undefined" && parent !== null) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    onParentHeightChanged: {
        if (typeof(parent) !== "undefined" && parent !== null) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    onRotationChanged: {
        if (typeof(parent) !== "undefined" && parent !== null) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    function open(enable_watch_video_button) {
        visible                = true;
        enableWatchVideoButton = enable_watch_video_button;

        opened();
    }

    function close() {
        visible = false;

        cancel();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        width:            Math.min(parent.width, parent.height) - 16
        height:           Math.min(parent.width, parent.height) - 72
        source:           "qrc:/resources/images/dialog/purchase_dialog.png"
        fillMode:         Image.PreserveAspectFit

        property bool geometrySettled: false

        onPaintedWidthChanged: {
            if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                geometrySettled = true;

                width  = paintedWidth;
                height = paintedHeight;
            }
        }

        onPaintedHeightChanged: {
            if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                geometrySettled = true;

                width  = paintedWidth;
                height = paintedHeight;
            }
        }

        Column {
            anchors.centerIn: parent
            spacing:          8

            Image {
                id:       watchVideoButtonImage
                width:    dialogImage.width  - 16
                height:   dialogImage.height - 16
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

                property bool geometrySettled: false

                onPaintedWidthChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width  = paintedWidth;
                        height = paintedHeight;
                    }
                }

                onPaintedHeightChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width  = paintedWidth;
                        height = paintedHeight;
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled:      purchaseDialog.enableWatchVideoButton

                    onClicked: {
                        purchaseDialog.visible = false;

                        purchaseDialog.watchVideo();
                        purchaseDialog.closed();
                    }
                }

                Row {
                    anchors.fill: parent
                    leftPadding:  4
                    rightPadding: 4
                    spacing:      4

                    Image {
                        id:                     watchVideoImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - 8
                        source:                 "qrc:/resources/images/dialog/purchase_dialog_watch.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - watchVideoImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - 8
                        clip:                   true
                        color:                  "black"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        text:                   qsTr("Watch the video")
                    }
                }
            }

            Image {
                id:       purchaseFullVersionButtonImage
                width:    dialogImage.width  - 16
                height:   dialogImage.height - 16
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

                property bool geometrySettled: false

                onPaintedWidthChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width  = paintedWidth;
                        height = paintedHeight;
                    }
                }

                onPaintedHeightChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width  = paintedWidth;
                        height = paintedHeight;
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        purchaseDialog.visible = false;

                        purchaseDialog.purchaseFullVersion();
                        purchaseDialog.closed();
                    }
                }

                Row {
                    anchors.fill: parent
                    leftPadding:  4
                    rightPadding: 4
                    spacing:      4

                    Image {
                        id:                     purchaseFullVersionImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - 8
                        source:                 "qrc:/resources/images/dialog/purchase_dialog_purchase.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - purchaseFullVersionImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - 8
                        clip:                   true
                        color:                  "black"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        text:                   qsTr("Purchase full version")
                    }
                }
            }

            Image {
                id:       restorePurchasesButtonImage
                width:    dialogImage.width  - 16
                height:   dialogImage.height - 16
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

                property bool geometrySettled: false

                onPaintedWidthChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width  = paintedWidth;
                        height = paintedHeight;
                    }
                }

                onPaintedHeightChanged: {
                    if (!geometrySettled && width > 0 && height > 0 && paintedWidth > 0 && paintedHeight > 0) {
                        geometrySettled = true;

                        width  = paintedWidth;
                        height = paintedHeight;
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        purchaseDialog.visible = false;

                        purchaseDialog.restorePurchases();
                        purchaseDialog.closed();
                    }
                }

                Row {
                    anchors.fill: parent
                    leftPadding:  4
                    rightPadding: 4
                    spacing:      4

                    Image {
                        id:                     restorePurchasesImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - 8
                        source:                 "qrc:/resources/images/dialog/purchase_dialog_restore.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - restorePurchasesImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - 8
                        clip:                   true
                        color:                  "black"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        text:                   qsTr("Restore purchases")
                    }
                }
            }
        }
    }

    Image {
        id:                       cancelButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        width:                    64
        height:                   64
        z:                        dialogImage.z + 1
        source:                   "qrc:/resources/images/dialog/cancel.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                purchaseDialog.visible = false;

                purchaseDialog.cancel();
                purchaseDialog.closed();
            }
        }
    }
}
