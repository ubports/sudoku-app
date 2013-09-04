# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot tests."""

import os.path

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from sudoku_app.emulators.main_window import MainWindow
from sudoku_app.emulators.ubuntusdk import ubuntusdk


class SudokuTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    sudoku-app tests.

    """
    if model() == 'Desktop':
        scenarios = [('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [('with touch', dict(input_device_class=Touch))]

    local_location = "../../sudoku-app.qml"

    def setUp(self):
        self.clean_db()
        self.pointing_device = Pointer(self.input_device_class.create())
        super(SudokuTestCase, self).setUp()
        if os.path.exists(self.local_location):
            self.launch_test_local()
        else:
            self.launch_test_installed()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            "qmlscene",
            self.local_location,
            app_type='qt')

    def launch_test_installed(self):
        self.app = self.launch_test_application(
            "qmlscene",
            "/usr/share/sudoku-app/sudoku-app.qml",
            "--desktop_file_hint=/usr/share/applications/sudoku-app.desktop",
            app_type='qt')

    def find_db(self):
        dbs_path = os.path.expanduser("~/.local/share/Qt Project/QtQmlViewer/QML/OfflineStorage/Databases/")
        if not os.path.exists(dbs_path):
            return None

        files = [ f for f in os.listdir(dbs_path) if os.path.splitext(f)[1] == ".ini" ]
        for f in files:
            ini_path = os.path.join(dbs_path, f)
            with open(ini_path) as ini:
                for line in ini:
                    if "=" in line:
                        key, val = line.strip().split("=")
                        if key == "Name" and val == "SudokuTouch":
                            try:
                                return ini_path.replace(".ini", ".sqlite")
                            except OSError:
                                pass
        return None

    def clean_db(self):
        path = self.find_db()
        if path is None:
            self.launch_and_quit_app()
            path = self.find_db()
            if path is None:
                self.assertNotEquals(path, None)

        try:
            os.remove(path)
        except OSError:
            pass

    @property
    def main_window(self):
        return MainWindow(self.app)

    @property
    def ubuntusdk(self):
        return ubuntusdk(self, self.app)
