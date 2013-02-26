import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "SudokuCU.js" as SudokuCU

Rectangle {
    id: mainRectangle;
    x:3
    y:3
    //anchors.fill: parent;
    color: "transparent"
    property string defaultColor: "gray";
    property string defaultStartingColor : "#77216F"
    property string defaultNotAllowedColor : "#FF0000"
    property string defaultHintColor: "#DD4814"
    property int currentX;
    property string selectedNumberFromDialog: "0";
    property var grid;
    property var solution;
    property bool alreadyCreated: false;

    function createNewGame(difficulty) {
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (i % 3 == 0 && i != 0 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += units.dp(2);
                if (i > 3 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += units.dp(2);
                if (i > 6 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += units.dp(2);

                if (j % 3 == 0 && j != 0 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += units.dp(2);

                if (j > 3 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += units.dp(2);

                if (j > 6 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += units.dp(2);

                buttonsGrid.itemAt(i*9 + j).buttonText = 0;
                buttonsGrid.itemAt(i*9 + j).color = defaultColor;
                buttonsGrid.itemAt(i*9 + j).border.color = defaultStartingColor;
                buttonsGrid.itemAt(i*9 + j).enabled = true;
            }
        }

        grid = SudokuCU.CU.Sudoku.generate();
        solution = grid;
        SudokuCU.CU.Sudoku.cull(grid, difficulty);
        print(grid);
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (grid.getValue(j,i) != 0) {
                    buttonsGrid.itemAt(i*9 + j).buttonText = grid.getValue(j,i);
                    buttonsGrid.itemAt(i*9 + j).color = defaultStartingColor;
                    buttonsGrid.itemAt(i*9 + j).border.color = "#DD4814";
                    buttonsGrid.itemAt(i*9 + j).enabled = false;
                }
                else
                    buttonsGrid.itemAt(i*9 + j).buttonText = "";
            }
        }
        alreadyCreated = true;
    }

    function checkIfGameFinished() {
        return checkIfAllFieldsFilled() && checkIfAllFieldsCorrect();
    }

    function checkIfAllFieldsFilled() {
        for (var i = 0; i < 81; i++) {
            if (buttonsGrid.itemAt(currentX).buttonText == "")
                return false;
        }
        return true;
    }

    function checkIfAllFieldsCorrect() {
        for (var i = 0; i < 81; i++) {
            var row = Math.floor(i/9);
            var column = i%9;

            var testField = grid.cellConflicts(column,row)
            if (testField == true)
                return false;
        }
        return true;
    }

    Timer {
        id: winTimer;
        interval: 2000;
        running: false;
        repeat: false;
        onTriggered: {
            gameFinishedRectangle.visible = false;
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

    Column {
        anchors.fill: mainRectangle.parent;
        y: 3

        Grid {
            x: 3
            y: 0
            //anchors.horizontalCenter: parent.parent.horizontalCenter;
            rows: 9;
            columns: 9;
            spacing: units.dp(3);

            Component {
                id: dialog

                Dialog {
                    id: dialogue
                    //title: "Number Picker"
                    text: "Please pick a number"

                    Column {
                        spacing: units.gu(5)

                        SudokuButton {
                            id: clearButton
                            width: units.gu(30)
                            buttonText: "Clear"
                            anchors.horizontalCenter: parent.verticalCenter
                            border.color: defaultHintColor
                            border.width: 3
                            MouseArea {
                                id: buttonMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    buttonsGrid.itemAt(currentX).buttonText = ""
                                    PopupUtils.close(dialogue)
                                }
                            }
                        }

                        Grid {
                            columns: 3;
                            x: clearButton.width / 6;
                            spacing: units.gu(2);
                            width: units.gu(15);
                            //anchors.horizontalCenter: dialog.horizontalCenter

                            Repeater {
                                id: numberPickerButtons
                                model:9
                                SudokuButton {
                                    id: buttonPick
                                    buttonText: index+1;
                                    border.color: defaultHintColor
                                    border.width: 3

                                    MouseArea {
                                        id: buttonMouseArea1
                                        anchors.fill: parent
                                        onClicked: {
                                            buttonsGrid.itemAt(currentX).buttonText = index+1

                                            var row = Math.floor(currentX/9);
                                            var column = currentX%9;

                                            print (row, column)
                                            grid.setValue(column, row, index+1);
                                            print(grid)
                                            var testField = grid.cellConflicts(column,row)
                                            print (testField)
                                            if (testField == true)
                                                buttonsGrid.itemAt(currentX).color = defaultNotAllowedColor;
                                            else
                                                buttonsGrid.itemAt(currentX).color = defaultColor;

                                            PopupUtils.close(dialogue)

                                            if (checkIfGameFinished()) {
                                                gameFinishedRectangle.visible = true;
                                                winTimer.restart();
                                            }

                                        }
                                    }
                                }
                            }
                        }

                    }

                }
            }

            Repeater {
                id: buttonsGrid;
                model: 81
                objectName: "buttonsGrid";

                SudokuButton {
                    id: gridButton;
                    buttonText: "0";
                    //width: units.gu(5);
                    //height: units.gu(5);
                    size: units.gu(5)
                    //color: defaultColor;
                    border.width: 3
                    border.color: defaultStartingColor
                    MouseArea {
                        id: buttonMouseArea
                        anchors.fill: parent
                        onClicked: {
                            mainRectangle.currentX = index;
                            PopupUtils.open(dialog, gridButton);
                        }
                    }
                    color: buttonMouseArea.pressed ? Qt.darker(defaultColor,1.5) : defaultColor


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
                    //sudokuBlocksGrid.createNewGame(1);
                }

            }
        }

    }

    /*Button {
        y: units.gu(50)
        width: units.gu(49)
        id: newGameButton
        text: i18n.tr("New Game")
        onClicked: {
            for (var i = 0; i < 9; i++) {
                for (var j = 0; j < 9; j++) {
                    buttonsGrid.itemAt(i*9 + j).buttonText = 0;
                    buttonsGrid.itemAt(i*9 + j).color = defaultColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = true;
                }
            }

            grid = SudokuCU.CU.Sudoku.generate();
            solution = grid;
            SudokuCU.CU.Sudoku.cull(grid, 60);
            //print(grid);
            for (var i = 0; i < 9; i++) {
                for (var j = 0; j < 9; j++) {
                    if (grid.getValue(j,i) != 0) {
                        buttonsGrid.itemAt(i*9 + j).buttonText = grid.getValue(j,i);
                        buttonsGrid.itemAt(i*9 + j).color = defaultStartingColor;
                        buttonsGrid.itemAt(i*9 + j).enabled = false;
                    }
                    else
                        buttonsGrid.itemAt(i*9 + j).buttonText = "";
                }
            }

        }
    }*/
    Row {
        y: units.gu(55)
        spacing: 5
        Rectangle {
            id: redFlagRect
            Rectangle {
                id: redFlag
                color: defaultNotAllowedColor
                width: units.gu(4)
                height: units.gu(4)
                radius: 5
            }
            Text {
                id: redFlagText
                text: i18n.tr("Not allowed")
                anchors.left: redFlag.right;
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: redFlag.verticalCenter
            }
        }
        Rectangle {
            id: blueFlagRect
            x: redFlag.width + redFlagText.width + units.gu(2);
            Rectangle {
                id: blueFlag
                color: defaultStartingColor
                width: units.gu(4)
                height: units.gu(4)
                radius: 5
            }
            Text {
                id: blueFlagText
                text: i18n.tr("Starting blocks")
                anchors.left: blueFlag.right;
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: blueFlag.verticalCenter
            }
        }
        Rectangle {
            id: orangeFlagRect
            x: redFlag.width + redFlagText.width + blueFlagRect.width + blueFlagText.width + units.gu(8)
            Rectangle {
                id: orangeFlag
                color: defaultHintColor
                width: units.gu(4)
                height: units.gu(4)
                radius: 5
            }
            Text {
                text: i18n.tr("Hinted blocks")
                anchors.left: orangeFlag.right;
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: orangeFlag.verticalCenter
            }
        }
    }
}
