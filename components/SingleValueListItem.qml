import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {
    id: customListItem

    property alias title: customItemLayout.title
    property alias value: _value.text

    ListItemLayout {
        id: customItemLayout

        title.text: " "

        Label {
            id: _value
            SlotsLayout.position: SlotsLayout.Trailing;
        }

        ProgressionSlot {}
    }
}
