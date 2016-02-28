import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.Layouts 1.0
import "../js/localStorage.js" as Settings
import "../components"

Tab {
    id: highScoresTab

    function appendModel(item)
    {
        highscoresModel.append(item)
    }
    function clearModel()
    {
        highscoresModel.clear()
    }
    function clearModelProfileId(id)
    {
        var firstName = Settings.getUserFirstName(currentUserId);
        var lastName = Settings.getUserLastName(currentUserId);
        for (var i = 0; i < highscoresModel.count; i++)
        {
            if (highscoresModel.get(i).firstname === firstName &&
                    highscoresModel.get(i).lastname === lastName )
                highscoresModel.remove(i);
        }
    }

    Page {
        id: highScoresPage

        header: PageHeader {
            title: i18n.tr("About")
            leadingActionBar {
                numberOfSlots: 0
                actions: tabsList.actions
            }

            trailingActionBar.actions: [
                Action {
                    objectName: "allusersbutton"
                    text: "All\nusers"
                    iconSource: Qt.resolvedUrl("../icons/all-users.svg")
                    onTriggered: {
                        var allScores = Settings.getAllScores()
                        highscoresModel.clear();
                        highscoresHeaderText = i18n.tr("<b>Best scores for all players</b>");
                        for(var i = 0; i < allScores.length; i++) {
                            var rowItem = allScores[i];
                            //print("ROW ",rowItem)
                            var firstName = Settings.getUserFirstName(rowItem[1]);
                            var lastName = Settings.getUserLastName(rowItem[1]);
                            //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                            highscoresModel.append({ 'id': rowItem[0],
                                                       'firstname': firstName,
                                                       'lastname':  lastName,
                                                       'score': rowItem[2] });
                        }
                    }
                },
                Action {
                    text: "Current\nuser"
                    objectName: "currentuserbutton"
                    iconSource: Qt.resolvedUrl("../icons/single-user.svg")
                    onTriggered: {
                        var firstName = Settings.getUserFirstName(currentUserId);
                        var lastName = Settings.getUserLastName(currentUserId);
                        //print(firstName, lastName)
                        // TRANSLATORS: %1 is user's first name and %2 is last name
                        highscoresHeaderText = "<b>" + i18n.tr("Best scores for %1 %2").arg(firstName).arg(lastName) + "</b>"
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
        }

        BottomEdge {
            z:2
            hintIconName: "delete"
            actions: [
                RadialAction {
                    iconName: "contact"
                    iconColor: UbuntuColors.orange
                    onTriggered: {
                        Settings.deleteScoresWithProfileId(currentUserId)
                        highscoresModel.clearModelProfileId(currentUserId);
                    }
                },
                RadialAction {
                    iconName: "contact-group"
                    iconColor: UbuntuColors.orange
                    onTriggered: {
                        Settings.deleteAllScores();
                        highscoresModel.clear();
                    }
                }
            ]
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
                    var firstName = Settings.getUserFirstName(rowItem[1]);
                    var lastName = Settings.getUserLastName(rowItem[1]);
                    //res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
                    highscoresModel.append({ 'id': rowItem[0],
                                               'firstname': firstName,
                                               'lastname':  lastName,
                                               'score': rowItem[2] });
                }
            }
        }

        UbuntuListView {
            id: highScoresListView

            anchors {
                top: highScoresPage.header.bottom
                topMargin: units.gu(2)
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            model: highscoresModel

            header: Label {
                id: highscoresHeader
                objectName: "highscoreslabel"
                text: highscoresHeaderText
                height: units.gu(5)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
            }

            delegate: ListItem {
                ListItemLayout {
                    title.text: "%1. %2 %3".arg(index+1).arg(firstname).arg(lastname)
                    Label {
                        SlotsLayout.position: SlotsLayout.Last
                        text: score
                    }
                }

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            onTriggered: {
                                Settings.deleteScoreWithId(id);
                                highscoresModel.remove(index,1);
                            }
                        }
                    ]
                }
            }
        }
    }
}

