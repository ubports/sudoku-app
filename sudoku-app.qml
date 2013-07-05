import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.LocalStorage 2.0
import "js/localStorage.js" as Settings
import "components"

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "sudoku"
    applicationName: "sudoku-app"

    property real pageWidth: units.gu(40);
    property real pageHeight: units.gu(71);

    property real blockDistance: pageWidth/200;
    property bool alreadyCreated: false;
    property bool gridLoaded: false;
    property int currentUserId: 1;
    property string highscoresHeaderText: i18n.tr("Best scores for all players")

    width: pageWidth;
    height: pageHeight;

    function newSize(width, height) {
        pageWidth = width;
        pageHeight = height;
        print(height," x ", width);
    }

    function updateGrid() {
        print("Updating grid");
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

    onHeightChanged: {
        if (!gridLoaded)
            return;
        newSize(mainView.width, mainView.height);

        //sudokuBlocksGrid = Qt.createComponent(Qt.resolvedUrl("SudokuBlocksGrid.qml"))
    }

    Component.onCompleted: {
        Settings.initialize();
        settingsTab.difficultyIndex = parseInt(Settings.getSetting("Difficulty"));
        //print(Settings.getSetting("DisableHints"));
        settingsTab.disableHintsChecked = Settings.getSetting("DisableHints") == "true" ? true: false;
        settingsTab.themeIndex = parseInt(Settings.getSetting("ColorTheme"));
        print(Settings.getSetting("ColorTheme"));
        var newColorScheme = null;
        if (settingsTab.themeIndex == 0)
        {
            print("Ubuntu")
            sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
        }
        if (settingsTab.themeIndex == 1)
        {
            print("Simple")
            sudokuBlocksGrid.changeColorScheme("ColorSchemeSimple.qml");
        }
        gridLoaded = true;
        //Settings.insertNewScore("Hamo","Hamić", "100")
        var allScores = Settings.getAllScores()
        for(var i = 0; i < allScores.length; i++) {
            var rowItem = allScores[i];
            //res.push[dbItem.first_name, dbItem.last_name, dbItem.score])
            print("ROW ",rowItem[0])
            var firstName = Settings.getUserFirstName(rowItem[0])
            var lastName = Settings.getUserLastName(rowItem[0])
            print(firstName, lastName)
            highscoresModel.append({'firstname': firstName,
                                       'lastname':  lastName,
                                       'score': rowItem[1] });
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
                    }
                }

            }

            Rectangle {
                id: gameFinishedRectangle;
                color: sudokuBlocksGrid.defaultColor;
                border.color: sudokuBlocksGrid.defaultBorderColor;
                width: units.gu(25);
                radius: 5
                height: units.gu(15);
                z: 100;
                visible: false;
                x: mainView.pageWidth / 2 - width/2;
                y: mainView.pageHeight / 2 - height/2;
                //anchors.verticalCenter: mainView.verticalCenter;
                //anchors.horizontalCenter: mainView.verticalCenter;
                //anchors.centerIn: mainView;
                //y: units.gu(5);
                Label {
                    id: gameFinishedText;
                    text: sudokuBlocksGrid.checkIfCheating ? i18n.tr("You are a cheat...") : i18n.tr("Congratulations!")
                    color: sudokuBlocksGrid.defaultHintColor;
                    anchors.centerIn: parent;
                    fontSize: "large";
                }
            }

            page: Page {

                tools: ToolbarActions {
                    Action {
                        text: i18n.tr("New game");
                        iconSource: Qt.resolvedUrl("icons/new_game_ubuntu.svg")
                        onTriggered: {
                            print("new block distance:", blockDistance);
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
                    Action {
                        iconSource: Qt.resolvedUrl("icons/hint.svg")
                        text: i18n.tr("Show hint");
                        enabled: disableHints.checked;
                        onTriggered: {
                            if(enabled)
                            {
                                sudokuBlocksGrid.revealHint();
                                sudokuBlocksGrid.checkIfCheating = true;
                                if (sudokuBlocksGrid.checkIfGameFinished()) {
                                    gameFinishedRectangle.visible = true;
                                    gameFinishedText.text = i18n.tr("You are a cheat... \nBut we give you\n")
                                            + sudokuBlocksGrid.calculateScore()
                                            + " " + i18n.tr("points.")

                                    print (sudokuBlocksGrid.numberOfActions)
                                    print (sudokuBlocksGrid.numberOfHints)
                                    print (sudokuBlocksGrid.gameSeconds)
                                    print (sudokuBlocksGrid.gameDifficulty)
                                    winTimer.restart();
                                }
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

                Column {
                    id: mainColumn;
                    //width: mainView.width;
                    //height: mainView.height;
                    anchors.left: parent.left;
                    spacing: units.gu(5)

                    SudokuBlocksGrid {
                        id: sudokuBlocksGrid;
                    }
                }
            }

        }

        // Highscores Tab

        Tab {
            id: highscoresTab
            objectName: "highscoresTab"
            title: i18n.tr("Best Scores")
            page: Page {
                tools: ToolbarItems {
                    ToolbarButton {
                        action: Action {
                            text: "All\nusers"
                            iconSource: Qt.resolvedUrl("icons/all-users.svg")
                            onTriggered: {
                                var allScores = Settings.getAllScores()
                                highscoresModel.clear();
                                highscoresHeaderText = i18n.tr("Best scores for all players");
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
                        }
                    }
                    ToolbarButton {
                        action: Action {
                            text: "Current\nuser"
                            iconSource: Qt.resolvedUrl("icons/single-user.svg")
                            onTriggered: {
                                var firstName = Settings.getUserFirstName(currentUserId);
                                var lastName = Settings.getUserLastName(currentUserId);
                                print(firstName, lastName)
                                highscoresHeaderText = i18n.tr("Best scores for ")+firstName + " " + lastName
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
                    ListView {
                        model: highscoresModel
                        anchors.fill: parent
                        header: ListItem.Header {
                            id: highscoresHeader
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
            property alias difficultyIndex: difficultySelector.selectedIndex;
            property alias themeIndex: themeSelector.selectedIndex;

            title: i18n.tr("Settings")
            page: Page {
                /*
                tools: ToolbarActions {

                    Action {
                        iconSource: Qt.resolvedUrl("icons/close.svg")
                        text: i18n.tr("Close");
                        onTriggered: Qt.quit()
                    }
                }
                */
                Column {
                    id: mainColumnSettings;
                    //width: settingsTab.width;
                    //height: settingsTab.height;
                    anchors.fill: parent
                    //anchors.horizontalCenter: parent.horizontalCenter;
                    spacing: units.gu(1)

                    ListItem.Header {
                        text: i18n.tr("Sudoku settings")
                    }

                    ListItem.ValueSelector {
                        id: difficultySelector
                        text: i18n.tr("Difficulty")
                        values: [i18n.tr("Easy"), i18n.tr("Moderate"), i18n.tr("Hard"), i18n.tr("Ultra Hard")]
                        onSelectedIndexChanged: {
                            print(difficultySelector.selectedIndex)
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
                            }
                        }

                    }
                    ListItem.ValueSelector {
                        id: themeSelector
                        text: i18n.tr("Theme")
                        values: ["UbuntuColours", "Simple"]
                        onSelectedIndexChanged: {
                            var newColorScheme = null;
                            if (selectedIndex == 0)
                            {
                                print("Ubuntu")
                                var result = Settings.setSetting("ColorTheme", selectedIndex);
                                print(result);
                                sudokuBlocksGrid.changeColorScheme("ColorSchemeUbuntu.qml");
                            }
                            if (selectedIndex == 1)
                            {
                                print("Simple")
                                var result = Settings.setSetting("ColorTheme", selectedIndex);
                                print(result);
                                sudokuBlocksGrid.changeColorScheme("ColorSchemeSimple.qml");
                            }
                        }
                    }

                    ListItem.Standard {
                        text: i18n.tr("Hints")
                        width: parent.width
                        control: Switch {
                            id: disableHints
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            checked: disableHintsChecked
                            onCheckedChanged: {
                                var result = Settings.setSetting("DisableHints", checked ? "true":"false");
                                print(result);
                            }
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
                /*
                tools: ToolbarActions {


                    Action {
                        iconSource: Qt.resolvedUrl("icons/close.svg");
                        text: i18n.tr("Close");
                        onTriggered: Qt.quit()
                    }

                }
                */
                Column {
                    id: aboutColumn;
                    spacing: 5;
                    //anchors.fill: parent
                    anchors.horizontalCenter: parent.horizontalCenter;
                    y: units.gu(8);
                    Rectangle {
                        radius: 10
                        height: units.gu(20)
                        width: units.gu(20)
                        anchors.horizontalCenter: parent.horizontalCenter;

                        Image {
                            source: "icons/SudokuGameIcon.svg"
                            smooth: true
                            fillMode: Image.PreserveAspectCrop
                            height: units.gu(20)
                            width: units.gu(20)
                            anchors.centerIn: parent

                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        Label {
                            text: i18n.tr("Author(s): ")
                        }
                        Label {
                            font.bold: true;
                            text: "Dinko Osmankovic\nFrédéric Delgado"
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        Label {
                            text: i18n.tr("Contact: ")
                        }
                        Label {
                            font.bold: true;
                            text: "dinko.metalac@gmail.com\nfredoust@gmail.com"
                        }
                    }
                    Row {
                        id: homepage;
                        anchors.horizontalCenter: parent.horizontalCenter;
                        Label {
                            font.bold: true;
                            text: "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>"
                            onLinkActivated: Qt.openUrlExternally(link)
                        }
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter;
                    anchors.top: aboutColumn.bottom;
                    anchors.topMargin: units.gu(5);
                    Label {
                        text: i18n.tr("Version: ")
                    }
                    Label {
                        font.bold: true;
                        text: "0.4"
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter;
                    anchors.top: aboutColumn.bottom;
                    anchors.topMargin: units.gu(8);
                    Label {
                        font.bold: true;
                        text: "2013"
                    }
                }
            }
        }
    }
}
