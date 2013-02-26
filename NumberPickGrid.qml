import QtQuick 2.0
import Ubuntu.Components 0.1

Item {

    Grid {
        anchors.horizontalCenter: parent.horizontalCenter
        columns: 3;
        spacing: units.gu(1);
        width: units.gu(15);

        // BLOCK 1
        Button {
            id: cell11;
            text: "1";
            z: 100
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
                print (parent.parent.parent.parent.objectName)
            }
        }
        Button {
            id: cell12;
            text: "2";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }
        Button {
            id: cell13;
            text: "3";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }

        Button {
            id: cell21;
            text: "4";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }
        Button {
            id: cell22;
            text: "5";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }
        Button {
            id: cell23;
            text: "6";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }

        Button {
            id: cell31;
            text: "7";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }
        Button {
            id: cell32;
            text: "8";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }
        Button {
            id: cell33;
            text: "9";
            width: units.gu(5);
            onClicked: {
                numberPickRectangle.visible = false;
            }
        }

    }
}

