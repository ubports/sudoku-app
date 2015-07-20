import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import "../js/SudokuCU.js" as SudokuCU
import QtFeedback 5.0

Rectangle {
    width: 3*blockSize + 5*blockDistance
    height: 3*blockSize + 5*blockDistance
    id: block
    Rectangle {
        color: UbuntuColors.warmGrey
        height: parent.height - units.dp(6)
        width: units.dp(2)
        x: block.width*1/3;
        y: units.dp(3)
    }
    Rectangle {
        color: UbuntuColors.warmGrey
        height: parent.height - units.dp(6)
        width: units.dp(2)
        x: block.width*2/3;
        y: units.dp(3)
    }
    Rectangle {
        color: UbuntuColors.warmGrey
        width: parent.height - units.dp(6)
        height: units.dp(2)
        y: block.width*1/3;
        x: units.dp(3)
    }
    Rectangle {
        color: UbuntuColors.warmGrey
        width: parent.height - units.dp(6)
        height: units.dp(2)
        y: block.width*2/3;
        x: units.dp(3)
    }
}
