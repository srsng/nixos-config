import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property bool colorize: false
    property color color
    property string source: ""
    property string iconFolder: Qt.resolvedUrl(Quickshell.shellPath("assets/icons/"))
    property string resolvedSource: (source.length > 0 && source[0] === "/") ? source : Qt.resolvedUrl(
                                                                                   iconFolder + source
                                                                                   + ".svg")

    width: 30
    height: 30

    Image {
        id: iconImage
        anchors.fill: parent
        visible: !root.colorize
        source: root.resolvedSource
        sourceSize.width: root.width
        sourceSize.height: root.height
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    ColorOverlay {
        anchors.fill: iconImage
        visible: root.colorize
        source: iconImage
        color: root.color
    }
}
