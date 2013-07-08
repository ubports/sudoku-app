import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 0.1
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
    property int currentUserId: -1;
    property string highscoresHeaderText: i18n.tr("<b>Best scores for all players</b>")

    property string alertTitle: ""
    property string alertText : ""

    property int editUserId : -1;

    width: pageWidth;
    height: pageHeight;

    onCurrentUserIdChanged: {
        Settings.setSetting("currentUserId", currentUserId)
    }

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

    function showAlert(title, text, caller)
    {
        alertTitle = title
        alertText = text
        PopupUtils.open(alertDialog, caller)

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

        if(Settings.getSetting("currentUserId")=="Unknown")
            currentUserId = -1;
        else
        {
            currentUserId = Settings.getSetting("currentUserId")
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
                                    Settings.insertNewScore(currentUserId, sudokuBlocksGrid.calculateScore())
                                    gameFinishedText.text = i18n.tr("You are a cheat... \nBut we give you\n")
                                            + sudokuBlocksGrid.calculateScore()
                                            + " " + i18n.tr("points.")

                                    print (sudokuBlocksGrid.numberOfActions)
                                    print (sudokuBlocksGrid.numberOfHints)
                                    print (sudokuBlocksGrid.gameSeconds)
                                    print (sudokuBlocksGrid.gameDifficulty)
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
            page:

                Page {

                Column {

                    Component {
                        id: profileSelector
                        Popover {
                            Column {
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                                height: mainColumnSettings.height
                                ListItem.Header {
                                    id: header
                                    text: i18n.tr("Select profile")
                                }



                                ListView {
                                    id: profileListView
                                    clip: true
                                    width: parent.width
                                    height: parent.height - header.height
                                    model: profilesModel

                                    delegate:

                                        ListItem.Standard {
                                        text: firstname + " " + lastname
 progression: true
                                        onTriggered: {
                                            console.log("clicked "+index)
                                            currentUserId = profileId;
                                            hide()
                                        }
                                    }

                                }
                            }
                        }
                    }

                    Component {
                        id: manageProfileSelector
                        Popover {
                            Column {
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                                height: mainColumnSettings.height
                                ListItem.Header {
                                    id: header
                                    text: i18n.tr("Manage profile")
                                }
                                ListView {
                                    id: manageProfileListView
                                    clip: true
                                    width: parent.width
                                    height: parent.height - header.height
                                    model: profilesModel

                                    delegate:

                                        ListItem.Standard {
                                        text: firstname + " " + lastname
 progression: true
                                        onTriggered: {
                                            hide()
                                            editUserId = profileId
                                            PopupUtils.open(manageProfileDialog, selectorProfile)
                                        }
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
                    ListItem.Header {
                        text: i18n.tr("<b>Profiles settings</b>")
                    }
                    ListItem.SingleValue {
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
                        id:addSingleValue
                        text: i18n.tr("Add profile")
                        onClicked: {
                            PopupUtils.open(addProfileDialog, addSingleValue);
                        }
                    }

                    ListItem.SingleValue {
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

                Column {
                    id: aboutColumn;
                    spacing: 5;
                    //anchors.fill: parent
                    anchors.horizontalCenter: parent.horizontalCenter;
                    y: units.gu(8);
                    Image {
                        property real maxWidth: units.gu(100)
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(mainView.width, maxWidth)/1.75
                        //height: width
                        source: "icons/sudoko-vector-about.svg"
                        smooth: true
                        fillMode: Image.PreserveAspectFit

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
