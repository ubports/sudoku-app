import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 0.1
import Ubuntu.Layouts 0.1
import "../js/localStorage.js" as Settings
import "../components"
//import Ubuntu.HUD 1.0 as HUD
import Ubuntu.Unity.Action 1.0 as UnityActions
import UserMetrics 0.1

Tab {

    page: Page {
        tools: ToolbarItems {
            ToolbarButton {
                objectName: "allusersbutton"
                action: Action {
                    text: "All\nusers"
                    iconSource: Qt.resolvedUrl("../icons/all-users.svg")
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
                    iconSource: Qt.resolvedUrl("../icons/single-user.svg")
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