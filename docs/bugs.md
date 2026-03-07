# Known Bugs

This document tracks confirmed bugs.

AI agents must follow these rules:

1. Bugs with Status: Open must be considered active issues.
2. Bugs with Status: Closed are historical records and should not be treated as active problems.
3. When implementing new features, ensure fixes listed here are not reintroduced.

## BUG-001

Title:
Cannot add a new shortcut

Description:
The CLI fails when attempting to add a new shortcut.  
The operation stops during the "saving changes" step with a plist backup error.

Error message:

Error: Could not create backup of plist file  
Hint: Check disk space and file permissions for ~/.GlobalPreferences.plist

Expected behavior:
Running the command

keymap add <shortcut> <expansion>

should add the shortcut to the macOS text replacement list stored in:

~/Library/Preferences/.GlobalPreferences.plist

After the command completes successfully, the new shortcut should be visible in:

System Settings → Keyboard → Text Replacements

Actual behavior:
The command fails and the shortcut is not added to the plist file.

Reproduction steps:

1. Run the following command:

keymap add x.oc "npm install v24.14.0"

2. Observe the error message displayed in the terminal.

Result:
The shortcut is not added and the command exits with an error.

Environment:
macOS: [version]  
Machine: MacBook Pro M4  
CLI version: [version]

Possible cause:
The application may not have permission to write to the plist file or create the backup file.
The backup process may also be referencing an incorrect file path.

Status: Closed (fixed in v0.9.1)  
Priority: High