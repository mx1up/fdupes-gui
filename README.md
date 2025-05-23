# fdupes_gui

A graphical user interface front end for `fdupes` cli program. 

[Fdupes](https://github.com/adrianlopezroche/fdupes) is a program to detect duplicate files based on content in an efficient way. 

![screenshot](gfx/screenshot.png)

## Getting Started

Make sure the following prerequisites are met:
* `fdupes` command is available from `PATH`
  * When not found, you can still select the `fdupes` binary location manually.
* Download `fdupes_gui` from [releases](https://github.com/mx1up/fdupes-gui/releases)

## Usage

### Folder selection

Specify initial folders to scan for duplicates, either:
* Pass parameters (full folder paths) to the `fdupes_gui` executable
* Select a folder using the 'Select folder' button

Change folder: press the 'Change folder' button on the top left.

Add additional folders to scan for duplicates: press the + button on the top right.

Remove a folder: click the - button on the right of the folder name.

### Dupe group selection

Clicking on a dupe group will select it and show the duplicate instances on the right pane.

### Dupe instances

A dupe instance shows its simple filename if all dupes are in the same folder, or includes
its path relative to its base dir otherwise.

The following actions can be performed:

* Click on the filename to open the file in the default viewer
* Hover over the filename to see its full path
* Click on the edit button to rename the file
* Click on the trash button to delete the duplicate (no confirmation asked!)

### Refresh

Recalculates duplicates by pressing the 'Refresh' button top right.

## Config location

* MacOS: `~/Library/Preferences/be.shibby.fdupes-gui.plist`
* Linux: `~/.local/share/be.shibby.fdupes_gui/shared_preferences.json`