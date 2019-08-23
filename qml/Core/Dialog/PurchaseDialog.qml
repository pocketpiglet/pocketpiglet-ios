import QtQuick 2.12

import "../../Util.js" as UtilScript

MultiPointTouchArea {
    id:               purchaseDialog
    anchors.centerIn: parent
    width:            dialogWidth(rotation, parent.width, parent.height)
    height:           dialogHeight(rotation, parent.width, parent.height)
    visible:          false

    readonly property int diamondsDeliveryInterval: 300
    readonly property int diamondsForDelivery:      5

    property bool enableGetFreeDiamondsButton:      true

    property double nextDiamondsDeliveryTime:       0.0

    signal opened()
    signal closed()

    signal getFreeDiamondsSelected(int deliveredAmount)
    signal purchaseFullVersionSelected()
    signal restorePurchasesSelected()
    signal cancelled()

    onNextDiamondsDeliveryTimeChanged: {
        mainWindow.setSetting("PurchaseNextDiamondsDeliveryTime", nextDiamondsDeliveryTime.toString(10));
    }

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

    function open(enable_get_free_diamonds_button) {
        visible                     = true;
        enableGetFreeDiamondsButton = enable_get_free_diamonds_button;

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
        width:            UtilScript.pt(sourceSize.width)
        height:           UtilScript.pt(sourceSize.height)
        source:           "qrc:/resources/images/dialog/purchase_dialog.png"
        fillMode:         Image.PreserveAspectFit

        Column {
            anchors.centerIn: parent
            spacing:          UtilScript.pt(8)

            Image {
                id:       getFreeDiamondsButtonImage
                width:    UtilScript.pt(sourceSize.width)
                height:   UtilScript.pt(sourceSize.height)
                source:   enabled ? "qrc:/resources/images/dialog/purchase_dialog_button.png" :
                                    "qrc:/resources/images/dialog/purchase_dialog_button_disabled.png"
                fillMode: Image.PreserveAspectFit
                enabled:  purchaseDialog.enableGetFreeDiamondsButton && countdownTimer.countdownTime <= 0

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        purchaseDialog.nextDiamondsDeliveryTime = (new Date()).getTime() + purchaseDialog.diamondsDeliveryInterval * 1000;

                        purchaseDialog.visible = false;

                        purchaseDialog.getFreeDiamondsSelected(purchaseDialog.diamondsForDelivery);
                        purchaseDialog.closed();
                    }
                }

                Row {
                    anchors.fill: parent
                    leftPadding:  UtilScript.pt(4)
                    rightPadding: UtilScript.pt(4)
                    spacing:      UtilScript.pt(4)

                    Image {
                        id:                     getFreeDiamondsImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - UtilScript.pt(8)
                        source:                 getFreeDiamondsButtonImage.enabled ? "qrc:/resources/images/dialog/purchase_dialog_get_free_diamonds.png" :
                                                                                     "qrc:/resources/images/dialog/purchase_dialog_get_free_diamonds_disabled.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - getFreeDiamondsImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - UtilScript.pt(8)
                        text:                   textText(countdownTimer.countdownTime)
                        color:                  "black"
                        font.pointSize:         16
                        font.family:            "Helvetica"
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        wrapMode:               Text.Wrap
                        fontSizeMode:           Text.Fit
                        minimumPointSize:       8

                        function textText(countdown_time) {
                            if (countdown_time > 0) {
                                var hrs = Math.floor(countdown_time / 1000 / 3600).toString(10);
                                var mns = Math.floor((countdown_time / 1000 - hrs * 3600) / 60).toString(10);
                                var scs = Math.floor(countdown_time / 1000 - hrs * 3600 - mns * 60).toString(10);

                                if (hrs.length < 2) {
                                    hrs = "0" + hrs;
                                }
                                if (mns.length < 2) {
                                    mns = "0" + mns;
                                }
                                if (scs.length < 2) {
                                    scs = "0" + scs;
                                }

                                if (hrs === "00") {
                                    return "%1:%2".arg(mns).arg(scs);
                                } else {
                                    return "%1:%2:%3".arg(hrs).arg(mns).arg(scs);
                                }
                            } else {
                                return qsTr("Get free diamonds");
                            }
                        }
                    }
                }
            }

            Image {
                id:       purchaseFullVersionButtonImage
                width:    UtilScript.pt(sourceSize.width)
                height:   UtilScript.pt(sourceSize.height)
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

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
                    leftPadding:  UtilScript.pt(4)
                    rightPadding: UtilScript.pt(4)
                    spacing:      UtilScript.pt(4)

                    Image {
                        id:                     purchaseFullVersionImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - UtilScript.pt(8)
                        source:                 "qrc:/resources/images/dialog/purchase_dialog_purchase.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - purchaseFullVersionImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - UtilScript.pt(8)
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
                id:       restorePurchasesButtonImage
                width:    UtilScript.pt(sourceSize.width)
                height:   UtilScript.pt(sourceSize.height)
                source:   "qrc:/resources/images/dialog/purchase_dialog_button.png"
                fillMode: Image.PreserveAspectFit

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
                    leftPadding:  UtilScript.pt(4)
                    rightPadding: UtilScript.pt(4)
                    spacing:      UtilScript.pt(4)

                    Image {
                        id:                     restorePurchasesImage
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  sourceSize.width * (height / sourceSize.height)
                        height:                 parent.height - UtilScript.pt(8)
                        source:                 "qrc:/resources/images/dialog/purchase_dialog_restore.png"
                        fillMode:               Image.PreserveAspectFit
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width - restorePurchasesImage.width - parent.spacing -
                                                parent.leftPadding - parent.rightPadding
                        height:                 parent.height - UtilScript.pt(8)
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
        width:                    UtilScript.pt(64)
        height:                   UtilScript.pt(64)
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

    Timer {
        id:       countdownTimer
        running:  true
        interval: 1000
        repeat:   true

        property double countdownTime: timerCountdownTime(purchaseDialog.nextDiamondsDeliveryTime)

        onTriggered: {
            countdownTime = timerCountdownTime(purchaseDialog.nextDiamondsDeliveryTime);
        }

        function timerCountdownTime(next_diamonds_delivery_time) {
            var current_time = (new Date()).getTime();

            if (next_diamonds_delivery_time >= current_time) {
                return next_diamonds_delivery_time - current_time;
            } else {
                return 0;
            }
        }
    }

    Component.onCompleted: {
        nextDiamondsDeliveryTime = parseFloat(mainWindow.getSetting("PurchaseNextDiamondsDeliveryTime", "0"));
    }
}
