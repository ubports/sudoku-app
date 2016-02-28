import QtQuick 2.4
import Ubuntu.Components 1.3

ActionList {
    id: tabsList

    children: [
        Action {
            text: i18n.tr("Sudoku")
            onTriggered: {
                tabs.selectedTabIndex = 0
            }
        },

        Action {
            text: i18n.tr("Scores")
            onTriggered: {
                tabs.selectedTabIndex = 1
            }
        },

        Action {
            text: i18n.tr("Settings")
            onTriggered: {
                tabs.selectedTabIndex = 2
            }
        },

        Action {
            text: i18n.tr("About")
            onTriggered: {
                tabs.selectedTabIndex = 3
            }
        }
    ]
}
