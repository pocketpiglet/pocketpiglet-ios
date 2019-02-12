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
        width:            calculateWidth (sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        height:           calculateHeight(sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        source:           "qrc:/resources/images/dialog/purchase_dialog.png"
        fillMode:         Image.PreserveAspectFit

        function calculateWidth(src_width, src_height, dst_width, dst_height) {
            if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                if (dst_width / dst_height > src_width / src_height) {
                    return src_width * dst_height / src_height;
                } else {
                    return dst_width;
                }
            } else {
                return 0;
            }
        }

        function calculateHeight(src_width, src_height, dst_width, dst_height) {
            if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                if (dst_width / dst_height > src_width / src_height) {
                    return dst_height;
                } else {
                    return src_height * dst_width / src_width;
                }
            } else {
                return 0;
            }
        }

        Column {
            anchors.centerIn: parent
            spacing:          8

            Image {
                id:       watchVideoButtonImage
                width:    calculateWidth (sourceSize.width, sourceSize.height, dialogImage.width - 24, dialogImage.height - 24)
                height:   calculateHeight(sourceSize.width, sourceSize.height, dialogImage.width - 24, dialogImage.height - 24)
                source:   purchaseDialog.enableWatchVideoButton ? "qrc:/resources/images/dialog/purchase_dialog_button.png" :
                                                                  "qrc:/resources/images/dialog/purchase_dialog_button_disabled.png"
                fillMode: Image.PreserveAspectFit

                function calculateWidth(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height > src_width / src_height) {
                            return src_width * dst_height / src_height;
                        } else {
                            return dst_width;
                        }
                    } else {
                        return 0;
                    }
                }

                function calculateHeight(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height > src_width / src_height) {
                            return dst_height;
                        } else {
                            return src_height * dst_width / src_width;
                        }
                    } else {
                        return 0;
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
                        source:                 purchaseDialog.enableWatchVideoButton ? "qrc:/resources/images/dialog/purchase_dialog_watch.png" :
                                                                                        "qrc:/resources/images/dialog/purchase_dialog_watch_disabled.png"
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
                        text:                   qsTr("Watch video ad")
                    }
                }
            }

            Image {
                id:       purchaseFullVersionButtonImage
                width:    calculateWidth (sourceSize.width, sourceSize.height, dialogImage.width - 24, dialogImage.height - 24)
                height:   calculateHeight(sourceSize.width, sourceSize.height, dialogImage.width - 24, dialogImage.height - 24)
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

                function calculateWidth(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height > src_width / src_height) {
                            return src_width * dst_height / src_height;
                        } else {
                            return dst_width;
                        }
                    } else {
                        return 0;
                    }
                }

                function calculateHeight(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height > src_width / src_height) {
                            return dst_height;
                        } else {
                            return src_height * dst_width / src_width;
                        }
                    } else {
                        return 0;
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
                width:    calculateWidth (sourceSize.width, sourceSize.height, dialogImage.width - 24, dialogImage.height - 24)
                height:   calculateHeight(sourceSize.width, sourceSize.height, dialogImage.width - 24, dialogImage.height - 24)
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

                function calculateWidth(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height > src_width / src_height) {
                            return src_width * dst_height / src_height;
                        } else {
                            return dst_width;
                        }
                    } else {
                        return 0;
                    }
                }

                function calculateHeight(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height > src_width / src_height) {
                            return dst_height;
                        } else {
                            return src_height * dst_width / src_width;
                        }
                    } else {
                        return 0;
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
