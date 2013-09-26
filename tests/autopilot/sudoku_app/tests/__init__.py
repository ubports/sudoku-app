# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot tests."""

import os.path
import os
import shutil

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from testtools.matchers import GreaterThan, Equals

from ubuntuuitoolkit import emulators as toolkit_emulators
from sudoku_app import emulators


class SudokuTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    sudoku-app tests.

    """
    if model() == 'Desktop':
        scenarios = [('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [('with touch', dict(input_device_class=Touch))]

    local_location = "../../sudoku-app.qml"
    sqlite_dir = os.path.expanduser(
        "~/.local/share/Qt Project/QtQmlViewer/QML/OfflineStorage/Databases")
    backup_dir = sqlite_dir + ".backup"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(SudokuTestCase, self).setUp()

        #backup and wipe db's before testing
        self.temp_move_sqlite_db()
        self.addCleanup(self.restore_sqlite_db)

        if os.path.exists(self.local_location):
            self.launch_test_local()
        elif os.path.exists('/usr/share/sudoku-app/sudoku-app.qml'):
            self.launch_test_installed()
        else:
            self.launch_test_click()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            "qmlscene",
            self.local_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_installed(self):
        self.app = self.launch_test_application(
            "qmlscene",
            "/usr/share/sudoku-app/sudoku-app.qml",
            "--desktop_file_hint=/usr/share/applications/sudoku-app.desktop",
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_click(self):
        self.app = self.launch_click_package('com.ubuntu.stock-ticker-mobile', emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def temp_move_sqlite_db(self):
        if os.path.exists(self.backup_dir):
            shutil.rmtree(self.backup_dir)
        if os.path.exists(self.sqlite_dir):
            shutil.move(self.sqlite_dir, self.backup_dir)
            self.assertThat(
                lambda: os.path.exists(self.backup_dir),
                Eventually(Equals(True)))

    def restore_sqlite_db(self):
        if os.path.exists(self.backup_dir) and os.path.exists(self.sqlite_dir):
            shutil.rmtree(self.sqlite_dir)
            self.assertThat(
                lambda: os.path.exists(self.sqlite_dir),
                Eventually(Equals(False)))
            shutil.move(self.backup_dir, self.sqlite_dir)
            self.assertTrue(
                lambda: os.path.exists(self.sqlite_dir),
                Eventually(Equals(True)))
        elif os.path.exists(self.backup_dir):
            shutil.move(self.backup_dir, self.sqlite_dir)
            self.assertTrue(
                lambda: os.path.exists(self.sqlite_dir),
                Eventually(Equals(True)))
        else:
            pass

    @property
    def main_view(self):
        return self.app.select_single(emulators.MainView)
