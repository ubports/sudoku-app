import QtQuick 2.3
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import "../js/SudokuCU.js" as SudokuCU
import QtFeedback 5.0

UbuntuShape {
    width: 3*blockSize + 5*blockDistance
    height: 3*blockSize + 5*blockDistance
    id: block
    Rectangle {
        height: parent.height - units.dp(6)
        width: units.dp(1)
        x: block.width*1/3;
        y: units.dp(3)
    }
    Rectangle {
        height: parent.height - units.dp(6)
        width: units.dp(1)
        x: block.width*2/3;
        y: units.dp(3)
    }
    Rectangle {
        width: parent.height - units.dp(6)
        height: units.dp(1)
        y: block.width*1/3;
        x: units.dp(3)
    }
    Rectangle {
        width: parent.height - units.dp(6)
        height: units.dp(1)
        y: block.width*2/3;
        x: units.dp(3)
    }
}
