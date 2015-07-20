import QtQuick 2.2
import QtFeedback 5.0
import Ubuntu.Components 1.1

Item {
    id: bottomEdge
    
    property int hintSize: units.gu(8)
    property color hintColor: Theme.palette.normal.overlay
    property string hintIconName: "view-grid-symbolic"
    property alias hintIconSource: hintIcon.source
    property color hintIconColor: UbuntuColors.coolGrey
    property bool bottomEdgeEnabled: true

    property int expandAngle: 360
    property real expandedPosition: (0.85 - 0.45 * expandAngle/360) * height
    property real collapsedPosition: height - hintSize/2

    property real actionButtonSize: units.gu(7)
    property real actionButtonDistance: 1.5* hintSize

    anchors.fill: parent

    HapticsEffect {
        id: clickEffect
        attackIntensity: 0.0
        attackTime: 50
        intensity: 1.0
        duration: 10
        fadeTime: 50
        fadeIntensity: 0.0
    }

    /*Rectangle {
        id: bgVisual
        
        z: 10
        color: "black"
        //anchors.fill: parent
        width: parent.width
        height: parent.height/2*3
        y: bottomEdgeHint.y
        opacity: 0.0
    }*/
    Rectangle {
        width: parent.width
        height: parent.height/2*3
        color: Theme.palette.normal.background
        y: bottomEdgeHint.y + bottomEdgeHint.height/2
        Rectangle {
            id: dropShadowSlide
            width: parent.width
            height: parent.height
            border.color: "#B3B3B3"
            color: Theme.palette.normal.background
            radius: parent.radius
            z: -1
            anchors {
                centerIn: parent
                verticalCenterOffset: units.gu(-0.3)
            }
        }

        Flow {
            id: informationRow;
            //y: 7*mainView.pageHeight/10;
            //width: mainView.pageWidth - units.dp(8);
            //anchors.horizontalCenter: parent.horizontalCenter
            /*x: !mainView.wideAspect() ? 0.5*(mainView.width - width) :
                                        0.25*(mainView.width-9*sudokuBlocksGrid.blockSize-
                                              22*sudokuBlocksGrid.blockDistance)+9*sudokuBlocksGrid.blockSize + 35*sudokuBlocksGrid.blockDistance + units.gu(2)

                                              */
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: units.gu(6)
            anchors.leftMargin: units.gu(4)
            /*anchors.topMargin: !mainView.wideAspect() ?
                                   9*sudokuBlocksGrid.blockSize + 35*sudokuBlocksGrid.blockDistance :
                                   mainView.height*0.15
*/
            //columns: !wideAspect ? 3 : 1
            flow: mainView.wideAspect() ? Flow.LeftToRight : Flow.TopToBottom
            spacing: mainView.width/mainView.height < mainView.resizeFactor ? units.gu(4) : units.gu(50)/6
            Row {
                spacing: units.gu(4)
                Rectangle {
                    id: redFlag
                    color: sudokuBlocksGrid.defaultNotAllowedColor
                    width: units.gu(5)
                    height: width
                    //border.color: defaultBorderColor
                    //radius: "medium"
                    Label {
                        id: redFlagText
                        text: i18n.tr("4")
                        fontSize: "large"
                        font.bold: true
                        color: "white"
                        width:units.gu(5);
                        wrapMode: TextEdit.WordWrap;
                        horizontalAlignment: Text.AlignHCenter
                        anchors.centerIn: parent
                        //                                    anchors.left: redFlag.right;
                        //                                    anchors.leftMargin: units.dp(2);
                        //                                    anchors.verticalCenter: redFlag.verticalCenter;
                    }
                }
                Label {
                    text: i18n.tr("Not allowed")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(4)
                Rectangle {
                    id: blueFlag
                    color: "#dcdcd5"
                    //border.color: defaultBorderColor
                    width: units.gu(5)
                    height: width
                    //radius: "medium";
                    Label {
                        id: blueFlagText
                        text: i18n.tr("4")
                        fontSize: "large"
                        color: sudokuBlocksGrid.defaultStartingColor
                        font.bold: true
                        width:units.gu(5);
                        wrapMode: TextEdit.WordWrap;
                        horizontalAlignment: Text.AlignHCenter
                        anchors.centerIn: parent
                        //                                    anchors.left: blueFlag.right;
                        //                                    anchors.leftMargin: units.dp(2);
                        //                                    anchors.verticalCenter: blueFlag.verticalCenter;
                    }
                }
                Label {
                    text: i18n.tr("Start blocks")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(4)
                Rectangle {
                    id: orangeFlag
                    color: "#dcdcd5"
                    //border.color: defaultBorderColor
                    width: units.gu(5)
                    height: width
                    //radius: "medium";
                    Label {
                        text: i18n.tr("4")
                        fontSize: "large"
                        color: sudokuBlocksGrid.defaultHintColor
                        font.bold: true
                        width:units.gu(5);
                        wrapMode: TextEdit.WordWrap;
                        horizontalAlignment: Text.AlignHCenter
                        anchors.centerIn: parent
                        //                                    anchors.left: orangeFlag.right;
                        //                                    anchors.leftMargin: units.dp(2);
                        //                                    anchors.verticalCenter: orangeFlag.verticalCenter;
                    }
                }
                Label {
                    text: i18n.tr("Hinted blocks")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

    }
    
    Rectangle {
        id: bottomEdgeHint

        color: hintColor
        width: hintSize
        height: width
        radius: units.gu(2)//width/2
        visible: bottomEdgeEnabled

        anchors.horizontalCenter: parent.horizontalCenter
        y: collapsedPosition
        z: parent.z + 1

        Rectangle {
            id: dropShadow
            width: parent.width
            height: parent.height
            border.color: "#B3B3B3"
            color: Theme.palette.normal.background
            radius: parent.radius
            z: -1
            anchors {
                centerIn: parent
                verticalCenterOffset: units.gu(-0.3)
            }
        }
        
        Icon {
            id: hintIcon
            width: hintSize/4
            height: width
            name: hintIconName
            color: hintIconColor
            anchors {
                centerIn: parent
                verticalCenterOffset: width * ((bottomEdgeHint.y - expandedPosition)
                                               /(expandedPosition - collapsedPosition))
            }
        }

        property real actionListDistance: -actionButtonDistance * ((bottomEdgeHint.y - collapsedPosition)
                                                                   /(collapsedPosition - expandedPosition))

        MouseArea {
            id: mouseArea
            
            property real previousY: -1
            property string dragDirection: "None"
            
            z: 1
            anchors.fill: parent
            visible: bottomEdgeEnabled
            
            preventStealing: true
            drag {
                axis: Drag.YAxis
                target: bottomEdgeHint
                minimumY: expandedPosition
                maximumY: collapsedPosition
            }
            
            onReleased: {
                if ((dragDirection === "BottomToTop") &&
                        bottomEdgeHint.y < collapsedPosition) {
                    bottomEdgeHint.state = "expanded"
                } else {
                    if (bottomEdgeHint.state === "collapsed") {
                        bottomEdgeHint.y = collapsedPosition
                    }
                    bottomEdgeHint.state = "collapsed"
                }
                previousY = -1
                dragDirection = "None"
            }

            onClicked: {
                if (bottomEdgeHint.y === collapsedPosition)
                    bottomEdgeHint.state = "expanded"
                else
                    bottomEdgeHint.state = "collapsed"
            }
            
            onPressed: {
                previousY = bottomEdgeHint.y
            }
            
            onMouseYChanged: {
                var yOffset = previousY - bottomEdgeHint.y
                if (Math.abs(yOffset) <= units.gu(2)) {
                    return
                }
                previousY = bottomEdgeHint.y
                dragDirection = yOffset > 0 ? "BottomToTop" : "TopToBottom"
            }
        }
        
        state: "collapsed"
        states: [
            State {
                name: "collapsed"
                PropertyChanges {
                    target: bottomEdgeHint
                    y: collapsedPosition
                }
                PropertyChanges {
                    target: hintIcon
                    width: hintSize/4
                }
            },
            State {
                name: "expanded"
                PropertyChanges {
                    target: bottomEdgeHint
                    y: expandedPosition
                }
                PropertyChanges {
                    target: hintIcon
                    width: hintSize/2
                }
            },
            
            State {
                name: "floating"
                when: mouseArea.drag.active
            }
        ]
        
        transitions: [
            Transition {
                to: "expanded"
                SpringAnimation {
                    target: bottomEdgeHint
                    property: "y"
                    spring: 2
                    damping: 0.2
                }
                SpringAnimation {
                    target: hintIcon
                    property: "width"
                    spring: 2
                    damping: 0.2
                }
            },
            
            Transition {
                to: "collapsed"
                SmoothedAnimation {
                    target: bottomEdgeHint
                    property: "y"
                    duration: UbuntuAnimation.BriskDuration
                }
            }
        ]
    }
}
