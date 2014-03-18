import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 0.1
import "../js/localStorage.js" as Settings
import "../components"

Tab {
    id: aboutTab;
    objectName: "aboutTab"
    title: i18n.tr("About")
    page: Page {
        Column {
            id: aboutColumn;
            spacing: units.gu(3)
            //anchors.fill: parent
            //anchors.horizontalCenter: parent.horizontalCenter;
            width: parent.width
            y: units.gu(6);
            UbuntuShape {
                property real maxWidth: units.gu(45)
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(mainView.width, maxWidth)/2
                height: Math.min(mainView.width, maxWidth)/2
                image: Image {
                    objectName: "aboutImage"
                    //height: width
                    source: "../icons/about.png"
                    smooth: true
                    fillMode: Image.PreserveAspectFit

                }
            }
            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                rowSpacing: units.gu(2)
                columnSpacing: mainView.width/10
                Label {
                    objectName: "authorLabel"
                    text: i18n.tr("Author(s): ")

                }
                Label {
                    objectName: "authors"
                    font.bold: true;
                    text: "Dinko Osmankovi\u0107 \nFr\u00e9d\u00e9ric Delgado \nGeorgi Karavasilev \nSam Hewitt"
                }
                Label {
                    objectName: "contactLabel"
                    text: i18n.tr("Contact: ")
                }
                Label {
                    objectName: "contacts"
                    font.bold: true;
                    text: "dinko.metalac@gmail.com"
                }

            }

            Row {
                id: homepage;
                anchors.horizontalCenter: parent.horizontalCenter;
                Label {
                    objectName: "urlLabel"
                    font.bold: true;
                    text: "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter;
                Label {
                    objectName: "versionLabel"
                    text: i18n.tr("Version: ")
                }
                Label {
                    objectName: "version"
                    font.bold: true;
                    text: "1.5"
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter;
                Label {
                    objectName: "yearLabel"
                    font.bold: true;
                    text: "2013"


                }
            }
        }
    }
}
