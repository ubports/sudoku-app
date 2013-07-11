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
        #sudokuButton->QQuickTest->enabled == true
        #save the id
        #click the button
        #set a value
        #check the value to ensure it worked
        #click the button
        #clear the value
        #check the value to ensure it worked

    def test_best_scores_tab(self):
        #switch to best scores tab
        self.ubuntusdk.switch_to_tab(1)
        #click current user button
        self.ubuntusdk.click_toolbar_button("currentuserbutton")
        #check label
        label = lambda: self.ubuntusdk.get_object("Header","highscoreslabel").text
        self.assertThat(label, Eventually(NotEquals("<b>Best scores for all players</b>")))
        #click all users button
        self.ubuntusdk.click_toolbar_button("allusersbutton")
        #check label
        self.assertThat(label, Eventually(Equals("<b>Best scores for all players</b>")))
