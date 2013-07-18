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
        self.ubuntusdk.click_toolbar_button("newgamebutton")

        number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.app.select_single(objectName="blockgrid").numberOfActions
        game_seconds = lambda: self.app.select_single(objectName="blockgrid").gameSeconds

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))
        self.assertThat(game_seconds, Eventually(Equals(0)))

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
        tabName = lambda: self.ubuntusdk.get_object("Tab","Sudoku")
        #self.assertThat(tabName, Eventually(NotEquals(None)))

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
        profilePage = self.main_window.get_select_profile_sheet()
        lambda: self.assertThat(profilePage.title, Eventually(Equals("Select profile")))

        #select "sudoku user" profile
        sudokuUserProfile = self.main_window.get_sudoku_user_profile()
        lambda: self.assertThat(sudokuUserProfile, Eventually(Equals("Sudoku User")))

        #click on close button
        profileCloseButton = self.main_window.get_user_profile_close_button()
        lambda: self.assertThat(profileCloseButton.text, Eventually(Equals("close")))
        self.pointing_device.click_object(profileCloseButton)

        #verify changed profile
        currentProfile = self.main_window.get_current_profile()
        lambda: self.assertThat(currentProfile.value, Eventually(Equals("Sudoku User")))

        #let's add a user profile



    def open_and_check_settings_tab(self):
        #click on settings tab so to enable the hints button
        self.ubuntusdk.switch_to_tab(2)

        #verify settings tab is open
        tabName = lambda: self.ubuntusdk.get_object("Tab","settingsTab")
        self.assertThat(tabName, Eventually(NotEquals(None)))

