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

import uuid

from sudoku_app import tests


class ProfilesTestCase(tests.SudokuTestCase):

    def setUp(self):
        super().setUp()
        self.settings_page = self.app.main_view.go_to_settings()

    def add_new_test_profile(self):
        # There is no need to delete the profile created because we are using a
        # clean database.
        unique_id = uuid.uuid1()
        test_last_name = 'Test last name {}'.format(unique_id)
        test_first_name = 'Test first name {}'.format(unique_id)

        self.settings_page.add_profile(test_last_name, test_first_name)

        return test_first_name, test_last_name

    def format_profile_name(self, first_name, last_name):
        return '{} {}'.format(first_name, last_name)

    def test_add_new_profile_must_make_it_available_in_manage_profiles(self):
        test_first_name, test_last_name = self.add_new_test_profile()

        profiles = self.settings_page.get_profiles()
        self.assertIn(
            self.format_profile_name(test_first_name, test_last_name),
            profiles)

    def test_change_profile_must_update_selected_profile(self):
        test_first_name, test_last_name = self.add_new_test_profile()
        formated_test_profile_name = self.format_profile_name(
            test_first_name, test_last_name)

        self.settings_page.change_profile(formated_test_profile_name)

        self.assertEqual(
            self.settings_page.get_current_profile(),
            formated_test_profile_name)

    def test_delete_profile_must_remove_it_from_manage_profiles(self):
        test_first_name, test_last_name = self.add_new_test_profile()
        formated_test_profile_name = self.format_profile_name(
            test_first_name, test_last_name)

        self.settings_page.delete_profile(formated_test_profile_name)

        profiles = self.settings_page.get_profiles()
        self.assertNotIn(formated_test_profile_name, profiles)
