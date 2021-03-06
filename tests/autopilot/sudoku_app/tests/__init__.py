# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014 Canonical
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Sudoku app autopilot tests."""

import os
import shutil
import logging

from autopilot.input import Mouse, Touch, Pointer
from autopilot.matchers import Eventually
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from testtools.matchers import Equals
from ubuntuuitoolkit import (
    base,
    emulators as toolkit_emulators,
)

import sudoku_app

logger = logging.getLogger(__name__)


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
        "~/.local/share/com.ubuntu.sudoku/Databases")
    backup_dir = sqlite_dir + ".backup"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(SudokuTestCase, self).setUp()

        # backup and wipe db's before testing
        self.temp_move_sqlite_db()
        self.addCleanup(self.restore_sqlite_db)

        if os.path.exists(self.local_location):
            app_proxy = self.launch_test_local()
        elif os.path.exists('/usr/share/sudoku-app/sudoku-app.qml'):
            app_proxy = self.launch_test_installed()
        else:
            app_proxy = self.launch_test_click()

        self.app = sudoku_app.SudokuApp(app_proxy)
        self.assertThat(
            self.app.main_view.visible,
            Eventually(Equals(True))
        )

    def launch_test_local(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.local_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase
        )

    def launch_test_installed(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            "/usr/share/sudoku-app/sudoku-app.qml",
            "--desktop_file_hint=/usr/share/applications/sudoku-app.desktop",
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase
        )

    def launch_test_click(self):
        return self.launch_click_package(
            'com.ubuntu.sudoku',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase
        )

    def temp_move_sqlite_db(self):
        try:
            shutil.rmtree(self.backup_dir)
        except:
            pass
        else:
            logger.warning("Prexisting backup database found and removed")

        try:
            shutil.move(self.sqlite_dir, self.backup_dir)
        except:
            logger.warning("No current database found")
        else:
            logger.debug("Backed up database")

    def restore_sqlite_db(self):
        if os.path.exists(self.backup_dir):
            if os.path.exists(self.sqlite_dir):
                try:
                    shutil.rmtree(self.sqlite_dir)
                except:
                    logger.error(
                        'Failed to remove test database and restore database'
                    )
                    return
            try:
                shutil.move(self.backup_dir, self.sqlite_dir)
            except:
                logger.error("Failed to restore database")
