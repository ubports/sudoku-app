import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import "../js/localStorage.js" as Settings
import QtQuick.LocalStorage 2.0

Component {
    id: addProfileDialog

    Dialog {
        id: addProfileDialogue
        title: i18n.tr("Add new profile")
        width: parent.width


        Column {
            width: parent.width
            spacing: units.gu(2)

            UbuntuShape{
                width: mainView.width/3*2
                height: mainView.height/18
                radius: "medium"
                color: "#AEA79F"
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id:lastnameField
                    anchors.fill: parent
                    placeholderText: i18n.tr("Lastname")
                    color: "white"
                }
            }
            UbuntuShape{
                width: mainView.width/3*2
                height: mainView.height/18
                radius: "medium"
                color: "#AEA79F"
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id:firstnameField
                    anchors.fill: parent
                    placeholderText: i18n.tr("Firstname")
                    color: "white"
                }
            }


            Row{
                width: parent.width
                spacing: units.gu(1)

                SudokuDialogButton{
                    id:okButton
                    buttonText: i18n.tr("OK")
                    width: parent.width/2;
                    size: units.gu(5)
                    buttonColor: sudokuBlocksGrid.dialogButtonColor2
                    textColor: sudokuBlocksGrid.dialogButtonTextColor
                    onTriggered: {

                        if(lastnameField.text!="" && firstnameField.text!="")
                        {

                            if(!Settings.existProfile(lastnameField.text, firstnameField.text))
                            {

                                Settings.insertProfile(lastnameField.text, firstnameField.text);
                                PopupUtils.close(addProfileDialogue)
                            }else{
                                mainView.showAlert(i18n.tr("Warning"), i18n.tr("User already exist."), okButton)
                            }


                        } else{
                            mainView.showAlert(i18n.tr("Warning"), i18n.tr("Lastname and firstname must not be empty."), okButton)
                        }





                    }
                }

                SudokuDialogButton{
                    buttonText: i18n.tr("Cancel")
                    width: parent.width/2;
                    size: units.gu(5)
                    buttonColor: sudokuBlocksGrid.dialogButtonColor1
                    textColor: sudokuBlocksGrid.dialogButtonTextColor
                    //border.color: "transparent"
                    onTriggered: {
                        PopupUtils.close(addProfileDialogue)
                    }
                }
            }



        }


    }
}

