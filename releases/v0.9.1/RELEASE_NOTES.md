# keymap v0.9.1 Release

**Release Date:** March 7, 2026

## Overview
Patch release addressing a critical backup issue encountered when adding new shortcuts. A previous backup file could prevent the CLI from creating a fresh copy, causing commands to fail during the "saving changes" step.

## What's Fixed
- **BUG-001:** Creating a shortcut could fail with "Could not create backup of plist file" if `~/.GlobalPreferences.plist.backup` already existed. The writer now removes any existing backup before copying.
- Added `PlistWriter.backupExistingPlist(at:)` helper to support targeted testing.
- Regression test `testBackupIsRecreated` ensures backup behaviour remains correct.

## Test Coverage
- ✅ New unit test added; PlistWriter suite remains at 9 tests with 100% pass rate.
- ✅ All other existing tests continue to pass.

## Total Test Results
- ✅ 100% test pass rate after patch.

## Installation
```bash
swift build -c release
chmod +x keymap
sudo mv keymap /usr/local/bin/
```

## Notes
This release is a minor patch; functionality remains otherwise unchanged from v0.9.0.
