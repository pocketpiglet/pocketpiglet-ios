import QtQuick 2.9

MouseArea {
    id:               notificationDialog
    anchors.centerIn: parent
    visible:          false

    property int parentWidth:  parent.width
    property int parentHeight: parent.height

    property string text:      ""

    signal opened()
    signal closed()

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

    function open() {
        visible = true;

        opened();
    }

    function close() {
        visible = false;

        closed();
    }

    Image {
        anchors.centerIn: parent
        width:            calculateWidth (sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        height:           calculateHeight(sourceSize.width, sourceSize.height, parent.width - 72, parent.height - 72)
        source:           "qrc:/resources/images/dialog/dialog.png"
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

        Text {
            anchors.fill:        parent
            anchors.margins:     16
            clip:                true
            color:               "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            wrapMode:            Text.Wrap
            text:                notificationDialog.text
        }
    }
}
