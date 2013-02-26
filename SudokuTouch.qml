import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.LocalStorage 2.0
import "localStorage.js" as Settings

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "Sudoku Touch"
    applicationName: "SudokuTouch"

    property int pageWidth: 50;
    property int pageHeight: 75;
    
    width: units.gu(pageWidth)
    height: units.gu(pageHeight)

    Component.onCompleted: {
        Settings.initialize();
        settingsTab.difficultyIndex = parseInt(Settings.getSetting("Difficulty"));
        print(Settings.getSetting("DisableHints"));
        settingsTab.disableHintsChecked = Settings.getSetting("DisableHints") == "true" ? true: false;
    }

    Tabs {
        id: tabs
        anchors.fill: parent

        // First tab begins here
        Tab {
            id: mainTab;
            objectName: "MainTab"

            title: i18n.tr("SudokuTouch Game")

            Rectangle {
                id: gameFinishedRectangle;
                color: "#AEA79F";
                width: units.gu(25);
                radius: 5
                height: units.gu(15);
                z: 100;
                visible: false;
                //x: units.gu(mainView.pageWidth / 2)
                //y: units.gu(mainView.pageHeight / 2)
                anchors.verticalCenter: sudokuBlocksGrid.verticalCenter;
                anchors.horizontalCenter: parent.horizontalCenter;
                y: units.gu(5);
                Text {
                    id: gameFinishedText;
                    text: "Congratulations!"
                    color: sudokuBlocksGrid.defaultHintColor;
                    anchors.centerIn: parent;
                    font.pointSize: 14;
                }
            }

            page: Page {

                tools: ToolbarActions {
                    Action {
                        text: i18n.tr("New game");
                        iconSource: Qt.resolvedUrl("icons/new_game.png")
                        onTriggered: {
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
                        iconSource: Qt.resolvedUrl("icons/hint.png")
                        text: i18n.tr("Show hint");
                        enabled: !disableHints.checked;
                        onTriggered: {
                            print("Fuck you for now!")
                        }
                    }
                    Action {
                        iconSource: Qt.resolvedUrl("icons/exit.png")
                        text: i18n.tr("Close");
                        onTriggered: Qt.quit()
                    }
                }

                Column {
                    id: mainColumn;
                    //width: mainView.width;
                    //height: mainView.height;
                    anchors.left: parent.left;
                    spacing: units.gu(5)

                    SudokuBlocksGrid {
                        id: sudokuBlocksGrid;

                        NumberPickGrid {
                            id: numberPickGrid;
                            visible: false;
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

            title: i18n.tr("Settings")
            page: Page {
                Column {
                    id: mainColumnSettings;
                    //width: settingsTab.width;
                    //height: settingsTab.height;
                    anchors.fill: parent
                    //anchors.horizontalCenter: parent.horizontalCenter;
                    spacing: units.gu(5)

                    ListItem.ValueSelector {
                        id: difficultySelector
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(5)
                        text: "Difficulty"
                        values: ["Easy", "Moderate", "Hard", "Ultra Hard"]
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
                    Row {
                        id: disableHintsRow
                        anchors.top: difficultySelector.bottom
                        anchors.topMargin: units.gu(2)
                        anchors.leftMargin: units.gu(2)
                        width: parent.width
                        Text {
                            id: disableHintsText
                            anchors.left: parent.left
                            anchors.leftMargin: units.dp(20)
                            text: "Disable hints"
                            font.pointSize: 11
                            font.family: "Ubuntu"
                            color: "#333333"
                        }
                        Switch {
                            id: disableHints
                            checked: disableHintsChecked
                            anchors.right: disableHintsRow.right
                            anchors.rightMargin: units.dp(25)
                            anchors.verticalCenter: disableHintsText.verticalCenter
                            onCheckedChanged: {
                                var result = Settings.setSetting("DisableHints", checked ? "true":"false");
                                print(result);
                            }
                        }
                    }
                }
            }

        }
    }
}
