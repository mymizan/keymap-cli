# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-03-07

### Added
- Implement CLI argument parser with CommandParser class
- Create Command enum supporting: add, remove, update, list, help
- Add comprehensive argument validation with error messages
- Implement help text with usage examples
- Add support for case-insensitive command parsing
- Create CommandParserTests with 14 test cases covering:
  - All command types (add, remove, update, list)
  - Missing/invalid arguments
  - Help flags (-h, --help)
  - Edge cases and complex expansions

### Changed
- Update main.swift to use CommandParser for CLI routing
- Implement command acknowledgement messages (Phase 4 implementation pending)

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — 🔲 Pending
- Phase 4: Data Manipulation — 🔲 Pending
- Phase 5: Plist Writing — 🔲 Pending
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 15 tests passing (14 CommandParserTests + 1 ReplacementManagerTests)
- Build: ✅ Success

## [0.1.0] - 2026-03-07

### Added
- Initialize Swift CLI project using Swift Package Manager
- Create main command entrypoint with binary name "keymap"
- Set up complete folder structure (CLI, Core, Storage, Utils modules)
- Configure Package.swift with executable and test targets
- Create placeholder modules for all phases:
  - CLI/CommandParser.swift
  - Core/ReplacementManager.swift
  - Core/ReplacementItem.swift
  - Storage/PlistReader.swift
  - Storage/PlistWriter.swift
  - Utils/OutputFormatter.swift
- Create initial test suite (ReplacementManagerTests)
- Added README with usage documentation
- Set up release folder structure (releases/v0.1.0)

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — 🔲 Pending
- Phase 3: Plist Reading — 🔲 Pending
- Phase 4: Data Manipulation — 🔲 Pending
- Phase 5: Plist Writing — 🔲 Pending
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending
