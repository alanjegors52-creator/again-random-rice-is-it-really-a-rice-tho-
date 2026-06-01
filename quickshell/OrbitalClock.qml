// OrbitalClock.qml — drop next to shell.qml
// Fully transparent: no background, just the clock geometry.

import QtQuick

Item {
    id: root

    // ── Config ────────────────────────────────────────────────────────────────
    property string themeMode:  "dark"           // "dark" | "light"
    property real   clockScale: height / 768     // auto-scales to parent height

    // ── Colours ───────────────────────────────────────────────────────────────
    readonly property bool  isLight:       themeMode === "light"
    readonly property color mainText:      isLight ? "#000000" : "#ffffff"
    readonly property color subColor:      isLight ? "#666666" : "#555555"
    readonly property color pillColor:     "#1a1b26"
    readonly property color pillBorder:    isLight ? "#cccccc" : "#1a1a1a"
    readonly property color pillInnerLine: isLight ? "#bbbbbb" : "#222222"

    readonly property real s: clockScale

    // ── Time ──────────────────────────────────────────────────────────────────
    property int curH:  new Date().getHours()
    property int curM:  new Date().getMinutes()
    property int curS:  new Date().getSeconds()
    property int curMS: new Date().getMilliseconds()

    readonly property real localTimeMS:
        (curH * 3600000) + (curM * 60000) + (curS * 1000) + curMS

    Timer {
        interval: 16; running: true; repeat: true
        onTriggered: {
            var d  = new Date()
            root.curH  = d.getHours()
            root.curM  = d.getMinutes()
            root.curS  = d.getSeconds()
            root.curMS = d.getMilliseconds()
        }
    }

    // ── Angles ────────────────────────────────────────────────────────────────
    readonly property real smoothSecAngle:
        -((localTimeMS % 60000)   / 60000.0)   * 360.0
    readonly property real smoothMinAngle:
        -((localTimeMS % 3600000) / 3600000.0) * 360.0

    // ── Font ──────────────────────────────────────────────────────────────────
    FontLoader { id: outfitFont; source: Qt.resolvedUrl("font/Outfit-Black.ttf") }

    // ── Clock ─────────────────────────────────────────────────────────────────
    Item {
        id: cc
        anchors.left:           parent.left
        anchors.verticalCenter: parent.verticalCenter
        width:  800 * s
        height: parent.height

        readonly property real cx:   40  * s
        readonly property real cy:   height * 0.5
        readonly property real minR: 320 * s
        readonly property real secR: 480 * s

        // Hour pill
        Rectangle {
            id: pill
            z: 1
            x: cc.cx + 230 * s;  anchors.verticalCenter: parent.verticalCenter
            width: 330 * s;  height: 90 * s;  radius: 45 * s
            color: root.pillColor;  border.color: root.pillBorder;  border.width: 1 * s
            Rectangle {
                x: 170 * s;  anchors.verticalCenter: parent.verticalCenter
                width: 1 * s;  height: 35 * s;  color: root.pillInnerLine
            }
        }

        // Hour digits
        Text {
            anchors.right:          pill.left
            anchors.rightMargin:    40 * s
            anchors.verticalCenter: parent.verticalCenter
            text: String(root.curH).padStart(2, '0')
            font.family: outfitFont.name;  font.pixelSize: 110 * s
            font.weight: Font.Black;  color: root.mainText
        }

        // Date / weekday
        Column {
            anchors.left:           pill.right
            anchors.leftMargin:     110 * s
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5 * s
            Text {
                text: Qt.formatDate(new Date(), "dd MMM yyyy").toUpperCase()
                font.family: outfitFont.name;  font.pixelSize: 13 * s
                font.letterSpacing: 4 * s;  color: root.subColor
            }
            Text {
                text: Qt.formatDate(new Date(), "dddd").toUpperCase()
                font.family: outfitFont.name;  font.pixelSize: 18 * s
                font.letterSpacing: 8 * s;  font.weight: Font.Bold
                color: root.mainText
            }
        }

        // ── Minute ring ───────────────────────────────────────────────────────
        Repeater {
            model: 60
            delegate: Item {
                z: 10
                property real base: index * 6
                property real relAngle: {
                    var a = (base + root.smoothMinAngle) % 360
                    if (a >  180) a -= 360; if (a < -180) a += 360; return a
                }
                property real spotlight: Math.max(0, 1.0 - Math.abs(relAngle) / 4.0)
                property bool isMajor:   index % 5 === 0
                property real disp: (base + root.smoothMinAngle) * Math.PI / 180
                property real tx: cc.cx + cc.minR * Math.cos(disp)
                property real ty: cc.cy + cc.minR * Math.sin(disp)
                visible: tx > -600 * s && tx < 1800 * s

                Rectangle {
                    x: parent.tx - width/2;  y: parent.ty - height/2
                    width:  isMajor ? 2*s  : 1*s;  height: isMajor ? 18*s : 10*s
                    color: root.isLight
                        ? Qt.rgba(0,0,0, spotlight>0 ? 1.0 : (isMajor?0.8:0.6))
                        : Qt.rgba(1,1,1, spotlight>0 ? 1.0 : (isMajor?0.3:0.15))
                    rotation: parent.disp * 180 / Math.PI + 90
                }
                Text {
                    visible: isMajor
                    property real nRad: cc.minR - 35*s
                    x: cc.cx + nRad*Math.cos(parent.disp) - width/2
                    y: cc.cy + nRad*Math.sin(parent.disp) - height/2
                    text: String(index).padStart(2,'0')
                    font.family: outfitFont.name;  font.pixelSize: 22*s
                    font.weight: parent.spotlight>0.5 ? Font.Bold : Font.Normal
                    color: root.isLight
                        ? Qt.rgba(0,0,0, parent.spotlight>0?(0.6+0.4*parent.spotlight):0.6)
                        : Qt.rgba(1,1,1, parent.spotlight>0?(0.4+parent.spotlight*0.6):0.25)
                    rotation: parent.disp * 180/Math.PI;  transformOrigin: Item.Center
                }
            }
        }

        // ── Second ring ───────────────────────────────────────────────────────
        Repeater {
            model: 60
            delegate: Item {
                z: 10
                property real base: index * 6
                property real relAngle: {
                    var a = (base + root.smoothSecAngle) % 360
                    if (a >  180) a -= 360; if (a < -180) a += 360; return a
                }
                property real spotlight: Math.max(0, 1.0 - Math.abs(relAngle) / 4.0)
                property bool isMajor:   index % 5 === 0
                property real disp: (base + root.smoothSecAngle) * Math.PI / 180
                property real tx: cc.cx + cc.secR * Math.cos(disp)
                property real ty: cc.cy + cc.secR * Math.sin(disp)
                visible: tx > -600 * s && tx < 1800 * s

                Rectangle {
                    x: parent.tx - width/2;  y: parent.ty - height/2
                    width:  isMajor ? 1.5*s : 1*s;  height: isMajor ? 13*s : 8*s
                    color: root.isLight
                        ? Qt.rgba(0,0,0, spotlight>0 ? 1.0 : (isMajor?0.8:0.6))
                        : Qt.rgba(1,1,1, spotlight>0 ? 1.0 : (isMajor?0.3:0.15))
                    rotation: parent.disp * 180 / Math.PI + 90
                }
                Text {
                    visible: isMajor
                    property real nRad: cc.secR - 30*s
                    x: cc.cx + nRad*Math.cos(parent.disp) - width/2
                    y: cc.cy + nRad*Math.sin(parent.disp) - height/2
                    text: String(index).padStart(2,'0')
                    font.family: outfitFont.name;  font.pixelSize: 16*s
                    font.weight: parent.spotlight>0.5 ? Font.Bold : Font.Normal
                    color: root.isLight
                        ? Qt.rgba(0,0,0, parent.spotlight>0?(0.6+0.4*parent.spotlight):0.6)
                        : Qt.rgba(1,1,1, parent.spotlight>0?(0.4+parent.spotlight*0.6):0.25)
                    rotation: parent.disp * 180/Math.PI;  transformOrigin: Item.Center
                }
            }
        }
    }
}
