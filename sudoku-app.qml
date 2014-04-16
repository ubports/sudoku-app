import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 0.1
import Ubuntu.Layouts 0.1
import "js/localStorage.js" as Settings
import "components"
//import Ubuntu.HUD 1.0 as HUD
import Ubuntu.Unity.Action 1.0 as UnityActions
import UserMetrics 0.1

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "sudoku"
    applicationName: "com.ubuntu.sudoku"

    property real resizeFactor: units.gu(50)/units.gu(75)
    property real blockDistance: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/200: units.gu(50)/200;
    property bool alreadyCreated: false;
    property bool gridLoaded: false;
    property int currentUserId: -1;
    property string highscoresHeaderText: i18n.tr("<b>Best scores for all players</b>")

    property string alertTitle: ""
    property string alertText : ""

    property int dialogLoaded: -1;

    property int editUserId : -1;

    width: units.gu(41);
    height: units.gu(70);

    //headerColor: sudokuBlocksGrid.headerColor
    //backgroundColor: sudokuBlocksGrid.backgroundColor
    //footerColor: sudokuBlocksGrid.footerColor

    /*HUD.HUD {
        applicationIdentifier: "sudoku-app" // this has to match the .desktop file!
        HUD.Context {*/

    StateSaver.properties: "width, height"

    actions: [
        Action {
            text: i18n.tr("New game")
            keywords: i18n.tr("New game")
            onTriggered: {
                tabs.selectedTabIndex = 0
                createNewGame()
            }
        },
        Action {
            text: i18n.tr("Reveal hint")
            keywords: i18n.tr("Reveal hint")
            enabled: disableHints.checked
            onTriggered: {
                tabs.selectedTabIndex = 0
                revealHint()
            }
        },
        Action {
            text: i18n.tr("Show settings")
            keywords: i18n.tr("Show settings")
            onTriggered: {
                tabs.selectedTabIndex = 2
                revealHint()
            }
        },
        Action {
            text: i18n.tr("Change difficulty to Easy")
            keywords: i18n.tr("Change difficulty to Easy")
            onTriggered: {
                tabs.selectedTabIndex = 0
                difficultySelector.selectedIndex = 0
                var randomnumber = Math.floor(Math.random()*9);
                randomnumber += 31;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                Settings.setSetting("Difficulty", 0)
                createNewGame()
            }
        },
        Action {
            text: i18n.tr("Change difficulty to Moderate")
            keywords: i18n.tr("Change difficulty to Moderate")
            onTriggered: {
                tabs.selectedTabIndex = 0
                difficultySelector.selectedIndex = 1
                var randomnumber = Math.floor(Math.random()*4);
                randomnumber += 26;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                Settings.setSetting("Difficulty", 1)
                createNewGame()
            }
        },
        Action {
            text: i18n.tr("Change difficulty to Hard")
            keywords: i18n.tr("Change difficulty to Hard")
            onTriggered: {
                tabs.selectedTabIndex = 0
                difficultySelector.selectedIndex = 2
                var randomnumber = Math.floor(Math.random()*4);
                randomnumber += 21;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                Settings.setSetting("Difficulty", 2)
                createNewGame()
            }
        },
        Action {
            text: i18n.tr("Change difficulty to Ultra Hard")
            keywords: i18n.tr("Change difficulty to Ultra Hard")
            onTriggered: {
                tabs.selectedTabIndex = 0
                difficultySelector.selectedIndex = 3
                var randomnumber = Math.floor(Math.random()*3);
                randomnumber += 17;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                Settings.setSetting("Difficulty", 3)
                createNewGame()
            }
        },
        Action {
            text: i18n.tr("Change theme to Simple")
            keywords: i18n.tr("Change theme to Simple")
            onTriggered: {
                //print("Simple")
                var result = Settings.setSetting("ColorTheme", 1);
                //print(result);
                sudokuBlocksGrid.changeColorScheme("ColorSchemeSimple.qml");
            }
        },
        Action {
            text: i18n.tr("Change theme to UbuntuColors")
            keywords: i18n.tr("Change theme to UbuntuColors")
            onTriggered: {
                print("UbuntuColors")
                var result = Settings.setSetting("ColorTheme", 0);
                //print(result);
                sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
            }
        },
        Action {
            text: i18n.tr("Show scores for all users")
            keywords: i18n.tr("Show scores for all users")
            onTriggered: {
                tabs.selectedTabIndex = 1
                var allScores = Settings.getAllScores()
                highscoresModel.clear();
                highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
                for(var i = 0; i < allScores.length; i++) {
                    var rowItem = allScores[i];
                    //print("ROW ",rowItem)
                    var firstName = Settings.getUserFirstName(rowItem[0]);
                    var lastName = Settings.getUserLastName(rowItem[0]);
                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                    highscoresModel.append({'firstname': firstName,
                                               'lastname':  lastName,
                                               'score': rowItem[1] });
                }
            }
        },
        Action {
            text: i18n.tr("Show scores for current user")
            keywords: i18n.tr("Show scores for current user")
            onTriggered: {
                tabs.selectedTabIndex = 1
                var firstName = Settings.getUserFirstName(currentUserId);
                var lastName = Settings.getUserLastName(currentUserId);
                //print(firstName, lastName)
                highscoresHeaderText = i18n.tr("<b>Best scores for ")+firstName + " " + lastName+"</b>"
                var allScores = Settings.getAllScoresForUser(currentUserId)
                highscoresModel.clear();
                for(var i = 0; i < allScores.length; i++) {
                    var rowItem = allScores[i];
                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                    highscoresModel.append({'firstname': firstName,
                                               'lastname':  lastName,
                                               'score': rowItem[1] });
                }
            }
        }
    ]
    //}
    //}

    onCurrentUserIdChanged: {
        Settings.setSetting("currentUserId", currentUserId)
    }

    function insertNewGameScore(userId, score) {
        Settings.insertNewScore(userId, score)
    }

    function wideAspect() {
        return width > units.gu(80)
    }

    function updatehighScores() {
        var allScores = Settings.getAllScores()
        highscoresModel.clear();
        highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
        for(var i = 0; i < allScores.length; i++) {
            var rowItem = allScores[i];
            print("ROW ",rowItem)
            var firstName = Settings.getUserFirstName(rowItem[0]);
            var lastName = Settings.getUserLastName(rowItem[0]);
            //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
            highscoresModel.append({'firstname': firstName,
                                       'lastname':  lastName,
                                       'score': rowItem[1] });
        }
    }

    function revealHint() {
        if(disableHints.checked)
        {
            sudokuBlocksGrid.revealHint();
            sudokuBlocksGrid.checkIfCheating = true;
            if (sudokuBlocksGrid.checkIfGameFinished()) {
                gameFinishedRectangle.visible = true;
                Settings.insertNewScore(currentUserId, sudokuBlocksGrid.calculateScore())
                gameFinishedText.text = i18n.tr("You are a cheat... \nBut we give you\n")
                        + sudokuBlocksGrid.calculateScore()
                        + " " + i18n.tr("points.")

                //                print (sudokuBlocksGrid.numberOfActions)
                //                print (sudokuBlocksGrid.numberOfHints)
                //                print (sudokuBlocksGrid.gameSeconds)
                //                print (sudokuBlocksGrid.gameDifficulty)
                var allScores = Settings.getAllScores()
                highscoresModel.clear();
                highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
                for(var i = 0; i < allScores.length; i++) {
                    var rowItem = allScores[i];
                    //(print("ROW ",rowItem)
                    var firstName = Settings.getUserFirstName(rowItem[0]);
                    var lastName = Settings.getUserLastName(rowItem[0]);
                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                    highscoresModel.append({'firstname': firstName,
                                               'lastname':  lastName,
                                               'score': rowItem[1] });
                }

                winTimer.restart();
            }
        }
    }

    function createNewGame() {
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
            mainView.dialogLoaded = 1;
            PopupUtils.open(newGameComponent)
            break;
        default:
            var randomnumber = Math.floor(Math.random()*9);
            randomnumber += 31;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            break;
        }
    }

    function newSize(widthn, heightn) {
        width = widthn
        height = heightn
        //print(height," x ", width);
    }

    function updateGrid() {
        //print("Updating grid");
        //print("width:"); print(mainView.width);
        //print("height:"); print(mainView.height);
        for (var i = 0; i < 9; i++) {
            for (var j = 0; j < 9; j++) {
                if (i % 3 == 0 && i != 0)
                    sudokuBlocksGrid.buttonsGridPublic.itemAt(i*9 + j).y += blockDistance;
                if (i > 3)
                    sudokuBlocksGrid.buttonsGridPublic.itemAt(i*9 + j).y += blockDistance;
                if (i > 6)
                    sudokuBlocksGrid.buttonsGridPublic.itemAt(i*9 + j).y += blockDistance;

                if (j % 3 == 0 && j != 0)
                    sudokuBlocksGrid.buttonsGridPublic.itemAt(i*9 + j).x += blockDistance;

                if (j > 3)
                    sudokuBlocksGrid.buttonsGridPublic.itemAt(i*9 + j).x += blockDistance;

                if (j > 6)
                    sudokuBlocksGrid.buttonsGridPublic.itemAt(i*9 + j).x += blockDistance;
            }
        }

        mainView.alreadyCreated = true;
        //mainRectangle.update();
        //buttonsGridPublic.update();
    }

    Metric {
        id: gamesPlayedMetric
        name: "sudoku-metrics"
        format: "<b>%1</b> " + i18n.tr("Sudoku games played today")
        emptyFormat: i18n.tr("No Sudoku games played today")
        domain: "com.ubuntu.sudoku"
    }

    Component {
        id: alertDialog
        Dialog {
            id: alertDialogue
            title: alertTitle
            text: alertText

            SudokuDialogButton{
                buttonText: i18n.tr("OK")
                width: parent.width/2;
                size: units.gu(5)
                onTriggered: {
                    PopupUtils.close(alertDialogue)
                }
            }

        }
    }

    Component {
        id: newGameComponent

        Dialog {
            id: newGameDialogue
            title: i18n.tr("New Game")
            text: i18n.tr("Select difficulty level")

            function closeDialog() {
                PopupUtils.close(newGameDialogue)
                mainView.dialogLoaded = -1;
                mainView.focus = true;
            }

            Component.onCompleted: {
                mainView.dialogLoaded = 1;
                newGameDialogue.focus = true;
                mainView.focus = false;
            }

            Keys.onPressed: {
                switch(event.key) {
                case Qt.Key_E:
                    var randomnumber = Math.floor(Math.random()*9);
                    randomnumber += 31;
                    sudokuBlocksGrid.createNewGame(81 - randomnumber);
                    sudokuBlocksGrid.gameDifficulty = 0
                    break;
                case Qt.Key_M:
                    var randomnumber = Math.floor(Math.random()*4);
                    randomnumber += 26;
                    sudokuBlocksGrid.createNewGame(81 - randomnumber);
                    sudokuBlocksGrid.gameDifficulty = 1
                    break;
                case Qt.Key_R:
                    var randomnumber = Math.floor(Math.random()*4);
                    randomnumber += 21;
                    sudokuBlocksGrid.createNewGame(81 - randomnumber);
                    sudokuBlocksGrid.gameDifficulty = 2
                    break;
                case Qt.Key_U:
                    var randomnumber = Math.floor(Math.random()*3);
                    randomnumber += 17;
                    sudokuBlocksGrid.createNewGame(81 - randomnumber);
                    sudokuBlocksGrid.gameDifficulty = 3
                    break;

                case Qt.Key_Escape:
                    break;

                default:
                    //console.log("No key action defined")
                    break;
                }
            }



            Column {
                spacing: units.gu(5)

                Grid {
                    rowSpacing: units.gu(3)
                    columnSpacing: units.gu(3)
                    columns: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    NewGameSelectionButton {
                        id: easyGameButton
                        objectName: "easyGameButton"
                        buttonText: i18n.tr("Easy")
                        opacity: 0.8
                        width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/4: units.gu(50)/4;
                        height: width

                        onTriggered: {
                            //print("EASY")
                            var randomnumber = Math.floor(Math.random()*9);
                            randomnumber += 31;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            sudokuBlocksGrid.gameDifficulty = 0
                            newGameDialogue.closeDialog()
                            //toolbar.opened = false;
                        }

                    }
                    NewGameSelectionButton {
                        id: moderateGameButton
                        objectName: "moderateGameButton"
                        buttonText: i18n.tr("Moderate")
                        opacity: 0.8
                        width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/4: units.gu(50)/4;
                        height: width
                        onTriggered: {
                            //print("EASY")
                            var randomnumber = Math.floor(Math.random()*4);
                            randomnumber += 26;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            sudokuBlocksGrid.gameDifficulty = 1
                            newGameDialogue.closeDialog()
                            //toolbar.opened = false;
                        }
                    }
                    NewGameSelectionButton {
                        id: hardGameButton
                        objectName: "hardGameButton"
                        buttonText: i18n.tr("Hard")
                        opacity: 0.8
                        width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/4: units.gu(50)/4;
                        height: width
                        onTriggered: {
                            //print("EASY")
                            var randomnumber = Math.floor(Math.random()*4);
                            randomnumber += 21;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            sudokuBlocksGrid.gameDifficulty = 2
                            newGameDialogue.closeDialog()
                            //toolbar.opened = false;
                        }
                    }
                    NewGameSelectionButton {
                        id: ultrahardGameButton
                        objectName: "ultrahardGameButton"
                        buttonText: i18n.tr("Ultra\nHard")
                        opacity: 0.8
                        width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/4: units.gu(50)/4;
                        height: width
                        onTriggered: {
                            //print("EASY")
                            var randomnumber = Math.floor(Math.random()*3);
                            randomnumber += 17;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            sudokuBlocksGrid.gameDifficulty = 3
                            newGameDialogue.closeDialog()
                            //toolbar.opened = false;
                        }
                    }

                }

                SudokuDialogButton{
                    buttonText: i18n.tr("Cancel")
                    width: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width*2/3: units.gu(50)*2/3
                    size: units.gu(5)
                    buttonColor: sudokuBlocksGrid.dialogButtonColor1
                    textColor: sudokuBlocksGrid.dialogButtonTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    //border.color: "transparent"
                    onTriggered: {
                        newGameDialogue.closeDialog()
                    }
                }
            }

        }
    }

    focus: true
    Keys.onPressed: {
        if (mainView.dialogLoaded == -1 && mainView.focus == true) {
            switch(event.key) {
            case Qt.Key_E:
                var randomnumber = Math.floor(Math.random()*9);
                randomnumber += 31;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                sudokuBlocksGrid.gameDifficulty = 0
                settingsTab.difficultyIndex = 0;
                break;
            case Qt.Key_M:
                var randomnumber = Math.floor(Math.random()*4);
                randomnumber += 26;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                sudokuBlocksGrid.gameDifficulty = 1
                settingsTab.difficultyIndex = 1
                break;
            case Qt.Key_R:
                var randomnumber = Math.floor(Math.random()*4);
                randomnumber += 21;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                sudokuBlocksGrid.gameDifficulty = 2
                settingsTab.difficultyIndex = 2
                break;
            case Qt.Key_U:
                var randomnumber = Math.floor(Math.random()*3);
                randomnumber += 17;
                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                sudokuBlocksGrid.gameDifficulty = 3
                settingsTab.difficultyIndex = 3
                break;

            case Qt.Key_H:
                // Show Hint if possible
                revealHint();
                break;

            case Qt.Key_Left:
                if (tabs.selectedTabIndex > 0) {
                    //print(tabs.selectedTabIndex)
                    tabs.selectedTabIndex -= 1
                }
                else
                    tabs.selectedTabIndex = 3
                break;

            case Qt.Key_Right:
                if (tabs.selectedTabIndex < 3) {
                    //print(tabs.selectedTabIndex)
                    tabs.selectedTabIndex += 1
                }
                else
                    tabs.selectedTabIndex = 0
                break;

            case Qt.Key_Escape:
                break;

            default:
                //console.log("No key action defined")
                break;
            }
        }
    }


    function showAlert(title, text, caller)
    {
        alertTitle = title
        alertText = text
        PopupUtils.open(alertDialog, caller)

    }

    function showNewGameDialog(caller)
    {
        PopupUtils.open(newGameComponent, caller)

    }
    function hideNewGameDialog()
    {
        PopupUtils.close(newGameComponent, caller)

    }

    onHeightChanged: {
        if (!gridLoaded && width/height > mainView.resizeFactor)
            return;
        newSize(mainView.width, mainView.height);
    }
    onWidthChanged: {
        if (!gridLoaded && width/height > mainView.resizeFactor)
            return;
        newSize(mainView.width, mainView.height);
    }


    Component.onCompleted: {
        Settings.initialize();
        settingsTab.difficultyIndex = parseInt(Settings.getSetting("Difficulty"));
        //print(Settings.getSetting("DisableHints"));
        settingsTab.disableHintsChecked = Settings.getSetting("DisableHints") == "true" ? true : false;
        settingsTab.disableVibrationsChecked = Settings.getSetting("DisableVibrations") == "true" ? true : false;
        settingsTab.themeIndex = parseInt(Settings.getSetting("ColorTheme"));
        //print(Settings.getSetting("ColorTheme"));
        var newColorScheme = null;
        if (Settings.getSetting("ColorTheme") == "Unknown") {
            sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
            print("NE VALJA")
            var result = Settings.setSetting("ColorTheme", 0);

        }
        if (settingsTab.themeIndex == 0)
        {
            //print("Ubuntu")
            sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
        }
        if (settingsTab.themeIndex == 1)
        {
            //print("Simple")
            sudokuBlocksGrid.changeColorScheme("ColorSchemeSimple.qml");
        }
        gridLoaded = true;
        //Settings.insertNewScore("Hamo","Hamić", "100")
        var allScores = Settings.getAllScores()
        for(var i = 0; i < allScores.length; i++) {
            var rowItem = allScores[i];
            //res.push[dbItem.first_name, dbItem.last_name, dbItem.score])
            //print("ROW ",rowItem[0])
            var firstName = Settings.getUserFirstName(rowItem[0])
            var lastName = Settings.getUserLastName(rowItem[0])
            //print(firstName, lastName)
            highscoresModel.append({'firstname': firstName,
                                       'lastname':  lastName,
                                       'score': rowItem[1] });
        }

        if(Settings.getSetting("currentUserId")=="Unknown")
            currentUserId = -1;
        else
        {
            currentUserId = Settings.getSetting("currentUserId")
        }
        if (difficultySelector.selectedIndex == 4) {
            PopupUtils.open(newGameComponent)
        }

    }

    Tabs {
        id: tabs
        anchors.fill: parent

        // First tab begins here
        Tab {
            id: mainTab;
            objectName: "MainTab"

            title: i18n.tr("Sudoku")

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
                    case 4:
                        PopupUtils.open(newGameComponent);
                        break;
                    }
                }

            }

            UbuntuShape {
                id: gameFinishedRectangle;
                color: sudokuBlocksGrid.defaultColor;
                //border.color: sudokuBlocksGrid.defaultBorderColor;
                width: units.gu(25);
                radius: "medium"
                height: units.gu(15);
                z: 100;
                visible: false;
                //x: mainView.width / 2 - width/2;
                //y: mainView.weight / 2 - height/2;
                //anchors.verticalCenter: mainView.verticalCenter;
                //anchors.horizontalCenter: mainView.verticalCenter;
                anchors.centerIn: parent;
                //y: units.gu(5);
                Label {
                    id: gameFinishedText;
                    text: sudokuBlocksGrid.checkIfCheating ? i18n.tr("You are a cheat...") : i18n.tr("Congratulations!")
                    color: sudokuBlocksGrid.defaultHintColor;
                    anchors.fill: parent;
                    fontSize: "large";
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            page: Page {

                tools: ToolbarItems {
                    opened: true
                    ToolbarButton {
                        objectName: "newgamebutton"
                        action: Action {
                            text: i18n.tr("New game");
                            iconSource: Qt.resolvedUrl("icons/new_game_ubuntu.svg")
                            onTriggered: {
                                if(gameFinishedRectangle.visible) gameFinishedRectangle.visible = false;
                                //print("new block distance:", blockDistance);
                                //createNewGame()
                                if (settingsTab.difficultyIndex == 4)
                                    PopupUtils.open(newGameComponent)
                                else
                                    createNewGame()
                            }
                        }
                    }
                    ToolbarButton {
                        objectName: "hintbutton"
                        action: Action {
                            id: revealHintAction
                            iconSource: Qt.resolvedUrl("icons/hint.svg")
                            text: i18n.tr("Show hint");
                            enabled: disableHints.checked;
                            onTriggered: {
                                revealHint()
                            }
                        }
                    }
                    /*
                    Action {
                        iconSource: Qt.resolvedUrl("icons/close.svg")
                        text: i18n.tr("Close");
                        onTriggered: Qt.quit()
                    }
                    */
                }

                //Column {
                //    id: mainColumn;
                //width: mainView.width;
                //height: mainView.height;
                //anchors.left: parent.left;
                //anchors.leftMargin: units.dp(3)
                //anchors.fill: parent
                //spacing: units.gu(5)

                SudokuBlocksGrid {
                    id: sudokuBlocksGrid;
                    objectName: "blockgrid"
                    //x: units.dp(3)
                    x: !mainView.wideAspect() ? 0.5*(mainView.width-9*sudokuBlocksGrid.blockSize-
                            22*sudokuBlocksGrid.blockDistance) :
                                     0.25*(mainView.width-9*sudokuBlocksGrid.blockSize-
                            22*sudokuBlocksGrid.blockDistance)

                    y: !mainView.wideAspect() ? units.gu(1) : mainView.height*0.05

                }

                Flow {
                    id: informationRow;
                    //y: 7*mainView.pageHeight/10;
                    //width: mainView.pageWidth - units.dp(8);
                    //anchors.horizontalCenter: parent.horizontalCenter
                    x: !mainView.wideAspect() ? 0.5*(mainView.width - width) :
                                                0.25*(mainView.width-9*sudokuBlocksGrid.blockSize-
                                       22*sudokuBlocksGrid.blockDistance)+9*sudokuBlocksGrid.blockSize + 35*sudokuBlocksGrid.blockDistance + units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: !mainView.wideAspect() ?
                                           9*sudokuBlocksGrid.blockSize + 35*sudokuBlocksGrid.blockDistance :
                                           mainView.height*0.15

                    //columns: !wideAspect ? 3 : 1
                    flow: !mainView.wideAspect() ? Flow.LeftToRight : Flow.TopToBottom
                    spacing: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/6 : units.gu(50)/6
                    UbuntuShape {
                        id: redFlag
                        color: sudokuBlocksGrid.defaultNotAllowedColor
                        width: mainView.width/mainView.height < mainView.resizeFactor ? 2*mainView.width/10: 2*units.gu(50)/10
                        height: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/10: units.gu(50)/10
                        //border.color: defaultBorderColor
                        //radius: "medium"
                        Label {
                            id: redFlagText
                            text: i18n.tr("Not allowed")
                            fontSize: "x-small"
                            width:units.gu(5);
                            wrapMode: TextEdit.WordWrap;
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent
                            //                                    anchors.left: redFlag.right;
                            //                                    anchors.leftMargin: units.dp(2);
                            //                                    anchors.verticalCenter: redFlag.verticalCenter;
                        }
                    }
                    UbuntuShape {
                        id: blueFlag
                        color: sudokuBlocksGrid.defaultStartingColor
                        //border.color: defaultBorderColor
                        width: mainView.width/mainView.height < mainView.resizeFactor ? 2*mainView.width/10: 2*units.gu(50)/10
                        height: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/10: units.gu(50)/10
                        //radius: "medium";
                        Label {
                            id: blueFlagText
                            text: i18n.tr("Start blocks")
                            fontSize: "x-small"
                            color: settingsTab.themeIndex == 0 ? "white" : "black"
                            width:units.gu(5);
                            wrapMode: TextEdit.WordWrap;
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent
                            //                                    anchors.left: blueFlag.right;
                            //                                    anchors.leftMargin: units.dp(2);
                            //                                    anchors.verticalCenter: blueFlag.verticalCenter;
                        }
                    }

                    UbuntuShape {
                        id: orangeFlag
                        color: sudokuBlocksGrid.defaultHintColor
                        //border.color: defaultBorderColor
                        width: mainView.width/mainView.height < mainView.resizeFactor ? 2*mainView.width/10: 2*units.gu(50)/10
                        height: mainView.width/mainView.height < mainView.resizeFactor ? mainView.width/10: units.gu(50)/10
                        //radius: "medium";
                        Label {
                            text: i18n.tr("Hinted blocks")
                            fontSize: "x-small"
                            width:units.gu(5);
                            wrapMode: TextEdit.WordWrap;
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent
                            //                                    anchors.left: orangeFlag.right;
                            //                                    anchors.leftMargin: units.dp(2);
                            //                                    anchors.verticalCenter: orangeFlag.verticalCenter;
                        }
                    }
                }

                //}
            }

        }

        // Highscores Tab

        Tab {
            id: highscoresTab
            objectName: "highscoresTab"
            title: i18n.tr("Scores")
            page: Page {
                tools: ToolbarItems {
                    ToolbarButton {
                        objectName: "allusersbutton"
                        action: Action {
                            text: "All\nusers"
                            iconSource: Qt.resolvedUrl("icons/all-users.svg")
                            onTriggered: {
                                var allScores = Settings.getAllScores()
                                highscoresModel.clear();
                                highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
                                for(var i = 0; i < allScores.length; i++) {
                                    var rowItem = allScores[i];
                                    //print("ROW ",rowItem)
                                    var firstName = Settings.getUserFirstName(rowItem[0]);
                                    var lastName = Settings.getUserLastName(rowItem[0]);
                                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                                    highscoresModel.append({'firstname': firstName,
                                                               'lastname':  lastName,
                                                               'score': rowItem[1] });
                                }
                            }
                        }
                    }
                    ToolbarButton {
                        objectName: "currentuserbutton"
                        action: Action {
                            text: "Current\nuser"
                            iconSource: Qt.resolvedUrl("icons/single-user.svg")
                            onTriggered: {
                                var firstName = Settings.getUserFirstName(currentUserId);
                                var lastName = Settings.getUserLastName(currentUserId);
                                //print(firstName, lastName)
                                highscoresHeaderText = i18n.tr("<b>Best scores for ")+firstName + " " + lastName+"</b>"
                                var allScores = Settings.getAllScoresForUser(currentUserId)
                                highscoresModel.clear();
                                for(var i = 0; i < allScores.length; i++) {
                                    var rowItem = allScores[i];
                                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                                    highscoresModel.append({'firstname': firstName,
                                                               'lastname':  lastName,
                                                               'score': rowItem[1] });
                                }
                            }
                        }
                    }
                    //locked: true
                    //opened: true
                }


                ListModel {
                    id: highscoresModel

                    onDataChanged: {
                        var allScores = Settings.getAllScores()
                        highscoresModel.clear();
                        highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
                        for(var i = 0; i < allScores.length; i++) {
                            var rowItem = allScores[i];
                            //print("ROW ",rowItem)
                            var firstName = Settings.getUserFirstName(rowItem[0]);
                            var lastName = Settings.getUserLastName(rowItem[0]);
                            //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                            highscoresModel.append({'firstname': firstName,
                                                       'lastname':  lastName,
                                                       'score': rowItem[1] });
                        }
                    }

                    /*ListElement {
                        firstname: "Bill"
                        lastname: "Smith"
                        score: "120"
                    }
                    ListElement {
                        firstname: "John"
                        lastname: "Brown"
                        score: "130"
                    }*/
                }
                Column {
                    anchors.fill: parent
                    clip: true
                    ListView {
                        id: highScoresListView
                        model: highscoresModel
                        width: parent.width
                        height:parent.height                        

                        header: ListItem.Header {
                            id: highscoresHeader
                            objectName: "highscoreslabel"
                            text: highscoresHeaderText
                        }
                        delegate: ListItem.SingleValue {
                            text: firstname + " " + lastname
                            value: score
                        }
                    }
                }
            }


        }



        // settingsTab
        Tab {
            id: settingsTab;
            objectName: "settingsTab"

            property alias disableHintsChecked: disableHints.checked;
            property alias disableVibrationsChecked: disableVibrations.checked;
            property alias difficultyIndex: difficultySelector.selectedIndex;
            property alias themeIndex: themeSelector.selectedIndex;



            title: i18n.tr("Settings")
            page:

                Page {

                Column {

                    Component {
                        id: profileSelector
                        Dialog  {
                            title: i18n.tr("Select profile")



                            Column{
                                height: mainColumnSettings.height*2/3
                                ListView {

                                    id: profileListView
                                    clip: true
                                    width: parent.width
                                    height: parent.height - units.gu(12)
                                    model: profilesModel

                                    delegate:
                                        ListItem.Standard {
                                        __foregroundColor: "white"
                                        text: firstname + " " + lastname
                                        progression: true
                                        onTriggered: {
                                            //console.log("clicked "+index)
                                            currentUserId = profileId;
                                            hide()
                                        }
                                    }

                                }

                                SudokuDialogButton{

                                    anchors.horizontalCenter: parent.horizontalCenter
                                    id:cancelButton
                                    buttonText: i18n.tr("Cancel")
                                    width: parent.width/2;
                                    size: units.gu(5)
                                    buttonColor: sudokuBlocksGrid.dialogButtonColor1
                                    textColor: sudokuBlocksGrid.dialogButtonTextColor
                                    //border.color: "transparent"
                                    onTriggered: {
                                        hide()
                                    }
                                }

                            }
                        }
                    }

                    Component {
                        id: manageProfileSelector
                        Dialog {
                            title: i18n.tr("Select profile")

                            Column{
                                height: mainColumnSettings.height*2/3
                                ListView {
                                    id: manageProfileListView
                                    clip: true
                                    width: parent.width
                                    height: parent.height - units.gu(12)
                                    model: profilesModel

                                    delegate:

                                        ListItem.Standard {
                                        __foregroundColor: "white"
                                        text: firstname + " " + lastname

                                        progression: true
                                        onTriggered: {
                                            hide()
                                            editUserId = profileId
                                            PopupUtils.open(manageProfileDialog, selectorProfile)
                                        }
                                    }



                                }
                                SudokuDialogButton{

                                    anchors.horizontalCenter: parent.horizontalCenter
                                    id:cancelButton
                                    buttonText: i18n.tr("Cancel")
                                    width: parent.width/2;
                                    size: units.gu(5)
                                    buttonColor: sudokuBlocksGrid.dialogButtonColor1
                                    textColor: sudokuBlocksGrid.dialogButtonTextColor
                                    //border.color: "transparent"
                                    onTriggered: {
                                        hide()
                                    }
                                }
                            }
                        }
                    }

                    ListModel{
                        id: profilesModel
                    }

                    id: mainColumnSettings;
                    //width: settingsTab.width;
                    //height: settingsTab.height;
                    anchors.fill: parent
                    //anchors.horizontalCenter: parent.horizontalCenter;
                    spacing: units.gu(1)

                    ListItem.Header {
                        text: i18n.tr("<b>Sudoku settings</b>")
                    }

                    ListItem.ValueSelector {
                        objectName: "difficultySelector"
                        id: difficultySelector
                        text: i18n.tr("Default Difficulty")
                        values: [i18n.tr("Easy"), i18n.tr("Moderate"), i18n.tr("Hard"), i18n.tr("Ultra Hard"), i18n.tr("Always ask")]
                        onSelectedIndexChanged: {
                            //print(difficultySelector.selectedIndex)
                            switch(difficultySelector.selectedIndex) {
                            case 0:
                                var randomnumber = Math.floor(Math.random()*9);
                                randomnumber += 31;
                                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                                Settings.setSetting("Difficulty", selectedIndex)
                                break;
                            case 1:
                                var randomnumber = Math.floor(Math.random()*4);
                                randomnumber += 26;
                                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                                Settings.setSetting("Difficulty", selectedIndex)
                                break;
                            case 2:
                                var randomnumber = Math.floor(Math.random()*4);
                                randomnumber += 21;
                                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                                Settings.setSetting("Difficulty", selectedIndex)
                                break;
                            case 3:
                                var randomnumber = Math.floor(Math.random()*3);
                                randomnumber += 17;
                                sudokuBlocksGrid.createNewGame(81 - randomnumber);
                                Settings.setSetting("Difficulty", selectedIndex)
                                break;
                            case 4:
                                Settings.setSetting("Difficulty", selectedIndex)
                                break;
                            }
                        }

                    }
                    ListItem.ValueSelector {
                        objectName: "themeSelector"
                        id: themeSelector
                        text: i18n.tr("Theme")
                        values: ["UbuntuColours", "Simple"]
                        onSelectedIndexChanged: {
                            var newColorScheme = null;
                            if (selectedIndex == 0)
                            {
                                //print("Ubuntu")
                                var result = Settings.setSetting("ColorTheme", selectedIndex);
                                //print(result);
                                sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
                            }
                            if (selectedIndex == 1)
                            {
                                //print("Simple")
                                var result = Settings.setSetting("ColorTheme", selectedIndex);
                                //print(result);
                                sudokuBlocksGrid.changeColorScheme("ColorSchemeSimple.qml");
                            }
                        }
                    }

                    ListItem.Standard {
                        objectName: "hintsSwitchClickable"
                        text: i18n.tr("Hints")
                        width: parent.width
                        control: Switch {
                            objectName: "hintsSwitch"
                            id: disableHints
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            checked: disableHintsChecked
                            onCheckedChanged: {
                                var result = Settings.setSetting("DisableHints", checked ? "true":"false");
                                //print(result);
                            }
                        }
                    }
                    ListItem.Standard {
                        objectName: "vibrationsSwitchClickable"
                        text: i18n.tr("Vibration Alerts")
                        width: parent.width
                        control: Switch {
                            objectName: "vibrationsSwitch"
                            id: disableVibrations
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            checked: disableVibrationsChecked
                            onCheckedChanged: {
                                var result = Settings.setSetting("DisableVibrations", checked ? "true":"false");
                                //print(result);
                            }
                        }
                    }
                    ListItem.Header {
                        text: i18n.tr("<b>Profiles settings</b>")
                    }
                    ListItem.SingleValue {
                        objectName: "Current profile"
                        text: "Current profile"
                        id: selectorProfile
                        value: {
                            if(currentUserId==-1)
                                return i18n.tr("None")
                            else
                                return Settings.getUserFirstName(currentUserId)+" "+Settings.getUserLastName(currentUserId);

                        }

                        onClicked: {

                            var allProfiles = new Array();
                            allProfiles = Settings.getAllProfiles()

                            profilesModel.clear()

                            for(var i = 0; i < allProfiles.length; i++)
                            {
                                profilesModel.append({"profileId":allProfiles[i].id,"lastname":allProfiles[i].lastname, "firstname":allProfiles[i].firstname})
                            }
                            PopupUtils.open(profileSelector, selectorProfile)
                        }
                    }

                    AddProfileDialog{
                        id:addProfileDialog
                    }

                    ManageProfileDialog{
                        id:manageProfileDialog
                    }


                    ListItem.SingleValue {
                        objectName: "Add profile"
                        id:addSingleValue
                        text: i18n.tr("Add profile")
                        onClicked: {
                            PopupUtils.open(addProfileDialog, addSingleValue);
                        }
                    }

                    ListItem.SingleValue {
                        objectName: "Manage profiles"
                        id:manageProfileSingleValue
                        text: i18n.tr("Manage profiles")
                        onClicked: {

                            var allProfiles = new Array();
                            allProfiles = Settings.getAllProfiles()

                            profilesModel.clear()

                            for(var i = 0; i < allProfiles.length; i++)
                            {
                                profilesModel.append({"profileId":allProfiles[i].id,"lastname":allProfiles[i].lastname, "firstname":allProfiles[i].firstname})
                            }

                            PopupUtils.open(manageProfileSelector, manageProfileSingleValue)
                        }
                    }


                }
            }


        }

        Tab {
            id: aboutTab;
            objectName: "aboutTab"
            title: i18n.tr("About")

            page: Page {
                Layouts {
                    id: aboutTabLayout
                    width: parent.width
                    height: parent.height
                    layouts: [
                        ConditionalLayout {
                            name: "tablet"
                            when: mainView.width > units.gu(80)
                            Row {
                                anchors {
                                    //top: parent
                                    left: parent.left
                                    leftMargin: mainView.width*0.1
                                    top: parent.top
                                    topMargin: mainView.height*0.2

                                }
                                spacing: units.gu(5)
                                ItemLayout {
                                    item: "icon"
                                    id: iconTabletItem
                                    property real maxWidth: units.gu(80)
                                    width: Math.min(parent.width, maxWidth)/2
                                    height: Math.min(parent.width, maxWidth)/2

                                }
                                Column {
                                    //height: iconTabletItem.height
                                    spacing: 1
                                    ItemLayout {
                                        item: "info"
                                        width: aboutTabLayout.width*0.25
                                        height: iconTabletItem.height*0.75
                                    }
                                    ItemLayout {
                                        item: "link"
                                        width: aboutTabLayout.width*0.25
                                        height: units.gu(3)
                                    }
                                    ItemLayout {
                                        item: "version"
                                        width: aboutTabLayout.width*0.25
                                        height: units.gu(2)
                                    }
                                    ItemLayout {
                                        item: "year"
                                        width: aboutTabLayout.width*0.25
                                        height: units.gu(2)
                                    }
                                }
                            }
                        }


                    ]

                    Column {
                        id: aboutColumn;
                        spacing: units.gu(3)
                        //anchors.fill: parent
                        //anchors.horizontalCenter: parent.horizontalCenter;
                        width: parent.width
                        y: units.gu(6);
                        UbuntuShape {
                            Layouts.item: "icon"
                            property real maxWidth: units.gu(45)
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min(parent.width, maxWidth)/2
                            height: Math.min(parent.width, maxWidth)/2
                            image: Image {
                                objectName: "aboutImage"
                                //height: width
                                source: "icons/about.png"
                                smooth: true
                                fillMode: Image.PreserveAspectFit

                            }
                        }
                        Grid {
                            anchors.horizontalCenter: parent.horizontalCenter
                            columns: 2
                            rowSpacing: units.gu(2)
                            columnSpacing: mainView.width/10
                            Layouts.item: "info"
                            Label {
                                objectName: "authorLabel"
                                text: i18n.tr("Author(s): ")

                            }
                            Label {
                                objectName: "authors"
                                font.bold: true;
                                text: "Dinko Osmankovi\u0107 \nFr\u00e9d\u00e9ric Delgado \nGeorgi Karavasilev \nSam Hewitt"
                            }
                            Label {
                                objectName: "contactLabel"
                                text: i18n.tr("Contact: ")
                            }
                            Label {
                                objectName: "contacts"
                                font.bold: true;
                                text: "dinko.metalac@gmail.com"
                            }

                        }

                        Row {
                            id: homepage;
                            anchors.horizontalCenter: parent.horizontalCenter;
                            Layouts.item: "link"
                            Label {
                                objectName: "urlLabel"
                                font.bold: true;
                                text: "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>"
                                onLinkActivated: Qt.openUrlExternally(link)
                            }
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter;
                            Layouts.item: "version"
                            Label {
                                objectName: "versionLabel"
                                text: i18n.tr("Version: ")
                            }
                            Label {
                                objectName: "version"
                                font.bold: true;
                                text: "1.5"
                            }
                        }
                        Row {
                            Layouts.item: "year"
                            anchors.horizontalCenter: parent.horizontalCenter;
                            Label {
                                objectName: "yearLabel"
                                font.bold: true;
                                text: "2013"


                            }
                        }
                    }

                }
            }
        }
    }
}
