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
		self.ubuntusdk.click_toolbar_button("hintbutton")
		gridButtons = self.main_window.get_blank_inputs()
		
		number_of_hints = lambda: self.app.select_single(objectName="blockgrid").numberOfHints
		self.assertThat(number_of_hints, Eventually(Equals(1)))

    def test_about_tab(self):
        #Switch to the 'About' tab
        self.ubuntusdk.switch_to_tab(3)

        #Check for'About' tab selection
        tabName = lambda: self.ubuntusdk.get_object("Tab", "aboutTab")


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

    def open_and_check_settings_tab(self):
        #click on settings tab so to enable the hints button
        self.ubuntusdk.switch_to_tab(2)

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
        self.assertThat(version, Eventually(Equals("0.4")))

        #Check correct year is displayed
        yearLabel = lambda: self.ubuntusdk.get_object("Label", "yearLabel").text
        self.assertThat(yearLabel, Eventually(Equals("2013")))

