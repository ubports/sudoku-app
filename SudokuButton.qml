import QtQuick 2.0

Rectangle {
    id: button
    property string buttonColor: "gray"
    property real size: units.gu(5)
    property string buttonText: ""

    signal buttonClick()
    height: size;
    width: size;
    radius: 5
    color: buttonColor
    border.color: Qt.darker(buttonColor,1.5)

    Text {
        id: buttonText
        text: button.buttonText;
        color: "white"
        anchors.centerIn: parent
        font.pixelSize: 18
    }

    //determines the color of the button by using the conditional operator
    //color: buttonMouseArea.pressed ? Qt.darker(color, 1.5) : color
}
