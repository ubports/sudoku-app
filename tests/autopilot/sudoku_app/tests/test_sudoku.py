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

        #clear the value by pressing clear button
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
