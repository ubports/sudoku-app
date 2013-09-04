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
            self.ubuntusdk.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestMainWindow, self).tearDown()

    def test_enter_and_clear_number(self):
        #find the first button that has a blank value
        gridButtons = self.main_window.get_blank_inputs()
        gridButton = gridButtons[0]

        #create a value function to check later using id
        buttonValue = lambda: self.app.select_single("QQuickText",id=gridButton.id).text

        #double check that it's blank
        self.assertThat(buttonValue, Eventually(Equals("")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_window.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose 4
        dialogButton = self.main_window.get_dialog_button("4")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("4")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_window.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose clear
        dialogButton = self.main_window.get_dialog_button("Clear")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("")))

    def test_best_scores_tab(self):
        #switch to best scores tab
        self.ubuntusdk.switch_to_tab(1)

        #make sure we are in the right place
        tabName = lambda: self.ubuntusdk.get_object("Tab","highscoresTab")
        self.assertThat(tabName, Eventually(NotEquals(None)))

        #click current user button
        self.ubuntusdk.click_toolbar_button("currentuserbutton")

        #check label
        label = lambda: self.ubuntusdk.get_object("Header","highscoreslabel").text
        self.assertThat(label, Eventually(NotEquals("<b>Best scores for all players</b>")))

        #click all users button
        self.ubuntusdk.click_toolbar_button("allusersbutton")

        #check label again
        self.assertThat(label, Eventually(Equals("<b>Best scores for all players</b>")))

    def test_enter_and_cancel(self):
        #find the first button that has a blank value
        gridButtons = self.main_window.get_blank_inputs()
        gridButton = gridButtons[0]

        #create a value function to check later using id
        buttonValue = lambda: self.app.select_single("QQuickText",id=gridButton.id).text

        #double check that it's blank
        self.assertThat(buttonValue, Eventually(Equals("")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_window.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose 4
        dialogButton = self.main_window.get_dialog_button("4")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("4")))

        #click the button
        self.pointing_device.click_object(gridButton)

        #assert that we can see the input screen
        inputScreen = lambda: self.main_window.get_number_dialog()
        self.assertThat(inputScreen, Eventually(NotEquals(None)))

        #set a value, choose clear
        dialogButton = self.main_window.get_dialog_button("Cancel")
        self.assertThat(dialogButton, NotEquals(None))
        self.pointing_device.click_object(dialogButton)

        #check the value to ensure it worked
        self.assertThat(buttonValue, Eventually(Equals("4")))


    def test_new_game_button(self):
		self.open_and_check_settings_tab()		
		difficultySelector = self.main_window.get_difficulty_selector()
		self.pointing_device.click_object(difficultySelector)
		difficultyChoices = self.main_window.get_difficulty_selector_labelvisual()
		difficultyChoice = difficultyChoices[3]
        self.assertThat(difficultyChoice.text, Eventually(Equals("Moderate")))

        self.pointing_device.click_object(difficultyChoice)
        self.verify_settings_tab_open()
        self.ubuntusdk.switch_to_tab(0)

        #verify settings sudoku tab is open
        self.verify_settings_tab_open()
        
        #testing new game with moderate mode        
        self.ubuntusdk.click_toolbar_button("newgamebutton")
        
        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0))) #This cannot be known because timer will not stop
        self.ubuntusdk.hide_toolbar()
        
        #----------------------------------------------------------
        
        self.open_and_check_settings_tab()		
		difficultySelector = self.main_window.get_difficulty_selector()
		self.pointing_device.click_object(difficultySelector)
		difficultyChoices = self.main_window.get_difficulty_selector_labelvisual()
		difficultyChoice = difficultyChoices[6]
		self.assertThat(difficultyChoice.text, Eventually(Equals("Always ask")))

        self.pointing_device.click_object(difficultyChoice)
        self.verify_settings_tab_open()
        self.ubuntusdk.switch_to_tab(0)

        #verify settings sudoku tab is open
        self.verify_settings_tab_open()
        
        #testing new game with always ask mode - easy
        self.ubuntusdk.open_toolbar()
        self.ubuntusdk.click_toolbar_button("newgamebutton")
        
        newGameEasyButton = self.main_window.get_new_game_easy_button()
        self.main_window.try_new_game_easy_button()
        self.assertThat(newGameEasyButton.buttonText, Eventually(Equals("Easy")))
        self.pointing_device.click_object(newGameEasyButton)
        
        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.ubuntusdk.hide_toolbar()
        
        #----------------------------------------------------------
        #testing new game with always ask mode - moderate
        self.ubuntusdk.open_toolbar()
        self.ubuntusdk.click_toolbar_button("newgamebutton")
        
        newGameModerateButton = self.main_window.get_new_game_moderate_button()
        self.main_window.try_new_game_moderate_button()
        self.assertThat(newGameModerateButton.buttonText, Eventually(Equals("Moderate")))
        self.pointing_device.click_object(newGameModerateButton)
        
        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.ubuntusdk.hide_toolbar()
        
        #----------------------------------------------------------
        #testing new game with always ask mode - hard
        self.ubuntusdk.open_toolbar()
        self.ubuntusdk.click_toolbar_button("newgamebutton")
        
        newGameHardButton = self.main_window.get_new_game_hard_button()
        self.main_window.try_new_game_hard_button()
        self.assertThat(newGameHardButton.buttonText, Eventually(Equals("Hard")))
        self.pointing_device.click_object(newGameHardButton)
        
        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.ubuntusdk.hide_toolbar()
        
        #----------------------------------------------------------
        #testing new game with always ask mode - ultra hard
        self.ubuntusdk.open_toolbar()
        self.ubuntusdk.click_toolbar_button("newgamebutton")
        
        newGameUltraHardButton = self.main_window.get_new_game_ultrahard_button()
        self.main_window.try_new_game_ultrahard_button()
        self.assertThat(newGameUltraHardButton.buttonText, Eventually(Equals("Ultra\nHard")))
        self.pointing_device.click_object(newGameUltraHardButton)
        
        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        #self.assertThat(game_seconds, Eventually(Equals(0)))
        self.ubuntusdk.hide_toolbar()
        

    def test_about_tab(self):
        #Switch to the 'About' tab
        self.ubuntusdk.switch_to_tab(3)

        #Check for'About' tab selection
        tabName = lambda: self.ubuntusdk.get_object("Tab", "aboutTab")

    def test_hint_button(self):
        #open settings tab
        self.open_and_check_settings_tab()

        #click on hints switch to enalbe hints toolbar button
        hintsSwitchClickable = self.main_window.get_hints_switchClickable()
        lambda: self.assertThat(hintsSwitchClickable.text, Eventually(Equals("Hints")))

        #turn on (by clicking on it) hints switch if not already
        hintsSwitch = self.main_window.get_hints_switch()
        lambda: self.assertThat(hintsSwitch.id, Eventually(Equals("disableHints")))
        if hintsSwitch.checked == False:
           self.pointing_device.click_object(hintsSwitchClickable)

        #verify hints switch is clicked
        self.assertThat(hintsSwitch.checked, Eventually(Equals(True)))

        # exit settings tab by clicking on sudoku tab
        self.ubuntusdk.switch_to_tab(0)

        #verify settings sudoku tab is open
        self.verify_settings_tab_open()

        #click on hint button on tuolbar
        self.ubuntusdk.click_toolbar_button("hintbutton")
        gridButtons = self.main_window.get_blank_inputs()

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        self.assertThat(number_of_hints, Eventually(Equals(1)))

    def test_settings_tab(self):
        #open settings tab
        self.open_and_check_settings_tab()

        #********check difficulty selector ********
        #click on difficulty selector
        difficultySelector = self.main_window.get_difficulty_selector()
        lambda: self.assertThat(difficultySelector.text, Eventually(Equals("Difficulty")))
        self.pointing_device.click_object(difficultySelector)

        #select "Moderate" choice of difficulty selector
        difficultyChoices = self.main_window.get_difficulty_selector_labelvisual()
        difficultyChoice = difficultyChoices[3]
        self.assertThat(difficultyChoice.text, Eventually(Equals("Moderate")))

        self.pointing_device.click_object(difficultyChoice)
        self.verify_settings_tab_open()

        #********check theme selector ********
        #click on theme selector
        themeSelector = self.main_window.get_theme_selector()
        lambda: self.assertThat(themeSelector.text, Eventually(Equals("Theme")))
        self.pointing_device.click_object(themeSelector)

        #select "Simple" choice of theme selector
        themeChoices = self.main_window.get_theme_selector_labelvisual()
        themeChoice = themeChoices[3]
        self.assertThat(themeChoice.text, Eventually(Equals("Simple")))

        self.pointing_device.click_object(themeChoice)

        #******** check hint switch  ********
        #select hints switch
        hintsSwitchClickable = self.main_window.get_hints_switchClickable()
        lambda: self.assertThat(hintsSwitchClickable.text, Eventually(Equals("Hints")))
        hintsSwitch = self.main_window.get_hints_switch()
        lambda: self.assertThat(hintsSwitch.id, Eventually(Equals("disableHints")))

        #switch it on or off depending on it's state
        if hintsSwitch.checked == False:
           self.pointing_device.click_object(hintsSwitchClickable)
           self.assertThat(hintsSwitch.checked, Eventually(Equals(True)))
        else:
           self.pointing_device.click_object(hintsSwitchClickable)
           self.assertThat(hintsSwitch.checked, Eventually(Equals(False)))

        #******** check profile settings ********
        #select current profile
        currentProfile = self.main_window.get_current_profile()
        lambda: self.assertThat(currentProfile.text, Eventually(Equals("Current profile")))
        self.pointing_device.click_object(currentProfile)

        #let's change profile
        #verify select profile page opens
        self.get_and_verify_profile_page()

        #select "sudoku user" profile
        sudokuUserProfile = self.main_window.get_sudoku_user_profile()
        lambda: self.assertThat(sudokuUserProfile, Eventually(Equals("Sudoku User")))
        self.pointing_device.click_object(sudokuUserProfile)

        #verify changed profile
        currentProfile = self.main_window.get_current_profile()
        lambda: self.assertThat(currentProfile.value, Eventually(Equals("Sudoku User")))

        #let's add a user profile
        #verify add profile page opens
        sudokuAddProfile = self.main_window.get_add_profile()
        lambda: self.assertThat(sudokuAddProfile, Eventually(Equals("Sudoku User")))
        self.pointing_device.click_object(sudokuAddProfile)

        #verify add profile dialog opens
        addDialog = self.main_window.get_add_profile_dialog()
        lambda: self.assertThat(addDialog.title, Eventually(Equals("Add new profile")))

        #insert Lastname
        lastName = self.main_window.get_add_profile_Lastname_field()
        self.pointing_device.click_object(lastName)
        lambda: self.assertThat(lastName.placeholderText, Eventually(Equals("Lastname")))
        self.keyboard.type("Mylastname")
        lambda: self.assertThat(lastName.text, Eventually(Equals("Mylastname")))

        #insert Firstname
        firstName = self.main_window.get_add_profile_Firstname_field()
        self.pointing_device.click_object(firstName)
        lambda: self.assertThat(firstName.placeholderText, Eventually(Equals("Firstname")))
        self.keyboard.type("Myfirstname")
        lambda: self.assertThat(firstName.text, Eventually(Equals("Myfirstname")))

        #click OK button
        OKButton = self.main_window.get_add_profile_OKbutton()
        self.main_window.try_OK_Button()
        self.assertThat(OKButton.buttonText, Eventually(Equals("OK")))
        self.pointing_device.click_object(OKButton)
        self.verify_settings_tab_open()

        #******** check manage profiles ********
        #select manage profile
        manageProfile = self.main_window.get_manage_profiles()
        self.main_window.try_manage_profile()
        self.assertThat(manageProfile.text, Eventually(Equals("Manage profiles")))
        self.pointing_device.click_object(manageProfile)

        #verify select profile page opens
        self.get_and_verify_profile_page()

        #click on the new profile just added
        myProfile = self.main_window.get_Myfirstname_Mylastname_profile()
        self.main_window.try_my_profile()
        self.assertThat(myProfile.text, Eventually(Equals("Myfirstname Mylastname")))
        self.pointing_device.click_object(myProfile)

        #verify the edit profile dialog opens
        editProfileDialog = self.main_window.get_edit_profile_dialog()
        lambda: self.assertThat(editProfileDialog.text, Eventually(Equals("editProfileDialog")))

        #click on delete
        deleteButton = self.main_window.get_edit_profile_delete_button()
        self.main_window.try_delete_Button()
        self.assertThat(deleteButton.buttonText, Eventually(Equals("Delete")))
        self.pointing_device.click_object(deleteButton)
        self.verify_settings_tab_open()

        #verify settings tab is open
        self.verify_settings_tab_open()

    def open_and_check_settings_tab(self):
        #click on settings tab so to enable the hints button
        self.ubuntusdk.switch_to_tab(2)
        self.verify_settings_tab_open()

    def verify_settings_tab_open(self):
        #verify settings tab is open
        tabName = lambda: self.ubuntusdk.get_object("Tab","settingsTab")

        self.assertThat(tabName, Eventually(NotEquals(None)))

        #Check image loads
        aboutImage = lambda: self.ubuntusdk.get_object("QQuickImage", "aboutImage").progress
        self.assertThat(aboutImage, Eventually(Equals(1.0)))

        #Check the 'Author(s):' label is displayed
        aboutLabel = lambda: self.ubuntusdk.get_object("Label", "authorLabel").text
        self.assertThat(aboutLabel, Eventually(Equals("Author(s): ")))

        #Check the 'Contact:' label is displayed
        contactLabel = lambda: self.ubuntusdk.get_object("Label", "contactLabel").text
        self.assertThat(contactLabel, Eventually(Equals("Contact: ")))

        #Check correct Launchpad URL: is displayed
        urlLabel = lambda: self.ubuntusdk.get_object("Label", "urlLabel").text
        self.assertThat(urlLabel, Eventually(Equals(
            "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>")))

        #Check the 'Version:' label is displayed
        versionLabel = lambda: self.ubuntusdk.get_object("Label", "versionLabel").text
        self.assertThat(versionLabel, Eventually(Equals("Version: ")))

        #Check correct version is displayed
        version = lambda: self.ubuntusdk.get_object("Label", "version").text
        self.assertThat(version, Eventually(Equals("0.4.3")))

        #Check correct year is displayed
        yearLabel = lambda: self.ubuntusdk.get_object("Label", "yearLabel").text
        self.assertThat(yearLabel, Eventually(Equals("2013")))

    def get_and_verify_profile_page(self):
        profilePage = self.main_window.get_select_profile_sheet()
        lambda: self.assertThat(profilePage.title, Eventually(Equals("Select profile")))

