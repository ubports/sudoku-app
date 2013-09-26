# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals, Contains, NotEquals

from sudoku_app.tests import SudokuTestCase
from time import sleep

class TestMainWindow(SudokuTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()
        self.assertThat(
            self.main_view.visible, Eventually(Equals(True)))

    def test_enter_and_clear_number(self):
        #find the first button that has a blank value
        gridButtons = self.main_view.get_blank_inputs()
        gridButton = gridButtons[0]

        #create a value function to check later using id
        buttonValue = lambda: self.app.select_single("QQuickText",id=gridButton.id).text

        #double check that it's blank
        self.assertThat(buttonValue, Eventually(Equals("")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_view.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose 4
        dialogButton = self.main_view.get_dialog_button("4")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("4")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_view.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose clear
        dialogButton = self.main_view.get_dialog_button("Clear")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("")))

    def test_best_scores_tab(self):
        #switch to best scores tab
        self.main_view.switch_to_tab_by_index(1)

        #make sure we are in the right place
        tabName = lambda: self.app.select_single("Tab", objectName="highscoresTab")
        self.assertThat(tabName, Eventually(NotEquals(None)))

        #click current user button
        self.main_view.click_toolbar_button("currentuserbutton")

        #check label
        label = lambda: self.app.select_single("Header", objectName="highscoreslabel").text
        self.assertThat(label, Eventually(NotEquals("<b>Best scores for all players</b>")))

        #click all users button
        self.main_view.click_toolbar_button("allusersbutton")

        #check label again
        self.assertThat(label, Eventually(Equals("<b>Best scores for all players</b>")))

    def test_enter_and_cancel(self):
        #find the first button that has a blank value
        gridButtons = self.main_view.get_blank_inputs()
        gridButton = gridButtons[0]

        #create a value function to check later using id
        buttonValue = lambda: self.app.select_single("QQuickText",id=gridButton.id).text

        #double check that it's blank
        self.assertThat(buttonValue, Eventually(Equals("")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_view.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose 4
        dialogButton = self.main_view.get_dialog_button("4")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("4")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_view.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose clear
        dialogButton = self.main_view.get_dialog_button("Cancel")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("4")))


    def test_new_game_button(self):
        self._open_and_check_settings_tab()
        difficultySelector = self.main_view.get_difficulty_selector()
        self.pointing_device.click_object(difficultySelector)
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = difficultyChoices[3]
        self.assertThat(difficultyChoice.text, Eventually(Equals("Moderate")))

        self.pointing_device.click_object(difficultyChoice)
        self._verify_settings_tab_open()
        self.main_view.switch_to_tab_by_index(0)

        #verify settings sudoku tab is open
        self._verify_settings_tab_open()

        #testing new game with moderate mode
        self.main_view.click_toolbar_button("newgamebutton")

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0))) #This cannot be known because timer will not stop
        self.main_view.hide_toolbar()

        #----------------------------------------------------------

        self._open_and_check_settings_tab()
        difficultySelector = self.main_view.get_difficulty_selector()
        self.pointing_device.click_object(difficultySelector)
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = difficultyChoices[6]
        self.assertThat(difficultyChoice.text, Eventually(Equals("Always ask")))

        self.pointing_device.click_object(difficultyChoice)
        self._verify_settings_tab_open()
        self.main_view.switch_to_tab_by_index(0)

        #verify settings sudoku tab is open
        self._verify_settings_tab_open()

        #testing new game with always ask mode - easy
        self.main_view.open_toolbar()
        self.main_view.click_toolbar_button("newgamebutton")

        newGameEasyButton = self.main_view.get_new_game_easy_button()
        self.main_view.try_new_game_easy_button()
        self.assertThat(newGameEasyButton.buttonText, Eventually(Equals("Easy")))
        self.pointing_device.click_object(newGameEasyButton)

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.main_view.hide_toolbar()

        #----------------------------------------------------------
        #testing new game with always ask mode - moderate
        self.main_view.open_toolbar()
        self.main_view.click_toolbar_button("newgamebutton")

        newGameModerateButton = self.main_view.get_new_game_moderate_button()
        self.main_view.try_new_game_moderate_button()
        self.assertThat(newGameModerateButton.buttonText, Eventually(Equals("Moderate")))
        self.pointing_device.click_object(newGameModerateButton)

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.main_view.hide_toolbar()

        #----------------------------------------------------------
        #testing new game with always ask mode - hard
        self.main_view.open_toolbar()
        self.main_view.click_toolbar_button("newgamebutton")

        newGameHardButton = self.main_view.get_new_game_hard_button()
        self.main_view.try_new_game_hard_button()
        self.assertThat(newGameHardButton.buttonText, Eventually(Equals("Hard")))
        self.pointing_device.click_object(newGameHardButton)

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.main_view.hide_toolbar()

        #----------------------------------------------------------
        #testing new game with always ask mode - ultra hard
        self.main_view.open_toolbar()
        self.main_view.click_toolbar_button("newgamebutton")

        newGameUltraHardButton = self.main_view.get_new_game_ultrahard_button()
        self.main_view.try_new_game_ultrahard_button()
        self.assertThat(newGameUltraHardButton.buttonText, Eventually(Equals("Ultra\nHard")))
        self.pointing_device.click_object(newGameUltraHardButton)

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.main_view.hide_toolbar()

        # Reverting to standard
        self._open_and_check_settings_tab()
        difficultySelector = self.main_view.get_difficulty_selector()
        self.pointing_device.click_object(difficultySelector)
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = difficultyChoices[1]


    def test_about_tab(self):
        #Switch to the 'About' tab
        self.main_view.switch_to_tab_by_index(3)

        #Check for 'About' tab selection
        tabName = lambda: self.app.select_single("Tab", objectName="aboutTab")
        self.assertThat(tabName.text, Eventually(Equals("About")))

        #Check image loads
        aboutImage = lambda: self.app.select_single("QQuickImage", objectName="aboutImage").progress
        self.assertThat(aboutImage, Eventually(Equals(1.0)))

        #Check the 'Author(s):' label is displayed
        aboutLabel = lambda: self.app.select_single("Label", objectName="authorLabel").text
        self.assertThat(aboutLabel, Eventually(Equals("Author(s): ")))

        #Check the 'Contact:' label is displayed
        contactLabel = lambda: self.app.select_single("Label", objectName="contactLabel").text
        self.assertThat(contactLabel, Eventually(Equals("Contact: ")))

        #Check correct Launchpad URL: is displayed
        urlLabel = lambda: self.app.select_single("Label", objectName="urlLabel").text
        self.assertThat(urlLabel, Eventually(Equals(
            "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>")))

        #Check the 'Version:' label is displayed
        versionLabel = lambda: self.app.select_single("Label", objectName="versionLabel").text
        self.assertThat(versionLabel, Eventually(Equals("Version: ")))

        #Check correct version is displayed
        version = lambda: self.app.select_single("Label", objectName="version").text
        self.assertThat(version, Eventually(Equals("0.4.3")))

        #Check correct year is displayed
        yearLabel = lambda: self.app.select_single("Label", objectName="yearLabel").text
        self.assertThat(yearLabel, Eventually(Equals("2013")))

    def test_hint_button(self):
        #open settings tab
        self._open_and_check_settings_tab()

        #click on hints switch to enalbe hints toolbar button
        hintsSwitchClickable = lambda: self.main_view.get_hints_switchClickable()
        self.assertThat(hintsSwitchClickable.text, Eventually(Equals("Hints")))

        #turn on (by clicking on it) hints switch if not already
        hintsSwitch = lambda: self.main_view.get_hints_switch()
        self.assertThat(hintsSwitch.id, Eventually(Equals("disableHints")))
        if hintsSwitch.checked == False:
           self.pointing_device.click_object(hintsSwitchClickable)

        #verify hints switch is clicked
        self.assertThat(hintsSwitch.checked, Eventually(Equals(True)))

        # exit settings tab by clicking on sudoku tab
        self.main_view.switch_to_tab_by_index(0)

        #verify settings sudoku tab is open
        self._verify_settings_tab_open()

        #click on hint button on tuolbar
        self.main_view.click_toolbar_button("hintbutton")
        gridButtons = self.main_view.get_blank_inputs()

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        self.assertThat(number_of_hints, Eventually(Equals(1)))

    def test_settings_tab(self):
        #open settings tab
        self._open_and_check_settings_tab()

        #********check difficulty selector ********
        #click on difficulty selector
        difficultySelector = lambda: self.main_view.get_difficulty_selector()
        self.assertThat(difficultySelector.text, Eventually(Equals("Difficulty")))
        self.pointing_device.click_object(difficultySelector)

        #select "Moderate" choice of difficulty selector
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = difficultyChoices[3]
        self.assertThat(difficultyChoice.text, Eventually(Equals("Moderate")))

        self.pointing_device.click_object(difficultyChoice)
        self._verify_settings_tab_open()

        #********check theme selector ********
        #click on theme selector
        themeSelector = lambda: self.main_view.get_theme_selector()
        self.assertThat(themeSelector.text, Eventually(Equals("Theme")))
        self.pointing_device.click_object(themeSelector)

        #select "Simple" choice of theme selector
        themeChoices = self.main_view.get_theme_selector_labelvisual()
        themeChoice = themeChoices[3]
        self.assertThat(themeChoice.text, Eventually(Equals("Simple")))

        self.pointing_device.click_object(themeChoice)

        #******** check hint switch  ********
        #select hints switch
        hintsSwitchClickable = lambda: self.main_view.get_hints_switchClickable()
        self.assertThat(hintsSwitchClickable.text, Eventually(Equals("Hints")))
        hintsSwitch = lambda: self.main_view.get_hints_switch()
        self.assertThat(hintsSwitch.id, Eventually(Equals("disableHints")))

        #switch it on or off depending on it's state
        if hintsSwitch.checked == False:
           self.pointing_device.click_object(hintsSwitchClickable)
           self.assertThat(hintsSwitch.checked, Eventually(Equals(True)))
        else:
           self.pointing_device.click_object(hintsSwitchClickable)
           self.assertThat(hintsSwitch.checked, Eventually(Equals(False)))

        #******** check profile settings ********
        #select current profile
        currentProfile = lambda: self.main_view.get_current_profile()
        self.assertThat(currentProfile.text, Eventually(Equals("Current profile")))
        self.pointing_device.click_object(currentProfile)

        #let's change profile
        #verify select profile page opens
        self._get_and_verify_profile_page()

        #select "sudoku user" profile
        sudokuUserProfile = lambda: self.main_view.get_sudoku_user_profile()
        self.assertThat(sudokuUserProfile, Eventually(Equals("Sudoku User")))
        self.pointing_device.click_object(sudokuUserProfile)

        #verify changed profile
        currentProfile = lambda: self.main_view.get_current_profile()
        self.assertThat(currentProfile.value, Eventually(Equals("Sudoku User")))

        #let's add a user profile
        #verify add profile page opens
        sudokuAddProfile = lambda: self.main_view.get_add_profile()
        self.assertThat(sudokuAddProfile, Eventually(Equals("Sudoku User")))
        self.pointing_device.click_object(sudokuAddProfile)

        #verify add profile dialog opens
        addDialog = lambda: self.main_view.get_add_profile_dialog()
        self.assertThat(addDialog.title, Eventually(Equals("Add new profile")))

        #insert Lastname
        lastName = lambda: self.main_view.get_add_profile_Lastname_field()
        self.pointing_device.click_object(lastName)
        self.assertThat(lastName.placeholderText, Eventually(Equals("Lastname")))
        self.keyboard.type("Mylastname")
        self.assertThat(lastName.text, Eventually(Equals("Mylastname")))

        #insert Firstname
        firstName = lambda: self.main_view.get_add_profile_Firstname_field()
        self.pointing_device.click_object(firstName)
        self.assertThat(firstName.placeholderText, Eventually(Equals("Firstname")))
        self.keyboard.type("Myfirstname")
        self.assertThat(firstName.text, Eventually(Equals("Myfirstname")))

        #click OK button
        OKButton = self.main_view.get_add_profile_OKbutton()
        self.main_view.try_OK_Button()
        self.assertThat(OKButton.buttonText, Eventually(Equals("OK")))
        self.pointing_device.click_object(OKButton)
        self._verify_settings_tab_open()

        #******** check manage profiles ********
        #select manage profile
        manageProfile = self.main_view.get_manage_profiles()
        self.main_view.try_manage_profile()
        self.assertThat(manageProfile.text, Eventually(Equals("Manage profiles")))
        self.pointing_device.click_object(manageProfile)

        #verify select profile page opens
        self._get_and_verify_profile_page()

        #click on the new profile just added
        myProfile = self.main_view.get_Myfirstname_Mylastname_profile()
        self.main_view.try_my_profile()
        self.assertThat(myProfile.text, Eventually(Equals("Myfirstname Mylastname")))
        self.pointing_device.click_object(myProfile)

        #verify the edit profile dialog opens
        editProfileDialog = lambda: self.main_view.get_edit_profile_dialog().text
        self.assertThat(editProfileDialog, Eventually(Equals("editProfileDialog")))

        #click on delete
        deleteButton = self.main_view.get_edit_profile_delete_button()
        self.main_view.try_delete_Button()
        self.assertThat(deleteButton.buttonText, Eventually(Equals("Delete")))
        self.pointing_device.click_object(deleteButton)
        self._verify_settings_tab_open()

        #verify settings tab is open
        self._verify_settings_tab_open()

    def _open_and_check_settings_tab(self):
        #click on settings tab so to enable the hints button
        self.main_view.switch_to_tab_by_index(2)
        self._verify_settings_tab_open()

    def _verify_settings_tab_open(self):
        #verify settings tab is open
        tabName = lambda: self.app.select_single("Tab", objectName="settingsTab")

        self.assertThat(tabName, Eventually(NotEquals(None)))

    def _get_and_verify_profile_page(self):
        profilePage = lambda: self.main_view.get_select_profile_sheet().title
        self.assertThat(profilePage, Eventually(Equals("Select profile")))

