# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot emulators."""

from ubuntuuitoolkit import emulators as toolkit_emulators


class MainView(toolkit_emulators.MainView):

    def get_blank_inputs(self):
        #generate a list of blank input fields from the game board
        #SudokuBlocksGrid->..->SudokuButton->QQuickTest->enabled == true
        inputs = self.select_single("SudokuBlocksGrid")
        blankInputsList = inputs.select_many("QQuickText", enabled=True)
        return blankInputsList

    def get_dialog_button(self, name):
        numberdialog = self.get_number_dialog()

        #SudokuDialogButton->QQuickText text =
        button = numberdialog.wait_select_single("QQuickText", text=name)
        return button

    def get_number_dialog(self):
        return self.wait_select_single("Dialog", objectName="picknumberscreen")

    def get_hints_switch(self):
        return self.select_single("CheckBox", objectName="hintsSwitch")

    #clicking on this works instead on  the previous one (get_hints_switch)
    #  it doesn't(but the previous has the clicked property so I am using both
    def get_hints_switchClickable(self):
        return self.select_single("Standard",
                                  objectName="hintsSwitchClickable")

    def get_difficulty_selector(self):
        return self.select_single("ValueSelector",
                                  objectName="difficultySelector")

    def get_difficulty_selector_labelvisual(self):
        difficultylabelvisual = self.get_difficulty_selector()
        difficutlylabelvisualList = difficultylabelvisual.select_many(
            "LabelVisual", visible="True")
        return difficutlylabelvisualList

    def get_theme_selector(self):
        return self.select_single("ValueSelector", objectName="themeSelector")

    def get_theme_selector_labelvisual(self):
        themelabelvisual = self.get_theme_selector()
        themelabelvisualList = themelabelvisual.select_many("LabelVisual",
                                                            visible="True")
        return themelabelvisualList

    def get_current_profile(self):
        return self.select_single("SingleValue", objectName="Current profile")

    def get_sudoku_user_profile(self):
        return self.select_single("Standard", text="Sudoku User")

    def get_user_profile_cancel_button(self):
        return self.select_single("Button", objectName="profileCancelButton")

    def get_add_profile(self):
        return self.select_single("SingleValue", objectName="Add profile")

    def get_add_profile_dialog(self):
        return self.select_single("Dialog", objectName="Add new profile")

    def get_add_profile_Lastname_field(self):
        return self.select_single("TextField", objectName="Lastname")

    def get_add_profile_Firstname_field(self):
        return self.select_single("TextField", objectName="Firstname")

    def get_add_profile_OKbutton(self):
        return self.select_single("SudokuDialogButton", objectName="OKbutton")

    def get_manage_profiles(self):
        return self.select_single("SingleValue", objectName="Manage profiles")

    def get_Myfirstname_Mylastname_profile(self):
        return self.select_single("Standard", text="Myfirstname Mylastname")

    def get_edit_profile_dialog(self):
        return self.select_single("Dialog", objectName="Edit profile")

    def get_edit_profile_delete_button(self):
        return self.select_single("SudokuDialogButton",
                                  objectName="deleteButton")

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
