# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014 Canonical
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

import logging

import autopilot.logging
import ubuntuuitoolkit
from autopilot import introspection


logger = logging.getLogger(__name__)


class Page11(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    # Due to https://bugs.launchpad.net/autopilot-qt/+bug/1341671
    # it must be called Page11

    """Autopilot helper for the Settings page."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page11':
            if state['objectName'][1] == 'settingsPage':
                return True
        return False

    @autopilot.logging.log_action(logger.info)
    def add_profile(self, last_name, first_name):
        self._click_item('Add profile')
        dialog = self.get_root_instance().select_single(
            objectName='Add new profile'
        )
        dialog.add_new_profile(last_name, first_name)

    @autopilot.logging.log_action(logger.debug)
    def _click_item(self, object_name):
        item = self.select_single(objectName=object_name)
        flickable = self.select_single(
            ubuntuuitoolkit.QQuickFlickable,
            objectName='settingsContainer'
        )
        flickable.swipe_child_into_view(item)
        self.pointing_device.click_object(item)

    def get_profiles(self):
        """Return a list with the names of the existing profiles."""
        manage_profile_dialog = self._go_to_manage_profiles()
        profiles = manage_profile_dialog.get_profiles()
        manage_profile_dialog.click_cancel()
        return profiles

    @autopilot.logging.log_action(logger.debug)
    def _go_to_manage_profiles(self):
        self._click_item('Manage profiles')
        return self.get_root_instance().select_single(
            objectName='manageProfileDialog'
        )

    @autopilot.logging.log_action(logger.debug)
    def change_profile(self, profile_name):
        select_profile_dialog = self._go_to_select_profiles()
        select_profile_dialog.select(profile_name)

    @autopilot.logging.log_action(logger.debug)
    def _go_to_select_profiles(self):
        self._click_item('Current profile')
        return self.get_root_instance().select_single(
            objectName='selectProfileDialog'
        )

    def get_current_profile(self):
        """Return the name of the current profile."""
        current_profile_item = self.select_single(objectName='Current profile')
        return current_profile_item.value

    @autopilot.logging.log_action(logger.info)
    def delete_profile(self, profile_name):
        manage_profile_dialog = self._go_to_manage_profiles()
        manage_profile_dialog.delete_profile(profile_name)


class AddNewProfileDialog(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Add new profile dialog."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Dialog':
            if state['objectName'][1] == 'Add new profile':
                return True
        return False

    @autopilot.logging.log_action(logger.debug)
    def add_new_profile(self, last_name, first_name):
        self._fill_form(last_name, first_name)
        self._click_ok()
        self.wait_until_destroyed()

    @autopilot.logging.log_action(logger.debug)
    def _fill_form(self, last_name, first_name):
        last_name_text_field = self.select_single(
            ubuntuuitoolkit.TextField,
            objectName='Lastname'
        )
        last_name_text_field.write(last_name)
        first_name_text_field = self.select_single(
            ubuntuuitoolkit.TextField,
            objectName='Firstname'
        )
        first_name_text_field.write(first_name)

    def _click_ok(self):
        ok_button = self.select_single(
            'SudokuDialogButton',
            objectName='OKbutton'
        )
        self.pointing_device.click_object(ok_button)


class ProfileDialog(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    PROFILE_LIST_VIEW_OBJECT_NAME = None

    def get_profiles(self):
        """Return a list with the names of the existing profiles."""
        profile_list_view = self._get_profile_list_view()
        profile_items = profile_list_view.select_many(
            ubuntuuitoolkit.listitems.Standard
        )
        # Sort by the position on the list.
        sorted_items = sorted(
            profile_items,
            key=lambda item: item.globalRect.y)
        profiles = [item.text for item in sorted_items]
        return profiles

    def _get_profile_list_view(self):
        return self.select_single(
            ubuntuuitoolkit.QQuickListView,
            objectName=self.PROFILE_LIST_VIEW_OBJECT_NAME
        )

    @autopilot.logging.log_action(logger.debug)
    def click_profile(self, profile_name):
        profile_list_view = self._get_profile_list_view()
        profile_item = profile_list_view.select_single(
            ubuntuuitoolkit.listitems.Standard,
            text=profile_name
        )
        self.pointing_device.click_object(profile_item)


class SelectProfileDialog(ProfileDialog):

    """Autopilot helper for the Select profile dialog."""

    PROFILE_LIST_VIEW_OBJECT_NAME = 'profileListView'

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Dialog':
            if state['objectName'][1] == 'selectProfileDialog':
                return True
        return False

    def select(self, profile_name):
        self.click_profile(profile_name)
        self.wait_until_destroyed()


class ManageProfileDialog(ProfileDialog):

    """Autopilot helper for the Select profile dialog."""

    PROFILE_LIST_VIEW_OBJECT_NAME = 'manageProfileListView'

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Dialog':
            if state['objectName'][1] == 'manageProfileDialog':
                return True
        return False

    @autopilot.logging.log_action(logger.debug)
    def click_cancel(self):
        cancel_button = self.select_single(
            'SudokuDialogButton',
            objectName='cancelButton'
        )
        self.pointing_device.click_object(cancel_button)
        self.wait_until_destroyed()

    def delete_profile(self, profile_name):
        root = self.get_root_instance()
        self._open_profile(profile_name)
        self.wait_until_destroyed()
        edit_profile_dialog = root.select_single(objectName='Edit profile')
        edit_profile_dialog.delete()

    @autopilot.logging.log_action(logger.debug)
    def _open_profile(self, profile_name):
        self.click_profile(profile_name)


class EditProfileDialog(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Dialog':
            if state['objectName'][1] == 'Edit profile':
                return True
        return False

    @autopilot.logging.log_action(logger.debug)
    def delete(self):
        delete_button = self.select_single(
            'SudokuDialogButton', objectName='deleteButton')
        self.pointing_device.click_object(delete_button)
        self.wait_until_destroyed()
