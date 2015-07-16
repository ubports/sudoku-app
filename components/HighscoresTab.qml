import QtQuick 2.3
import Ubuntu.Components 1.2
//import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Layouts 1.0
import "../js/localStorage.js" as Settings
import "../components"
//import Ubuntu.HUD 1.0 as HUD
import Ubuntu.Unity.Action 1.1 as UnityActions
import UserMetrics 0.1

Page {

    function appendModel(item)
    {
        highscoresModel.append(item)
    }
    function clearModel()
    {
        highscoresModel.clear()
    }

    BottomEdge {
        z:2
        hintIconName: "delete"
        actions: [
            RadialAction {
                iconName: "contact"
                iconColor: UbuntuColors.red
            },
            RadialAction {
                iconName: "contact-group"
                iconColor: UbuntuColors.red
            }
        ]
    }

    head.actions:  [
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

        //locked: true
        //opened: true
    ]


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
        UbuntuListView {
            id: highScoresListView
            model: highscoresModel
            width: parent.width
            height:parent.height

            header: Label {
                id: highscoresHeader
                objectName: "highscoreslabel"
                text: highscoresHeaderText
                height: units.gu(5)
            }

            delegate: ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    text: (index+1) + ".   " + firstname + " " + lastname
                }
                Label {
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1)
                    text: score
                }

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            onTriggered: {
                                //print(index, id, firstname);
                                Settings.deleteScoreWithId(id);
                                highscoresModel.remove(index,1);
                            }
                        }
                    ]
                }
                //value: score
            }
        }
    }
}


