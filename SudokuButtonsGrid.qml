import QtQuick 2.0



Repeater {
    id: buttonsGrid;
    model: 81
    objectName: "buttonsGrid";

    SudokuButton {
        id: gridButton;
        buttonText: "0";
        //width: units.gu(5);
        //height: units.gu(5);
        size: mainView.pageWidth/10;
        //color: defaultColor;
        border.width: 3
        border.color: defaultBorderColor
        textColor: defaultTextColor;
        MouseArea {
            id: buttonMouseArea2
            anchors.fill: parent
            onClicked: {
                mainRectangle.currentX = index;
                gridButton.buttonColor = defaultColor;
                PopupUtils.open(dialog, gridButton);
            }
            onPressed: {
                gridButton.buttonColor = String(Qt.darker(defaultColor,1.5));
            }
        }
        buttonColor: defaultColor;


    }
    Component.onCompleted: {
        switch(difficultySelector.selectedIndex) {
        case 0:
            var randomnumber = Math.floor(Math.random()*9);
            randomnumber += 31;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            break;
        case 1:
            var randomnumber = Math.floor(Math.random()*4);
            randomnumber += 26;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            break;
        case 2:
            var randomnumber = Math.floor(Math.random()*4);
            randomnumber += 21;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            break;
        case 3:
            var randomnumber = Math.floor(Math.random()*3);
            randomnumber += 17;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            break;
        }
    }

}

