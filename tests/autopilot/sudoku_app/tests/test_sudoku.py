# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot tests."""

from __future__ import absolute_import
import unittest

from autopilot.matchers import Eventually
from testtools.matchers import Equals, Contains, NotEquals, Not, Is

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
        buttonValue = lambda: self.main_view.select_single("QQuickText",id=gridButton.id).text

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
        self.main_view.switch_to_tab("highscoresTab")

        #make sure we are in the right place
        tabName = lambda: self.main_view.select_single("Tab", objectName="highscoresTab")
        self.assertThat(tabName, Eventually(NotEquals(None)))

        #click current user button
        toolbar = self.main_view.open_toolbar()
        toolbar.click_button("currentuserbutton")

        #check label
        label = lambda: self.main_view.select_single("Header", objectName="highscoreslabel").text
        self.assertThat(label, Eventually(NotEquals("<b>Best scores for all players</b>")))

        #click all users button
        toolbar = self.main_view.open_toolbar()
        toolbar.click_button("allusersbutton")

        #check label again
        self.assertThat(label, Eventually(Equals("<b>Best scores for all players</b>")))

    def test_enter_and_cancel(self):
        #find the first button that has a blank value
        gridButtons = self.main_view.get_blank_inputs()
        gridButton = gridButtons[0]

        #create a value function to check later using id
        buttonValue = lambda: self.main_view.select_single("QQuickText",id=gridButton.id).text

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
        #open settings tab
        self.main_view.switch_to_tab("settingsTab")

        #testing new game with moderate mode
        #click on difficulty selector
        self.assertThat(self.main_view.get_difficulty_selector, Eventually(Not(Is(None))))
        difficultySelector = self.main_view.get_difficulty_selector()
        self.assertThat(difficultySelector.text, Eventually(Equals("Default Difficulty")))
        self.pointing_device.click_object(difficultySelector)

        #select "Moderate" choice of difficulty selector
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = filter(lambda choice: choice.text == 'Moderate', difficultyChoices)[0]
        self.pointing_device.click_object(difficultyChoice)
        self.assertThat(lambda: self.main_view.get_difficulty_selector_labelvisual()[0].text, Eventually(Equals("Moderate")))
        self._verify_game_start()

        #testing new game with always ask
        self._set_difficulty(6, "Always ask")

        #testing new game with always ask mode - easy
        self._verify_game_start(True, "easyGameButton")

        #testing new game with always ask mode - moderate
        self._verify_game_start(True, "moderateGameButton")

        #testing new game with always ask mode - hard
        self._verify_game_start(True, "hardGameButton")

        #testing new game with always ask mode - ultra hard
        self._verify_game_start(True, "ultrahardGameButton")

    def test_about_tab(self):
        #Switch to the 'About' tab
        self.main_view.switch_to_tab("aboutTab")

        #Check image loads
        aboutImage = lambda: self.main_view.select_single("QQuickImage", objectName="aboutImage").progress
        self.assertThat(aboutImage, Eventually(Equals(1.0)))

        #Check the 'Author(s):' label is displayed
        aboutLabel = lambda: self.main_view.select_single("Label", objectName="authorLabel").text
        self.assertThat(aboutLabel, Eventually(Equals("Author(s): ")))

        #Check the 'Contact:' label is displayed
        contactLabel = lambda: self.main_view.select_single("Label", objectName="contactLabel").text
        self.assertThat(contactLabel, Eventually(Equals("Contact: ")))

        #Check correct Launchpad URL: is displayed
        urlLabel = lambda: self.main_view.select_single("Label", objectName="urlLabel").text
        self.assertThat(urlLabel, Eventually(Equals(
            "<a href=\"https://launchpad.net/sudoku-app\">https://launchpad.net/sudoku-app</a>")))

        #Check the 'Version:' label is displayed
        versionLabel = lambda: self.main_view.select_single("Label", objectName="versionLabel").text
        self.assertThat(versionLabel, Eventually(Equals("Version: ")))

        #Check correct version is displayed
        version = lambda: self.main_view.select_single("Label", objectName="version").text
        self.assertThat(version, Eventually(Equals("1.0")))

        #Check correct year is displayed
        yearLabel = lambda: self.main_view.select_single("Label", objectName="yearLabel").text
        self.assertThat(yearLabel, Eventually(Equals("2013")))

    def test_hint_button(self):
        #open settings tab
        self.main_view.switch_to_tab("settingsTab")

        #click on hints switch to enalbe hints toolbar button
        self.assertThat(self.main_view.get_hints_switchClickable, Eventually(Not(Is(None))))
        hintsSwitchClickable = self.main_view.get_hints_switchClickable()
        self.assertThat(hintsSwitchClickable.text, Eventually(Equals("Hints")))

        #turn on (by clicking on it) hints switch if not already
        self.assertThat(self.main_view.get_hints_switch, Eventually(Not(Is(None))))
        hintsSwitch = self.main_view.get_hints_switch()
        if hintsSwitch.checked == False:
           self.pointing_device.click_object(hintsSwitchClickable)

        #verify hints switch is clicked
        self.assertThat(self.main_view.get_hints_switch().checked, Eventually(Equals(True)))

        # exit settings tab by clicking on sudoku tab
        self.main_view.switch_to_tab("MainTab")

        #click on hint button on tuolbar
        toolbar = self.main_view.open_toolbar()
        toolbar.click_button("hintbutton")
        gridButtons = self.main_view.get_blank_inputs()

        number_of_hints = lambda: self.main_view.select_single(objectName="blockgrid").numberOfHints
        self.assertThat(number_of_hints, Eventually(Equals(1)))

    def test_settings_tab(self):
        #open settings tab
        self.main_view.switch_to_tab("settingsTab")

        #********check difficulty selector ********
        #click on difficulty selector
        self.assertThat(self.main_view.get_difficulty_selector, Eventually(Not(Is(None))))
        difficultySelector = self.main_view.get_difficulty_selector()
        self.assertThat(difficultySelector.text, Eventually(Equals("Default Difficulty")))
        self.pointing_device.click_object(difficultySelector)

        #select "Moderate" choice of difficulty selector
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = filter(lambda choice: choice.text == 'Moderate', difficultyChoices)[0]
        self.pointing_device.click_object(difficultyChoice)
        self.assertThat(lambda: self.main_view.get_difficulty_selector_labelvisual()[0].text, Eventually(Equals("Moderate")))

        #********check theme selector ********
        #click on theme selector
        self.assertThat(self.main_view.get_theme_selector, Eventually(Not(Is(None))))
        themeSelector = self.main_view.get_theme_selector()
        self.assertThat(themeSelector.text, Eventually(Equals("Theme")))
        self.pointing_device.click_object(themeSelector)

        #select "Simple" choice of theme selector
        self.assertThat(self.main_view.get_theme_selector_labelvisual, Eventually(Not(Is(None))))
        themeChoices = self.main_view.get_theme_selector_labelvisual()
        themeChoice = filter(lambda choice: choice.text == 'Simple', themeChoices)[0]
        self.pointing_device.click_object(themeChoice)
        self.assertThat(lambda: self.main_view.get_theme_selector_labelvisual()[1].text, Eventually(Equals("Simple")))

        #******** check hint switch  ********
        #select hints switch
        self.assertThat(self.main_view.get_hints_switchClickable, Eventually(Not(Is(None))))
        hintsSwitchClickable = self.main_view.get_hints_switchClickable()
        self.assertThat(hintsSwitchClickable.text, Eventually(Equals("Hints")))
        self.assertThat(self.main_view.get_hints_switch, Eventually(Not(Is(None))))
        hintsSwitch = self.main_view.get_hints_switch()

        #switch it on or off depending on it's state
        if hintsSwitch.checked == False:
           self.pointing_device.click_object(hintsSwitchClickable)
           self.assertThat(hintsSwitch.checked, Eventually(Equals(True)))
        else:
           self.pointing_device.click_object(hintsSwitchClickable)
           self.assertThat(hintsSwitch.checked, Eventually(Equals(False)))

        #******** check profile settings ********
        #select current profile
        self.assertThat(self.main_view.get_current_profile, Eventually(Not(Is(None))))
        currentProfile = self.main_view.get_current_profile()
        self.pointing_device.click_object(currentProfile)

        #let's change profile
        #select "sudoku user" profile
        self.assertThat(self.main_view.get_sudoku_user_profile, Eventually(Not(Is(None))))
        sudokuUserProfile = self.main_view.get_sudoku_user_profile()
        self.pointing_device.click_object(sudokuUserProfile)

        #verify changed profile
        self.assertThat(self.main_view.get_current_profile, Eventually(Not(Is(None))))
        currentProfile = self.main_view.get_current_profile()
        self.assertThat(currentProfile.value, Equals("Sudoku User"))

        #let's add a user profile
        #verify add profile page opens
        self.assertThat(self.main_view.get_add_profile, Eventually(Not(Is(None))))
        sudokuAddProfile = self.main_view.get_add_profile()
        self.pointing_device.click_object(sudokuAddProfile)

        #insert Lastname
        self.assertThat(self.main_view.get_add_profile_Lastname_field, Eventually(Not(Is(None))))
        lastName = self.main_view.get_add_profile_Lastname_field()
        self.pointing_device.click_object(lastName)
        self.assertThat(lastName.placeholderText, Eventually(Equals("Lastname")))
        self.keyboard.type("Mylastname")
        self.assertThat(lastName.text, Eventually(Equals("Mylastname")))

        #insert Firstname
        self.assertThat(self.main_view.get_add_profile_Firstname_field, Eventually(Not(Is(None))))
        firstName = self.main_view.get_add_profile_Firstname_field()
        self.pointing_device.click_object(firstName)
        self.assertThat(firstName.placeholderText, Eventually(Equals("Firstname")))
        self.keyboard.type("Myfirstname")
        self.assertThat(firstName.text, Eventually(Equals("Myfirstname")))

        #click OK button
        OKButton = self.main_view.get_add_profile_OKbutton()
        self.main_view.try_OK_Button()
        self.assertThat(OKButton.buttonText, Eventually(Equals("OK")))
        self.pointing_device.click_object(OKButton)

        #******** check manage profiles ********
        #select manage profile
        self.assertThat(self.main_view.get_manage_profiles, Eventually(Not(Is(None))))
        manageProfile = self.main_view.get_manage_profiles()
        self.main_view.try_manage_profile()
        self.pointing_device.click_object(manageProfile)

        #click on the new profile just added
        timeout = 0
        myProfile = self.main_view.get_Myfirstname_Mylastname_profile()
        while myProfile == None and timeout < 10:
            timeout += 1
            manageProfile = self.main_view.get_manage_profiles()
            self.main_view.try_manage_profile()
            self.pointing_device.click_object(manageProfile)

        #self.assertThat(self.main_view.get_Myfirstname_Mylastname_profile, Eventually(Not(Is(None))))
        myProfile = self.main_view.get_Myfirstname_Mylastname_profile()
        self.assertThat(myProfile.text, Eventually(Equals("Myfirstname Mylastname")))
        self.pointing_device.click_object(myProfile)

        #click on delete
        deleteButton = self.main_view.get_edit_profile_delete_button()
        self.main_view.try_delete_Button()
        self.assertThat(deleteButton.buttonText, Eventually(Equals("Delete")))
        self.pointing_device.click_object(deleteButton)

        #check and make sure the profile is gone

    def _set_difficulty(self, selection, label):
        #set the difficulty of the game
        self.main_view.switch_to_tab("settingsTab")
        difficultySelector = self.main_view.get_difficulty_selector()
        self.pointing_device.click_object(difficultySelector)
        difficultyChoices = self.main_view.get_difficulty_selector_labelvisual()
        difficultyChoice = difficultyChoices[selection]
        self.assertThat(difficultyChoice.text, Eventually(Equals(label)))
        self.pointing_device.click_object(difficultyChoice)

    def _verify_game_start(self, askmode = False, button = None):
        #check the game starts properly (according to difficulty)
        self.main_view.switch_to_tab("MainTab")
        toolbar = self.main_view.open_toolbar()
        toolbar.click_button("newgamebutton")

        #if we're in ask mode, make sure we can grab all the buttons
        #and click the proper button
        if askmode:
            self.assertThat(self.main_view.get_new_game_easy_button().buttonText, Eventually(Equals("Easy")))
            self.assertThat(self.main_view.get_new_game_moderate_button().buttonText, Eventually(Equals("Moderate")))
            self.assertThat(self.main_view.get_new_game_hard_button().buttonText, Eventually(Equals("Hard")))
            self.assertThat(self.main_view.get_new_game_ultrahard_button().buttonText, Eventually(Equals("Ultra\nHard")))
            self.pointing_device.click_object(self.main_view.get_new_game_button(button))

        number_of_hints = lambda: self.main_view.select_single(objectName="blockgrid").numberOfHints
        number_of_actions = lambda: self.main_view.select_single(objectName="blockgrid").numberOfActions

        self.assertThat(number_of_hints, Eventually(Equals(0)))
        self.assertThat(number_of_actions, Eventually(Equals(0)))

        #verify clock is moving
        game_seconds = self.main_view.select_single(objectName="blockgrid").gameSeconds
        self.assertThat(self.main_view.select_single(objectName="blockgrid").gameSeconds, Eventually(NotEquals(game_seconds)))
        self.main_view.close_toolbar()
