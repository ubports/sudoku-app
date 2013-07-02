import QtQuick 2.0
import Ubuntu.Components 0.1

SudokuButton {
    id: dialogButton
    border.color: defaultBorderColor
    border.width: 3
    textColor: defaultTextColor;

    signal triggered;

    SequentialAnimation {
        id: animateDialogButton
        UbuntuNumberAnimation {
            id: animateDialogButton1
            target: dialogButton
            properties: "scale"
            to: 1.1
            from: 1
            duration: UbuntuAnimation.SnapDuration
            easing: UbuntuAnimation.StandardEasing
        }
        UbuntuNumberAnimation {
            id: animateDialogButton2
            target: dialogButton
            properties: "scale"
            to: 1
            from: 1.1
            duration: UbuntuAnimation.SnapDuration
            easing: UbuntuAnimation.StandardEasing
        }
        onRunningChanged: {
            if (animateDialogButton.running == false ) {
                triggered();
            }

        }
    }
    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        onClicked: {
            animateDialogButton.start();
        }
    }
    buttonColor: buttonMouseArea.pressed ? String(Qt.darker(defaultColor,1.2)):defaultColor
}
