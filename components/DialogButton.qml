import QtQuick 2.4
import Ubuntu.Components 1.3

UbuntuShape {
    id: button
    property alias buttonColor: button.color;
    property color textColor: sudokuBlocksGrid.defaultTextColor
    property real size: mainView.blockSize;
    property string buttonText: "";
    property bool boldText: false;


    signal buttonClick()
    height: size;
    width: size;
    radius: "medium"
    backgroundColor: buttonColor
    //border.color: Qt.darker(buttonColor,1.5)

    Text {
        id: buttonText
        text: button.buttonText;
        color: textColor;
        anchors.centerIn: parent
        font.pixelSize: FontUtils.sizeToPixels("large")
        font.bold: boldText;
    }

    //determines the color of the button by using the conditional operator
    //color: buttonMouseArea.pressed ? Qt.darker(color, 1.5) : color
}
