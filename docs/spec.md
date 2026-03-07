# Project Specification

## Project Name
macOS Text Replacement CLI Manager

## Goal
Create a command-line tool that allows developers to manage macOS Text Replacement shortcuts directly from the terminal.

The tool should interact with the same storage used by:

System Settings → Keyboard → Text Replacements

The purpose is to avoid the slow GUI workflow and allow fast automation.

Example usage:

keymap add x.oc "npm install v24.14.0"

---

## Target Platform

macOS (Ventura or newer)

The tool must run without administrator privileges.

---

## Programming Language

Swift

Reasons:

- Native macOS compatibility
- Strong support for property lists (plist)
- Simple distribution as a single compiled binary
- Works well with Swift Package Manager

---

## Binary Name

keymap

Example command:

keymap add x.oc "npm install v24.14.0"

---

## macOS Data Location

The text replacement entries exist in:

~/Library/Preferences/.GlobalPreferences.plist

Key:

NSUserDictionaryReplacementItems

Example structure:

[
  {
    "on": 1,
    "replace": "x.oc",
    "with": "npm install v24.14.0"
  }
]

---

## Core Features

### Add Shortcut

Command:

keymap add <shortcut> <expansion>

Example:

keymap add x.oc "npm install v24.14.0"

Behavior:

- Add new replacement entry
- If shortcut exists, update it
- Ensure "on" = 1

---

### Remove Shortcut

Command:

keymap remove <shortcut>

Example:

keymap remove x.oc

Behavior:

- Remove entry where replace equals shortcut

---

### List Shortcuts

Command:

keymap list

Output example:

shortcut        expansion
--------------------------------
x.oc            npm install v24.14.0
gh.c            git checkout

---

### Update Shortcut

Command:

keymap update <shortcut> <expansion>

Behavior:

- Update the expansion text

---

## CLI Design Philosophy

Commands should feel similar to:

git  
npm  
brew  

Predictable and minimal.

---

## Expected Outcome

A lightweight developer tool that manages macOS text replacements without opening System Settings.
