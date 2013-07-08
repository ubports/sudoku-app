# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from sudoku_app import SudokuTestCase


class TestMainWindow(SudokuTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestMainWindow, self).tearDown()

    def test_toolbar_shows(self):
        """Make sure that dragging from the bottom reveals the hidden
        toolbar."""
        toolbar = self.main_window.get_toolbar()

        x, y, w, h = toolbar.globalRect
        tx = x + (w / 2)
        ty = y + (h - 2)

        self.pointing_device.drag(tx, ty, tx, ty - h)
        self.assertThat(toolbar.state, Eventually(Equals("spread")))
