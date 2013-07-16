# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Sudoku app autopilot emulators."""


class MainWindow(object):
    """An emulator class that makes it easy to interact with the
    sudoku-app.

    """
    def __init__(self, app):
        self.app = app

    def get_blank_inputs(self):
        #generate a list of blank input fields from the game board
        #SudokuBlocksGrid->..->SudokuButton->QQuickTest->enabled == true
        inputs = self.app.select_single("SudokuBlocksGrid")
        blankInputsList = inputs.select_many("QQuickText", enabled=True)
        return blankInputsList

    def get_dialog_button(self, name):
        numberdialog = self.get_number_dialog()

        #SudokuDialogButton->QQuickText text =
        button = numberdialog.select_single("QQuickText",text=name)
        return button

    def get_number_dialog(self):
        return self.app.select_single("Dialog", objectNme="picknumberscreen")

    def get_hints_switch(self):
        return self.app.select_single("CheckBox", objectName="hintsSwitch")

    #for clicking on this works on the previous one (get_hints_switch) doesn't(but the previous
    #has the clicked property so I am using both
    def get_hints_switchClickable(self):
        return self.app.select_single("Standard", objectName="hintsSwitchClickable")




