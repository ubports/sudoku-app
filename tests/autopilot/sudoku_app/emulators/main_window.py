# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot emulators."""

from autopilot.introspection.dbus import StateNotFoundError

class MainWindow(object):
    """An emulator class that makes it easy to interact with the
    sudoku-app.

    """
    def __init__(self, app):
        self.app = app

    def get_blank_inputs(self):
        #generate a list of blank input fields from the game board
        #SudokuBlocksGrid->..->SudokuButton->QQuickTest->enabled == true
        inputs = self.app.select_single("SudokuBlocksGrid")
        blankInputsList = inputs.select_many("QQuickText", enabled=True)
        return blankInputsList

    def get_dialog_button(self, name):
        numberdialog = self.get_number_dialog()

        #SudokuDialogButton->QQuickText text =
        button = numberdialog.select_single("QQuickText",text=name)
        return button

    def get_number_dialog(self):
        return self.app.select_single("Dialog", objectName="picknumberscreen")

    def get_hints_switch(self):
        return self.app.select_single("CheckBox", objectName="hintsSwitch")

    #clicking on this works instead on  the previous one (get_hints_switch) it doesn't(but the previous
    #has the clicked property so I am using both
    def get_hints_switchClickable(self):
        return self.app.select_single("Standard", objectName="hintsSwitchClickable")

    def get_difficulty_selector(self):
        return self.app.select_single("ValueSelector", objectName="difficultySelector")

    def get_difficulty_selector_labelvisual(self):
        difficultylabelvisual = self.get_difficulty_selector()
        difficutlylabelvisualList = difficultylabelvisual.select_many("LabelVisual", visible="True")
        return difficutlylabelvisualList

    def get_theme_selector(self):
        return self.app.select_single("ValueSelector", objectName="themeSelector")

    def get_theme_selector_labelvisual(self):
        themelabelvisual = self.get_theme_selector()
        themelabelvisualList = themelabelvisual.select_many("LabelVisual", visible="True")
        return themelabelvisualList

    def get_current_profile(self):
        return self.app.select_single("SingleValue", objectName="Current profile")

    def get_select_profile_sheet(self):
        return self.app.select_single("DefaultSheet", title="Select profile")

    def get_sudoku_user_profile(self):
        return self.app.select_single("Standard", text="Sudoku User")

    def get_user_profile_close_button(self):
        return self.app.select_single("Button", text="close")

    def get_add_profile(self):
        return self.app.select_single("SingleValue", objectName="Add profile")

    def get_add_profile_dialog(self):
        return  self.app.select_single("Dialog", objectName="Add new profile")

    def get_add_profile_Lastname_field(self):
        return self.app.select_single("TextField", objectName = "Lastname")

    def get_add_profile_Firstname_field(self):
        return self.app.select_single("TextField", objectName = "Firstname")

    def get_add_profile_OKbutton(self):
        return self.app.select_single("SudokuDialogButton", objectName = "OKbutton")

    def get_manage_profiles(self):
        return self.app.select_single("SingleValue", objectName = "Manage profiles")

    def get_Myfirstname_Mylastname_profile(self):
        return self.app.select_single("Standard", text="Myfirstname Mylastname")

    def get_edit_profile_dialog(self):
        return  self.app.select_single("Dialog", objectName="Edit profile")

    def get_edit_profile_delete_button(self):
        return self.app.select_single("SudokuDialogButton", objectName ="deleteButton")

    def try_OK_Button(self):
        try:
            return self.get_add_profile_OKbutton().buttonText
        except StateNotFoundError:
            return None

    def try_manage_profile(self):
        try:
            return self.get_manage_profiles().text
        except StateNotFoundError:
            return None

    def try_delete_Button(self):
        try:
            return self.get_edit_profile_delete_button().buttonText
        except StateNotFoundError:
            return None

    def try_my_profile(self):
        try:
            return self.get_Myfirstname_Mylastname_profile().text
        except StateNotFoundError:
            return None