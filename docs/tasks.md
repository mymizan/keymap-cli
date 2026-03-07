# Implementation Tasks

## Phase 1 — Project Setup

- Initialize Swift CLI project using Swift Package Manager
- Create main command entrypoint
- Set binary name to "keymap"

---

## Phase 2 — CLI Argument Parsing

Implement commands:

keymap add <shortcut> <expansion>

keymap remove <shortcut>

keymap update <shortcut> <expansion>

keymap list

Validate arguments and print usage if incorrect.

---

## Phase 3 — Plist Reading

- Locate plist:

~/Library/Preferences/.GlobalPreferences.plist

- Parse key:

NSUserDictionaryReplacementItems

- Convert entries to Swift objects

---

## Phase 4 — Data Manipulation

Implement functions:

addShortcut()

removeShortcut()

updateShortcut()

listShortcuts()

Ensure duplicates are handled properly.

---

## Phase 5 — Plist Writing

- Serialize updated data
- Write plist back to disk
- Preserve existing keys

---

## Phase 6 — Output Formatting

Format list output:

shortcut        expansion
--------------------------------
x.oc            npm install v24.14.0

---

## Phase 7 — Error Handling

Handle cases:

- missing plist
- invalid commands
- duplicate entries
- file write failure

---

## Phase 8 — Testing

Test scenarios:

add new shortcut

update existing shortcut

remove shortcut

list multiple entries

verify macOS text replacement reflects changes

---

## Phase 9 — Future Improvements (Completed)

Optional commands implemented:

- keymap export
- keymap import
- keymap search
- keymap enable
- keymap disable

These all have associated tests and CLI support.

## Phase 10 — GUI

(Remains as a potential future enhancement.)
