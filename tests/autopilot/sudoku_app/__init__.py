# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014 Canonical
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Sudoku app autopilot emulators."""

import logging

import autopilot.logging
import ubuntuuitoolkit
from autopilot import introspection


logger = logging.getLogger(__name__)


class SudokuApp:

    """Autopilot helper for the Sudoku application."""

    def __init__(self, app_proxy):
        self.app_proxy = app_proxy
        self.main_view = self.app_proxy.select_single(MainView)


class MainView(ubuntuuitoolkit.MainView):

    @autopilot.logging.log_action(logger.info)
    def go_to_settings(self):
        self.switch_to_tab('settingsTab')
        settings_page = self.select_single(objectName='settingsPage')
        settings_page.visible.wait_for(True)
        return settings_page

    def get_blank_inputs(self):
        # generate a list of blank input fields from the game board
        # SudokuBlocksGrid->..->SudokuButton->QQuickTest->enabled == true
        inputs = self.select_single("SudokuBlocksGrid")
        blankInputsList = inputs.select_many("QQuickText", enabled=True)
        return blankInputsList

    def get_dialog_button(self, name):
        numberdialog = self.get_number_dialog()

        # SudokuDialogButton->QQuickText text =
        button = numberdialog.wait_select_single("QQuickText", text=name)
        return button

    def get_number_dialog(self):
        return self.wait_select_single(objectName='picknumberscreen')

    def get_hints_switch(self):
        return self.select_single("CheckBox", objectName="hintsSwitch")

    # clicking on this works instead on  the previous one (get_hints_switch)
    #  it doesn't(but the previous has the clicked property so I am using both
    def get_hints_switchClickable(self):
        return self.select_single("Standard",
                                  objectName="hintsSwitchClickable")

    def get_difficulty_selector(self):
        return self.wait_select_single(ubuntuuitoolkit.OptionSelector,
                                       objectName="difficultySelector")

    def get_theme_selector(self):
        return self.wait_select_single(ubuntuuitoolkit.OptionSelector,
                                       objectName="themeSelector")

    def get_hint_toolbar_button(self):
        return self.wait_select_single(ubuntuuitoolkit.ToolbarButton,
                                       objectName="hintbutton")

    def get_new_game_easy_button(self):
        return self.wait_select_single("NewGameSelectionButton",
                                       objectName="easyGameButton")

    def get_new_game_moderate_button(self):
        return self.wait_select_single("NewGameSelectionButton",
                                       objectName="moderateGameButton")

    def get_new_game_hard_button(self):
        return self.wait_select_single("NewGameSelectionButton",
                                       objectName="hardGameButton")

    def get_new_game_ultrahard_button(self):
        return self.wait_select_single("NewGameSelectionButton",
                                       objectName="ultrahardGameButton")

    def get_new_game_button(self, objectName):
        return self.wait_select_single("NewGameSelectionButton",
                                       objectName=objectName)


class PickNumberDialog(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Add new profile dialog."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Dialog':
            if state['objectName'][1] == 'picknumberscreen':
                return True
        return False
