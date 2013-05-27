import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "SudokuCU.js" as SudokuCU

Rectangle {
    id: mainRectangle;
    x:3
    y:3
    anchors.fill: parent;
    color: "transparent"

    property alias defaultColor: colorScheme.defaultColor;
    property alias defaultStartingColor : colorScheme.defaultStartingColor
    property alias defaultNotAllowedColor : colorScheme.defaultNotAllowedColor;
    property alias defaultHintColor: colorScheme.defaultHintColor;
    property alias defaultBorderColor: colorScheme.defaultBorderColor;
    property alias boldText: colorScheme.boldText;
    property alias defaultTextColor: colorScheme.textColor;

    property real blockDistance: mainView.blockDistance;
    property int currentX;
    property string selectedNumberFromDialog: "0";
    property var grid;
    property var solution;
    property bool alreadyCreated: mainView.alreadyCreated;
    property bool checkIfCheating: false;

    ColorSchemeDefault {
        id: colorScheme;
    }

    function revealHint() {
        var emptyFields = new Array();
        var counter = 0;
        for (var i = 0; i < 81; i++) {
            var row = Math.floor(i/9);
            var column = i%9;
            /*if (grid.getValue(column,row)== 0) {
                emptyFields[counter] = new Array(2);
                emptyFields[counter][0] = row;
                emptyFields[counter][1] = column;
                counter += 1;
            }*/
            if ( grid.getValue(column,row) === 0 ) {
                emptyFields.push([row, column]);
                counter += 1;
            }
        }
        var randomnumber = Math.floor(Math.random()*counter);
        var hintPair = emptyFields[randomnumber];
        if (emptyFields.length != 0) {
            var hintRow = hintPair[0];
            var hintColumn = hintPair[1];
            //print(solution);
            //print(hintPair);
            //print(solution.getValue(hintColumn, hintRow));
            grid.setValue(hintColumn, hintRow, solution.getValue(hintColumn, hintRow));
            buttonsGrid.itemAt(hintRow*9 + hintColumn).buttonText = solution.getValue(hintColumn, hintRow);
            buttonsGrid.itemAt(hintRow*9 + hintColumn).buttonColor = defaultHintColor;
        }

    }

    function changeColorScheme(newColorScheme) {
        var component = Qt.createComponent(String(newColorScheme));
        var temp = component.createObject(mainRectangle);

        colorScheme.defaultColor = temp.defaultColor;
        colorScheme.defaultStartingColor = temp.defaultStartingColor;
        colorScheme.defaultNotAllowedColor = temp.defaultNotAllowedColor;
        colorScheme.defaultHintColor = temp.defaultHintColor;
        colorScheme.defaultBorderColor = temp.defaultBorderColor;
        colorScheme.boldText = temp.boldText;
        colorScheme.textColor = temp.textColor;

        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (i % 3 == 0 && i != 0 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += blockDistance;
                if (i > 3 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += blockDistance;
                if (i > 6 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += blockDistance;

                if (j % 3 == 0 && j != 0 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += blockDistance;

                if (j > 3 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += blockDistance;

                if (j > 6 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += blockDistance;

                buttonsGrid.itemAt(i*9 + j).buttonText = "";
                buttonsGrid.itemAt(i*9 + j).buttonColor = temp.defaultColor;
                buttonsGrid.itemAt(i*9 + j).border.color = temp.defaultBorderColor;
                buttonsGrid.itemAt(i*9 + j).enabled = true;
            }
        }
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (grid.getValue(j,i) != 0) {
                    buttonsGrid.itemAt(i*9 + j).buttonText = grid.getValue(j,i);
                    buttonsGrid.itemAt(i*9 + j).boldText = temp.boldText;
                    buttonsGrid.itemAt(i*9 + j).buttonColor = temp.defaultStartingColor;
                    buttonsGrid.itemAt(i*9 + j).border.color = temp.defaultBorderColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = false;
                }
                else
                {
                    buttonsGrid.itemAt(i*9 + j).buttonText = "";
                    buttonsGrid.itemAt(i*9 + j).buttonColor = temp.defaultColor;
                    buttonsGrid.itemAt(i*9 + j).border.color = temp.defaultBorderColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = true;
                }
            }
        }
        alreadyCreated = true;

        print("Theme updated " + String(newColorScheme));
    }

    function createNewGame(difficulty) {
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                /*if (i % 3 == 0 && i != 0 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += blockDistance;
                if (i > 3 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += blockDistance;
                if (i > 6 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).y += blockDistance;

                if (j % 3 == 0 && j != 0 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += blockDistance;

                if (j > 3 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += blockDistance;

                if (j > 6 && !alreadyCreated)
                    buttonsGrid.itemAt(i*9 + j).x += blockDistance;*/

                buttonsGrid.itemAt(i*9 + j).buttonText = "";
                buttonsGrid.itemAt(i*9 + j).buttonColor = defaultColor;
                buttonsGrid.itemAt(i*9 + j).boldText = boldText;
                buttonsGrid.itemAt(i*9 + j).border.color = defaultBorderColor;
                buttonsGrid.itemAt(i*9 + j).enabled = true;
            }
        }

        grid = SudokuCU.CU.Sudoku.generate();
        solution = SudokuCU.deepCopy(grid);
        SudokuCU.CU.Sudoku.cull(grid, difficulty);
        //print("width:"); print(mainView.width);
        //print("height:"); print(mainView.height);
        //print(solution);
        //print("start:");
        //print(grid);
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (grid.getValue(j,i) != 0) {
                    buttonsGrid.itemAt(i*9 + j).buttonText = grid.getValue(j,i);
                    buttonsGrid.itemAt(i*9 + j).buttonColor = defaultStartingColor;
                    buttonsGrid.itemAt(i*9 + j).border.color = defaultBorderColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = false;
                }
                else
                    buttonsGrid.itemAt(i*9 + j).buttonText = "";
            }
        }
        mainView.alreadyCreated = true;
    }

    function checkIfGameFinished() {
        //print (checkIfAllFieldsFilled());
        //print (checkIfAllFieldsCorrect());
        return checkIfAllFieldsFilled() && checkIfAllFieldsCorrect();
    }

    function checkIfAllFieldsFilled() {
        for (var i = 0; i < 81; i++) {
            var row = Math.floor(i/9);
            var column = i%9;
            if (grid.getValue(column,row) == 0)
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
        //anchors.fill: mainRectangle.parent;
        y: 3

        Grid {
            x: 3
            y: 0
            //anchors.horizontalCenter: parent.parent.horizontalCenter;
            rows: 9;
            columns: 9;
            spacing: units.dp(1);

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
                            width: mainView.pageWidth*2/3;
                            buttonText: "Clear"
                            size: units.gu(5)
                            //anchors.horizontalCenter: dialogue.verticalCenter
                            anchors.left: parent.left;
                            x: mainView.pageWidth/2 - units.gu(5)/2;
                            border.color: defaultBorderColor
                            border.width: 3
                            textColor: defaultTextColor;
                            MouseArea {
                                id: buttonMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    buttonsGrid.itemAt(currentX).buttonText = "";
                                    var row = Math.floor(currentX/9);
                                    var column = currentX%9;
                                    print (row, column);
                                    grid.setValue(column,row, 0);
                                    buttonsGrid.itemAt(currentX).buttonColor = defaultColor;
                                    buttonsGrid.itemAt(currentX).boldText = false;
                                    PopupUtils.close(dialogue)
                                }
                            }
                            buttonColor: buttonMouseArea.pressed ? String(Qt.darker(defaultColor,1.2)):defaultColor
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
                                    size: units.gu(5);
                                    border.color: defaultBorderColor;
                                    border.width: 2
                                    textColor: defaultTextColor;
                                    MouseArea {
                                        id: buttonMouseArea1
                                        anchors.fill: parent
                                        onClicked: {
                                            buttonsGrid.itemAt(currentX).buttonText = index+1

                                            var row = Math.floor(currentX/9);
                                            var column = currentX%9;

                                            //print (row, column)
                                            grid.setValue(column, row, index+1);
                                            //print(grid)
                                            var testField = grid.cellConflicts(column,row)
                                            //print (testField)
                                            if (testField == true)
                                                buttonsGrid.itemAt(currentX).buttonColor = defaultNotAllowedColor;
                                            else {
                                                buttonsGrid.itemAt(currentX).buttonColor = defaultColor;
                                                buttonsGrid.itemAt(currentX).boldText = false;
                                            }

                                            PopupUtils.close(dialogue)

                                            if (checkIfGameFinished()) {
                                                gameFinishedRectangle.visible = true;
                                                winTimer.restart();
                                            }

                                        }
                                    }
                                    buttonColor: buttonMouseArea1.pressed ? String(Qt.darker(defaultColor,1.2)):defaultColor
                                }
                            }
                        }

                    }

                }
            }

           SudokuButtonsGrid {
               id:buttonsGrid;
           }
        }
    }

    Row {
        id: informationRow;
        y: 7*mainView.pageHeight/10;
        x: units.dp(8);
        width: mainView.pageWidth - units.dp(8);
        Rectangle {
            id: redFlagRect
            x: 0
            Rectangle {
                id: redFlag
                color: defaultNotAllowedColor
                width: mainView.pageWidth/10;
                height: mainView.pageWidth/10;
                radius: 5
                Label {
                    id: redFlagText
                    text: i18n.tr("Not allowed")
                    fontSize: "x-small"
                    width:units.gu(5);
                    wrapMode: TextEdit.WordWrap;
                    anchors.left: redFlag.right;
                    anchors.leftMargin: units.dp(2);
                    anchors.verticalCenter: redFlag.verticalCenter;
                }
            }

        }
        Rectangle {
            id: blueFlagRect
            x: 3*mainView.pageWidth/10 + 10*blockDistance;
            //anchors.leftMargin: redFlag.width + redFlagText.width;
            Rectangle {
                id: blueFlag
                color: defaultStartingColor
                border.color: defaultBorderColor
                width: mainView.pageWidth/10
                height: mainView.pageWidth/10
                radius: 5;
                Label {
                    id: blueFlagText
                    text: i18n.tr("Start blocks")
                    fontSize: "x-small"
                    width:units.gu(5);
                    wrapMode: TextEdit.WordWrap;
                    anchors.left: blueFlag.right;
                    anchors.leftMargin: units.dp(2);
                    anchors.verticalCenter: blueFlag.verticalCenter;
                }
            }

        }
        Rectangle {
            id: orangeFlagRect
            x:  7*mainView.pageWidth/10+2*blockDistance;
            Rectangle {
                id: orangeFlag
                color: defaultHintColor
                border.color: defaultBorderColor
                width: mainView.pageWidth/10
                height: mainView.pageWidth/10
                radius: 5;
                Label {
                    text: i18n.tr("Hinted blocks")
                    fontSize: "x-small"
                    width:units.gu(5);
                    wrapMode: TextEdit.WordWrap;
                    anchors.left: orangeFlag.right;
                    anchors.leftMargin: units.dp(2);
                    anchors.verticalCenter: orangeFlag.verticalCenter;
                }
            }

        }
    }
}
