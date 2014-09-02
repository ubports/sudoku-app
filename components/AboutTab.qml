import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Layouts 1.0
import "../js/localStorage.js" as Settings
import "../components"
//import Ubuntu.HUD 1.0 as HUD
import Ubuntu.Unity.Action 1.1 as UnityActions
import UserMetrics 0.1

Tab {
    objectName: "aboutTab"
    page: Page {
        Layouts {
            id: aboutTabLayout
            width: mainView.width
            height: mainView.height
            layouts: [
                ConditionalLayout {
                    name: "tablet"
                    when: mainView.width > units.gu(80)
                    Row {
                        anchors {
                            //top: parent
                            left: parent.left
                            leftMargin: mainView.width*0.1
                            top: parent.top
                            topMargin: mainView.height*0.2

                        }
                        spacing: units.gu(5)
                        ItemLayout {
                            item: "icon"
                            id: iconTabletItem
                            property real maxWidth: units.gu(80)
                            width: Math.min(parent.width, maxWidth)/2
                            height: Math.min(parent.width, maxWidth)/2

                        }
                        Column {
                            //height: iconTabletItem.height
                            spacing: 1
                            ItemLayout {
                                item: "info"
                                width: aboutTabLayout.width*0.25
                                height: iconTabletItem.height*0.75
                            }
                            ItemLayout {
                                item: "link"
                                width: aboutTabLayout.width*0.25
                                height: units.gu(3)
                            }
                            ItemLayout {
                                item: "version"
                                width: aboutTabLayout.width*0.25
                                height: units.gu(2)
                            }
                            ItemLayout {
                                item: "year"
                                width: aboutTabLayout.width*0.25
                                height: units.gu(2)
                            }
                        }
                    }
                }


            ]

            Column {
                id: aboutColumn;
                spacing: units.gu(3)
                //anchors.fill: parent
                //anchors.horizontalCenter: parent.horizontalCenter;
                width: parent.width
                y: units.gu(6);
                UbuntuShape {
                    Layouts.item: "icon"
                    property real maxWidth: units.gu(45)
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width, maxWidth)/2
                    height: Math.min(parent.width, maxWidth)/2
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
                    Layouts.item: "info"
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
                    Layouts.item: "link"
                    Label {
                        objectName: "urlLabel"
                        font.bold: true;
                        text: "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>"
                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter;
                    Layouts.item: "version"
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
                    Layouts.item: "year"
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
}
