import QtQuick 2.12

MultiPointTouchArea {
    id:               purchaseDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    property bool enableGetDiamondsButton: true

    signal opened()
    signal closed()

    signal getDiamondsSelected()
    signal purchaseFullVersionSelected()
    signal restorePurchasesSelected()
    signal cancelled()

    function dialogWidth(rotation, parent_width, parent_height) {
        if (rotation === 90 || rotation === 270) {
            return parent_height;
        } else {
            return parent_width;
        }
    }

    function dialogHeight(rotation, parent_width, parent_height) {
        if (rotation === 90 || rotation === 270) {
            return parent_width;
        } else {
            return parent_height;
        }
    }

    function open(enable_get_diamonds_button) {
        visible                 = true;
        enableGetDiamondsButton = enable_get_diamonds_button;

        opened();
    }

    function close() {
        visible = false;

        cancelled();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        source:           "qrc:/resources/images/dialog/purchase_dialog.png"

        Column {
            anchors.centerIn: parent
            spacing:          8

            Image {
                id:     getDiamondsButtonImage
                source: purchaseDialog.enableGetDiamondsButton ? "qrc:/resources/images/dialog/purchase_dialog_button.png" :
                                                                 "qrc:/resources/images/dialog/purchase_dialog_button_disabled.png"

                MouseArea {
                    anchors.fill: parent
                    enabled:      purchaseDialog.enableGetDiamondsButton

                    onClicked: {
                        purchaseDialog.visible = false;

                        purchaseDialog.getDiamondsSelected();
                        purchaseDialog.closed();
                    }
                }

                Row {
                    anchors.fill: parent
                    leftPadding:  4
                    rightPadding: 4
                    spacing:      4

                    Image {
                        id:                     getDiamondsImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - 8
                        source:                 purchaseDialog.enableGetDiamondsButton ? "qrc:/resources/images/dialog/purchase_dialog_get_diamonds.png" :
                                                                                         "qrc:/resources/images/dialog/purchase_dialog_get_diamonds_disabled.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - getDiamondsImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - 8
                        text:                   qsTr("Get diamonds")
                        color:                  "black"
                        font.pointSize:         16
                        font.family:            "Helvetica"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        fontSizeMode:           Text.Fit
                        minimumPointSize:       8
                    }
                }
            }

            Image {
                id:     purchaseFullVersionButtonImage
                source: "qrc:/resources/images/dialog/purchase_dialog_button.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        purchaseDialog.visible = false;

                        purchaseDialog.purchaseFullVersionSelected();
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
                        text:                   qsTr("Purchase full version")
                        color:                  "black"
                        font.pointSize:         16
                        font.family:            "Helvetica"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        fontSizeMode:           Text.Fit
                        minimumPointSize:       8
                    }
                }
            }

            Image {
                id:     restorePurchasesButtonImage
                source: "qrc:/resources/images/dialog/purchase_dialog_button.png"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        purchaseDialog.visible = false;

                        purchaseDialog.restorePurchasesSelected();
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
                        text:                   qsTr("Restore purchases")
                        color:                  "black"
                        font.pointSize:         16
                        font.family:            "Helvetica"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        fontSizeMode:           Text.Fit
                        minimumPointSize:       8
                    }
                }
            }
        }
    }

    Image {
        id:                       cancelButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        z:                        1
        width:                    64
        height:                   64
        source:                   "qrc:/resources/images/dialog/cancel.png"
        fillMode:                 Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent

            onClicked: {
                purchaseDialog.visible = false;

                purchaseDialog.cancelled();
                purchaseDialog.closed();
            }
        }
    }
}
