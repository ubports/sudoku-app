import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import "../js/localStorage.js" as Settings
import QtQuick.LocalStorage 2.0

Component {
    id: editProfileDialog

    Dialog {
        id: editProfileDialogue
        title: i18n.tr("Edit profile")
        width: parent.width


        Column {
            width: parent.width
            spacing: units.gu(2)

            Rectangle{
                width: 200
                height: 32
                radius: 9
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id:lastnameField
                    text: Settings.getUserLastName(editUserId)
                    placeholderText: i18n.tr("Lastname")

                }
            }
            Rectangle{
                width: 200
                height: 32
                radius: 9
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id:firstnameField
                    anchors.horizontalCenter: parent.horizontalCenter
                    placeholderText: i18n.tr("Firstname")
                    text: Settings.getUserFirstName(editUserId)
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
                    border.color: "transparent"
                    onTriggered: {

                        if(lastnameField.text!="" && firstnameField.text!="")
                        {

                            if(!Settings.existProfile( lastnameField.text, firstnameField.text))
                            {

                                Settings.updateProfile(editUserId, lastnameField.text, firstnameField.text);
                                var userId = currentUserId
                                currentUserId = -1
                                currentUserId = userId

                                PopupUtils.close(editProfileDialogue)
                            }else{
                                PopupUtils.close(editProfileDialogue)
                            }


                        } else{
                            mainView.showAlert(i18n.tr("Warning"), i18n.tr("Lastname and firstname must not be empty."), okButton)
                        }





                    }
                }

                SudokuDialogButton{
                    buttonText: i18n.tr("Delete")
                    buttonColor: sudokuBlocksGrid.dialogButtonColor1
                    textColor: sudokuBlocksGrid.dialogButtonTextColor
                    border.color: "transparent"
                    width: parent.width/2;
                    size: units.gu(5)
                    onTriggered: {
                        Settings.deleteProfile(editUserId)
                        if(editUserId == currentUserId)
                            currentUserId = -1


                       PopupUtils.close(editProfileDialogue)
                    }
                }
            }
            SudokuDialogButton{
                anchors.horizontalCenter: parent.horizontalCenter
                buttonText: i18n.tr("Cancel")
                border.color: "transparent"
                width: parent.width/2;
                size: units.gu(5)
                onTriggered: {
                    PopupUtils.close(editProfileDialogue)
                }
            }


        }


    }
}

