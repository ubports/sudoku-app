import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import "../js/SudokuCU.js" as SudokuCU
import QtFeedback 5.0

Column {
    id: mainRectangle;
    //x:3
    //y:3
    //anchors.fill: parent;
    //anchors.horizontalCenter: parent.horizontalCenter
    //color: "transparent"
    spacing: units.gu(5)

    property alias defaultColor: colorScheme.defaultColor;
    property alias defaultStartingColor : colorScheme.defaultStartingColor
    property alias defaultNotAllowedColor : colorScheme.defaultNotAllowedColor;
    property alias defaultHintColor: colorScheme.defaultHintColor;
    property alias defaultBorderColor: colorScheme.defaultBorderColor;
    property alias boldText: colorScheme.boldText;
    property alias defaultTextColor: colorScheme.textColor;

    property alias dialogButtonColor1: colorScheme.dialogButtonColor1
    property alias dialogButtonColor2: colorScheme.dialogButtonColor2
    property alias dialogButtonTextColor: colorScheme.dialogButtonTextColor

    //property color headerColor: colorScheme.headerColor
    //property color backgroundColor: colorScheme.backgroundColor
    //property color footerColor: colorScheme.backgroundColor

    property real blockDistance: mainView.blockDistance;
    property int currentX;
    property string selectedNumberFromDialog: "0";
    property var grid;
    property var solution;
    property bool alreadyCreated: mainView.alreadyCreated;
    property bool checkIfCheating: false;
    property real blockSize: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/10: units.gu(50)/10;

    // ********* SCORES ENGINE VARIABLES ***************

    property int gameSeconds: 0;
    property int numberOfActions: 0;
    property int numberOfHints: 0;
    property int gameDifficulty: settingsTab.difficultyIndex;

    // *************************************************

    ColorSchemeDefault {
        id: colorScheme;
    }

    ThemeEffect {
        id: incorrectEntry
        effect: "PressStrong"
    }

    function calculateScore() {
        return Math.round((100000 * ((gameDifficulty+1)/(numberOfActions + (1000*numberOfHints) + gameSeconds))))
    }

    function resetScore() {
        gameSeconds = 0;
        numberOfActions = 0;
        numberOfHints = 0;
    }


    function revealHint() {
        numberOfHints++;
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
            buttonsGrid.itemAt(hintRow*9 + hintColumn).hinted = true;
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
        colorScheme.dialogButtonColor1 = temp.dialogButtonColor1;
        colorScheme.dialogButtonColor2 = temp.dialogButtonColor2;
        colorScheme.dialogButtonTextColor = temp.dialogButtonTextColor;

        colorScheme.headerColor = temp.headerColor;
        colorScheme.backgroundColor = temp.backgroundColor;
        colorScheme.footerColor = temp.footerColor;

        mainView.headerColor = colorScheme.headerColor;
        mainView.backgroundColor = colorScheme.backgroundColor;
        mainView.footerColor = colorScheme.footerColor;

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
                //buttonsGrid.itemAt(i*9 + j).border.color = temp.defaultBorderColor;
                buttonsGrid.itemAt(i*9 + j).enabled = true;
            }
        }
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (grid.getValue(j,i) != 0) {
                    buttonsGrid.itemAt(i*9 + j).buttonText = grid.getValue(j,i);
                    buttonsGrid.itemAt(i*9 + j).boldText = temp.boldText;
                    buttonsGrid.itemAt(i*9 + j).buttonColor = temp.defaultStartingColor;
                    //buttonsGrid.itemAt(i*9 + j).border.color = temp.defaultBorderColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = false;
                }
                else
                {
                    buttonsGrid.itemAt(i*9 + j).buttonText = "";
                    buttonsGrid.itemAt(i*9 + j).buttonColor = temp.defaultColor;
                    //buttonsGrid.itemAt(i*9 + j).border.color = temp.defaultBorderColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = true;
                }
            }
        }
        alreadyCreated = true;

        //print("Theme updated " + String(newColorScheme));
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
                //buttonsGrid.itemAt(i*9 + j).border.color = defaultBorderColor;
                buttonsGrid.itemAt(i*9 + j).enabled = true;
                buttonsGrid.itemAt(i*9 + j).hinted = false;
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
                    //buttonsGrid.itemAt(i*9 + j).border.color = defaultBorderColor;
                    buttonsGrid.itemAt(i*9 + j).enabled = false;
                }
                else
                    buttonsGrid.itemAt(i*9 + j).buttonText = "";
            }
        }
        mainView.alreadyCreated = true;
        if (gameTimer.running == true)
            gameTimer.restart();
        else
            gameTimer.start();
        resetScore();
    }

    function checkIfGameFinished() {
        //print (checkIfAllFieldsFilled());
        //print (checkIfAllFieldsCorrect());
        //print("game finished")
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
        id: gameTimer;
        running:false;
        repeat: true;
        interval: 1000;
        onTriggered: {
            gameSeconds++;
            //print(gameSeconds, numberOfActions, numberOfHints, calculateScore())
        }
    }

    Timer {
        id: winTimer;
        interval: 3000;
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
            case 4:
                PopupUtils.open(newGameComponent);
                break;
            }
        }

    }

    Item {
        //anchors.fill: mainRectangle.parent;
        //y: 3

        Item {

            // x: 3
            // y: 0
            //anchors.horizontalCenter: parent.parent.horizontalCenter;
            //  rows: 9;
            //  columns: 9;
            //  spacing: units.dp(1);


            Component {
                id: dialog

                Dialog {
                    id: dialogue
                    objectName: "picknumberscreen"
                    //title: "Number Picker"
                    text: i18n.tr("Please pick a number")

                    //Column {
                    //    spacing: units.gu(5)
                    //x: -units.gu(1)
                    Component.onCompleted: {
                        mainView.dialogLoaded = 2;
                        dialogue.focus = true;
                        //print(dialogue.focus)
                    }
                    Keys.onPressed: {
                        //print("Pressed: ",event.key)
                        if (event.key-48 >= 1 && event.key-48 <= 9) {
                            pressButton(event.key-48)
                        }
                        else if (event.key === Qt.Key_Escape) {
                            buttonsGrid.redrawGrid()
                            PopupUtils.close(dialogue)
                        }
                        else if (event.key == Qt.Key_C) {
                            numberOfActions++;
                            buttonsGrid.itemAt(currentX).buttonText = "";
                            var row = Math.floor(currentX/9);
                            var column = currentX%9;
                            //print (row, column);
                            grid.setValue(column,row, 0);
                            buttonsGrid.itemAt(currentX).buttonColor = defaultColor;
                            buttonsGrid.itemAt(currentX).boldText = false;
                            buttonsGrid.itemAt(currentX).hinted = false
                            buttonsGrid.redrawGrid()
                            PopupUtils.close(dialogue)
                        }


                    }

                    function pressButton(currentDigit){
                        buttonsGrid.itemAt(currentX).buttonText = currentDigit
                        buttonsGrid.itemAt(currentX).hinted = false
                        numberOfActions++;

                        var row = Math.floor(currentX/9);
                        var column = currentX%9;

                        //print (row, column)
                        grid.setValue(column, row, currentDigit);

                        buttonsGrid.redrawGrid()
                        PopupUtils.close(dialogue)
                        if (checkIfAllFieldsCorrect() == false) {
                            //console.log("FALSE ENTRY");
                            incorrectEntry.play();
                        }

                        mainView.dialogLoaded = -1;
                        mainView.focus = true;
                    }


                    SudokuDialogButton {
                        id: clearButton
                        buttonText: i18n.tr("Clear")
                        width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width*2/3: units.gu(50)*2/3
                        size: units.gu(5)
                        //anchors.left: parent.left;
                        //anchors.horizontalCenter: parent
                        buttonColor: dialogButtonColor1
                        textColor: dialogButtonTextColor
                        //border.color: "transparent"
                        onTriggered: {
                            numberOfActions++;
                            buttonsGrid.itemAt(currentX).buttonText = "";
                            var row = Math.floor(currentX/9);
                            var column = currentX%9;
                            //print (row, column);
                            grid.setValue(column,row, 0);
                            buttonsGrid.itemAt(currentX).buttonColor = defaultColor;
                            buttonsGrid.itemAt(currentX).boldText = false;
                            buttonsGrid.itemAt(currentX).hinted = false
                            buttonsGrid.redrawGrid()
                            PopupUtils.close(dialogue)
                            //parent.pressButton(currentX);
                        }
                    }

                    Grid {
                        columns: 3;
                        x: clearButton.x + 0.5*(clearButton.width - 4*units.gu(5))
                        spacing: units.gu(2);
                        //width: mainView.width/mainView.height < 0.6 ? mainView.pageWidth*2/3: units.gu(50)*2/3;
                        //anchors.horizontalCenter: clearButton.horizontalCenter
                        //anchors.horizontalCenter: parent

                        Repeater {
                            id: numberPickerButtons
                            model:9
                            anchors.centerIn: parent


                            SudokuDialogButton{
                                id: buttonPick
                                buttonText: index+1;

                                size: units.gu(5);

                                onTriggered: {
                                    //print("curr: ", index+1)
                                    buttonsGrid.itemAt(currentX).buttonText = index+1
                                    buttonsGrid.itemAt(currentX).hinted = false
                                    numberOfActions++;

                                    var row = Math.floor(currentX/9);
                                    var column = currentX%9;

                                    //print (row, column)
                                    grid.setValue(column, row, index+1);

                                    buttonsGrid.redrawGrid()

                                    PopupUtils.close(dialogue)

                                    if ( checkIfGameFinished()) {
                                        gameFinishedRectangle.visible = true;
                                        //Settings.insertNewScore(currentUserId, sudokuBlocksGrid.calculateScore())
                                        mainView.insertNewGameScore(currentUserId, sudokuBlocksGrid.calculateScore())

                                        if (checkIfCheating)
                                        {
                                            gameFinishedText.text = i18n.tr("You are a cheat...\nBut we give you\n%1 point.",
                                                                            "You are a cheat...\nBut we give you\n%1 points.",
                                                                            sudokuBlocksGrid.calculateScore()).arg(sudokuBlocksGrid.calculateScore())

                                        }
                                        else
                                        {
                                            gameFinishedText.text = i18n.tr("Congratulations!\nWe give you\n%1 point.",
                                                                            "Congratulations!\nWe give you\n%1 points.",
                                                                            sudokuBlocksGrid.calculateScore()).arg(sudokuBlocksGrid.calculateScore())
                                        }                                        

                                        //print (sudokuBlocksGrid.numberOfActions)
                                        //print (sudokuBlocksGrid.numberOfHints)
                                        //print (sudokuBlocksGrid.gameSeconds)
                                        //print (sudokuBlocksGrid.gameDifficulty)
                                        gamesPlayedMetric.increment(1);

                                        winTimer.restart();
                                    }
                                }
                            }
                        }
                    }


                    SudokuDialogButton{
                        buttonText: i18n.tr("Cancel")
                        width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width*2/3: units.gu(50)*2/3
                        size: units.gu(5)
                        //anchors.left: parent.left;
                        //anchors.horizontalCenter: parent
                        anchors.leftMargin: units.gu(10)
                        buttonColor: dialogButtonColor2
                        textColor: dialogButtonTextColor
                        //border.color: "transparent"
                        onTriggered: {
                            buttonsGrid.redrawGrid()
                            PopupUtils.close(dialogue)
                        }
                    }

                    //}

                }
            }




            SudokuButtonsGrid {
                id:buttonsGrid;
            }



        }
    }
}

