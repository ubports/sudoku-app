import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.Layouts 1.0
import "../js/localStorage.js" as Settings

Tab {
    id: settingsTab;
    objectName: "settingsTab"

    title: i18n.tr("Settings")
    
    property alias disableHintsChecked: disableHints.checked;
    property alias disableVibrationsChecked: disableVibrations.checked;
    property alias difficultyIndex: difficultySelector.selectedIndex;
    property alias themeIndex: themeSelector.selectedIndex;
    
    page: Page {
        id: settingsPage
        objectName: "settingsPage"
        
        anchors.fill: parent
        
        Component {
            id: profileSelector
            Dialog  {
                objectName: "selectProfileDialog"
                title: i18n.tr("Select profile")
                
                Column{
                    height: mainColumnSettings.height*2/3
                    ListView {
                        
                        id: profileListView
                        objectName: "profileListView"
                        clip: true
                        width: parent.width
                        height: parent.height - units.gu(12)
                        model: profilesModel
                        
                        delegate: ListItem {
                            height: selectProfileLayout.height + divider.height
                            ListItemLayout {
                                id: selectProfileLayout
                                title.text: firstname + " " + lastname
                                ProgressionSlot {}
                            }
                            onClicked: {
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
                objectName: "manageProfileDialog"
                title: i18n.tr("Select profile")
                
                Column{
                    height: mainColumnSettings.height*2/3
                    ListView {
                        id: manageProfileListView
                        objectName: "manageProfileListView"
                        clip: true
                        width: parent.width
                        height: parent.height - units.gu(12)
                        model: profilesModel
                        
                        delegate:ListItem {
                            height: manageProfileLayout.height + divider.height
                            ListItemLayout {
                                id: manageProfileLayout
                                title.text: firstname + " " + lastname
                                ProgressionSlot {}
                            }
                            onClicked: {
                                hide()
                                editUserId = profileId
                                PopupUtils.open(manageProfileDialog, selectorProfile)
                            }
                        }
                    }
                    SudokuDialogButton{
                        
                        anchors.horizontalCenter: parent.horizontalCenter
                        id:cancelButton
                        objectName: "cancelButton"
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
        
        Flickable {
            id: flickableSettings
            objectName: "settingsContainer"

            anchors.fill: parent
            contentHeight: mainColumnSettings.height
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: mainColumnSettings;

                height: childrenRect.height
                width: parent.width
                spacing: units.gu(1)

                ListItem {
                    height: sudokuSettingsLayout.height + divider.height
                    ListItemLayout {
                        id: sudokuSettingsLayout
                        title.text: i18n.tr("Sudoku settings")
                        title.font.weight: Font.DemiBold
                    }
                }
                
                OptionSelector {
                    objectName: "difficultySelector"
                    id: difficultySelector
                    text: i18n.tr("Default Difficulty")
                    width: parent.width - units.gu(4)
                    anchors.horizontalCenter: parent.horizontalCenter
                    model: [i18n.tr("Easy"), i18n.tr("Moderate"), i18n.tr("Hard"), i18n.tr("Ultra Hard"), i18n.tr("Always ask")]
                    onSelectedIndexChanged: {
                        //print(difficultySelector.selectedIndex)
                        switch(difficultySelector.selectedIndex) {
                        case 0:
                            var randomnumber = Math.floor(Math.random()*9);
                            randomnumber += 31;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            Settings.setSetting("Difficulty", selectedIndex)
                            sudokuBlocksGrid.gameDifficulty = 0
                            break;
                        case 1:
                            var randomnumber = Math.floor(Math.random()*4);
                            randomnumber += 26;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            Settings.setSetting("Difficulty", selectedIndex)
                            sudokuBlocksGrid.gameDifficulty = 1
                            break;
                        case 2:
                            var randomnumber = Math.floor(Math.random()*4);
                            randomnumber += 21;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            Settings.setSetting("Difficulty", selectedIndex)
                            sudokuBlocksGrid.gameDifficulty = 2
                            break;
                        case 3:
                            var randomnumber = Math.floor(Math.random()*3);
                            randomnumber += 17;
                            sudokuBlocksGrid.createNewGame(81 - randomnumber);
                            Settings.setSetting("Difficulty", selectedIndex)
                            sudokuBlocksGrid.gameDifficulty = 3
                            break;
                        case 4:
                            Settings.setSetting("Difficulty", selectedIndex)
                            break;
                        }
                    }
                    
                }

                OptionSelector {
                    objectName: "themeSelector"
                    id: themeSelector
                    text: i18n.tr("Theme")
                    model: ["UbuntuColours", "Simple"]
                    width: parent.width - units.gu(4)
                    anchors.horizontalCenter: parent.horizontalCenter
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
                    Component.onCompleted: selectedIndex = 0
                }
                
                ListItem {
                    objectName: "hintsSwitchClickable"
                    height: hintsSettingsLayout.height + divider.height

                    ListItemLayout {
                        id: hintsSettingsLayout
                        title.text: i18n.tr("Hints")

                        Switch {
                            id: disableHints
                            objectName: "hintsSwitch"
                            checked: disableHintsChecked
                            SlotsLayout.position: SlotsLayout.Last
                            onCheckedChanged: {
                                Settings.setSetting("DisableHints", checked ? "true":"false")
                            }
                        }
                    }
                }

                ListItem {
                    objectName: "vibrationsSwitchClickable"
                    height: vibrationsSettingsLayout.height + divider.height

                    ListItemLayout {
                        id: vibrationsSettingsLayout
                        title.text: i18n.tr("Vibration Alerts")

                        Switch {
                            id: disableVibrations
                            objectName: "vibrationsSwitch"
                            checked: disableVibrationsChecked
                            SlotsLayout.position: SlotsLayout.Last
                            onCheckedChanged: {
                                Settings.setSetting("DisableVibrations", checked ? "true":"false")
                            }
                        }
                    }
                }

                ListItem {
                    height: profileSettingsLayout.height + divider.height
                    ListItemLayout {
                        id: profileSettingsLayout
                        title.text: i18n.tr("Profiles settings")
                        title.font.weight: Font.DemiBold
                    }
                }

                SingleValueListItem {
                    id: selectorProfile
                    objectName: "Current profile"
                    title.text: i18n.tr("Current profile")
                    value: {
                        if(currentUserId==-1)
                            return i18n.tr("None")
                        else
                            return Settings.getUserFirstName(currentUserId)+" "+Settings.getUserLastName(currentUserId);

                    }
                    Component.onCompleted: currentUserId = Settings.getSetting("currentUserId")

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

                ListItem {
                    id: addSingleValue
                    objectName: "Add profile"
                    height: addSingleValueLayout.height + divider.height
                    ListItemLayout {
                        id: addSingleValueLayout
                        title.text: i18n.tr("Add profile")
                        ProgressionSlot {}
                    }
                    onClicked: {
                        PopupUtils.open(addProfileDialog, addSingleValue);
                    }
                }

                ListItem {
                    id: manageProfileSingleValue
                    objectName: "Manage profiles"
                    height: manageProfileSingleValueLayout.height + divider.height
                    ListItemLayout {
                        id: manageProfileSingleValueLayout
                        title.text: i18n.tr("Manage profiles")
                        ProgressionSlot {}
                    }
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
        
        Scrollbar {
            flickableItem: flickableSettings
            align: Qt.AlignTrailing
        }
    }
}
