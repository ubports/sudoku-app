import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.Layouts 1.0
import "js/localStorage.js" as Settings
import "components"
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
    StateSaver.properties: "width, height"

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
            //print("ROW ",rowItem)
            var firstName = Settings.getUserFirstName(rowItem[1]);
            var lastName = Settings.getUserLastName(rowItem[1]);
            //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
            /*highscoresModel.append({'firstname': firstName,
                                       'lastname':  lastName,
                                       'score': rowItem[1] });*/
            hsPage.appendModel({ 'id': rowItem[0],
                              'firstname': firstName,
                              'lastname':  lastName,
                              'score': rowItem[2] });

        }
    }

    function revealHint() {
        if(settingsTab.disableHintsChecked)
        {
            sudokuBlocksGrid.revealHint();
            sudokuBlocksGrid.checkIfCheating = true;
            if (sudokuBlocksGrid.checkIfGameFinished()) {
                gameFinishedRectangle.visible = true;
                Settings.insertNewScore(currentUserId, sudokuBlocksGrid.calculateScore())
                gameFinishedText.text = i18n.tr("You are a cheat... \nBut we give you\n")
                        + sudokuBlocksGrid.calculateScore()
                        + " " + i18n.tr("point.","points.",1)

                var allScores = Settings.getAllScores()
                //highscoresModel.clear();
                hsPage.clearModel()
                highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
                for(var i = 0; i < allScores.length; i++) {
                    var rowItem = allScores[i];
                    //(print("ROW ",rowItem)
                    var firstName = Settings.getUserFirstName(rowItem[1]);
                    var lastName = Settings.getUserLastName(rowItem[1]);
                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                    /*highscoresModel.append({'firstname': firstName,
                                               'lastname':  lastName,
                                               'score': rowItem[1] });*/
                    hsPage.appendModel({ 'id': rowItem[0],
                                      'firstname': firstName,
                                      'lastname':  lastName,
                                      'score': rowItem[2] });
                }

                winTimer.restart();
            }
        }
    }

    function createNewGame() {
        switch(settingsTab.difficultyIndex) {
        case 0:
            var randomnumber = Math.floor(Math.random()*9);
            randomnumber += 31;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            sudokuBlocksGrid.gameDifficulty = 0
            break;
        case 1:
            var randomnumber = Math.floor(Math.random()*4);
            randomnumber += 26;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            sudokuBlocksGrid.gameDifficulty = 1
            break;
        case 2:
            var randomnumber = Math.floor(Math.random()*4);
            randomnumber += 21;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            sudokuBlocksGrid.gameDifficulty = 2
            break;
        case 3:
            var randomnumber = Math.floor(Math.random()*3);
            randomnumber += 17;
            sudokuBlocksGrid.createNewGame(81 - randomnumber);
            sudokuBlocksGrid.gameDifficulty = 3
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
                buttonColor: sudokuBlocksGrid.dialogButtonColor2
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
        if (settingsTab.difficultyIndex < 0)
            settingsTab.difficultyIndex = 0
        //print(settingsTab.difficultyIndex)
        //print(Settings.getSetting("settingsTab.disableHints"));
        settingsTab.disableHintsChecked = Settings.getSetting("DisableHints") == "true" ? true : false;
        settingsTab.disableVibrationsChecked = Settings.getSetting("DisableVibrations") == "true" ? true : false;
        settingsTab.themeIndex = parseInt(Settings.getSetting("ColorTheme"));
        //print(Settings.getSetting("ColorTheme"));
        var newColorScheme = null;
        if (Settings.getSetting("ColorTheme") == "Unknown") {
            sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
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
            var firstName = Settings.getUserFirstName(rowItem[1])
            var lastName = Settings.getUserLastName(rowItem[1])
            //print(firstName, lastName)
            /*highscoresModel.append({'firstname': firstName,
                                       'lastname':  lastName,
                                       'score': rowItem[1] });*/
            hsPage.appendModel({ 'id': rowItem[0],
                                   'firstname': firstName,
                                   'lastname':  lastName,
                                   'score': rowItem[2] })
        }

        if(Settings.getSetting("currentUserId")=="Unknown")
            currentUserId = 1;
        else
        {
            currentUserId = Settings.getSetting("currentUserId")
        }
        if (settingsTab.difficultyIndex === 4) {
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
                    switch(settingsTab.difficultyIndex) {
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
                backgroundColor: "black";
                opacity: 0.8
                width: mainView.width
                radius: "medium"
                height: mainView.height*1.3
                z: 100;
                visible: false;
                anchors.centerIn: parent;
                //y: units.gu(5);
                Label {
                    id: gameFinishedText;
                    text: sudokuBlocksGrid.checkIfCheating ? i18n.tr("You are a cheat...") : i18n.tr("Congratulations!")
                    color: sudokuBlocksGrid.defaultTextColor;
                    anchors.fill: parent;
                    fontSize: "x-large";
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            page: Page {

                BottomEdgeSlide {
                    z:2
                    hintIconName: "help-contents"
                }

                head.actions: [
                    Action {
                        objectName: "newgamebutton"
                        text: i18n.tr("New game");
                        iconSource: Qt.resolvedUrl("icons/new_game_ubuntu.svg")
                        onTriggered: {
                            if(gameFinishedRectangle.visible) gameFinishedRectangle.visible = false;
                            //createNewGame()
                            if (settingsTab.difficultyIndex == 4)
                            PopupUtils.open(newGameComponent)
                            else {
                                createNewGame()
                            }
                        }
                    },
                    Action {
                        objectName: "hintbutton"
                        id: revealHintAction
                        iconSource: Qt.resolvedUrl("icons/hint.svg")
                        text: i18n.tr("Show hint");
                        enabled: settingsTab.disableHintsChecked
                        onTriggered: {
                            revealHint()
                        }
                    }
                ]

                SudokuBlocksGrid {
                    id: sudokuBlocksGrid;
                    objectName: "blockgrid"
                    x: !mainView.wideAspect() ? 0.5*(mainView.width-9*sudokuBlocksGrid.blockSize-
                                                     22*sudokuBlocksGrid.blockDistance) :
                                                0.25*(mainView.width-9*sudokuBlocksGrid.blockSize-
                                                      22*sudokuBlocksGrid.blockDistance)

                    y: !mainView.wideAspect() ? units.gu(1) : mainView.height*0.05

                }
            }
        }

        // Highscores Tab
        Tab {
            id: highscoresTab
            objectName: "highscoresTab"
            title: i18n.tr("Scores")
            page: HighscoresTab { id: hsPage }
        }

        // settingsTab
        SettingsTab {
            id: settingsTab
        }

        AboutTab {
            id: aboutTab
            objectName: "aboutTab"
            title: i18n.tr("About")
        }
    }
}
