import XCTest
@testable import keymap

final class IntegrationTests: XCTestCase {

    // MARK: - Business Logic Integration Tests

    func testManagerOperationsIntegration() {
        // Test that all manager operations work together correctly
        let manager = ReplacementManager()

        // Add multiple shortcuts
        try! manager.addShortcut("alpha", expansion: "first")
        try! manager.addShortcut("beta", expansion: "second")
        try! manager.addShortcut("gamma", expansion: "third")

        // Verify count
        XCTAssertEqual(manager.count(), 3)

        // Verify list is sorted
        let items = manager.listShortcuts()
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].shortcut, "alpha")
        XCTAssertEqual(items[1].shortcut, "beta")
        XCTAssertEqual(items[2].shortcut, "gamma")

        // Test update
        try! manager.updateShortcut("beta", expansion: "updated")
        let updatedItem = manager.getReplacement("beta")
        XCTAssertEqual(updatedItem?.expansion, "updated")
        XCTAssertTrue(updatedItem?.enabled ?? false) // Should preserve enabled state

        // Test remove
        try! manager.removeShortcut("alpha")
        XCTAssertEqual(manager.count(), 2)
        XCTAssertNil(manager.getReplacement("alpha"))

        // Verify remaining items
        let remaining = manager.listShortcuts()
        XCTAssertEqual(remaining.count, 2)
        XCTAssertEqual(remaining[0].shortcut, "beta")
        XCTAssertEqual(remaining[1].shortcut, "gamma")
    }

    func testErrorHandlingIntegration() {
        // Test that error handling works across components
        let manager = ReplacementManager()

        // Test duplicate addition
        try! manager.addShortcut("test", expansion: "value")
        XCTAssertThrowsError(try manager.addShortcut("test", expansion: "duplicate")) { error in
            XCTAssertEqual(error as? ReplacementManagerError, .shortcutAlreadyExists("test"))
        }

        // Test empty inputs
        XCTAssertThrowsError(try manager.addShortcut("", expansion: "test")) { error in
            XCTAssertEqual(error as? ReplacementManagerError, .emptyShortcut)
        }

        XCTAssertThrowsError(try manager.addShortcut("test", expansion: "")) { error in
            XCTAssertEqual(error as? ReplacementManagerError, .emptyExpansion)
        }

        // Test non-existent updates/removals
        XCTAssertThrowsError(try manager.updateShortcut("nonexistent", expansion: "test")) { error in
            XCTAssertEqual(error as? ReplacementManagerError, .shortcutNotFound("nonexistent"))
        }

        XCTAssertThrowsError(try manager.removeShortcut("nonexistent")) { error in
            XCTAssertEqual(error as? ReplacementManagerError, .shortcutNotFound("nonexistent"))
        }
    }

    func testOutputFormattingIntegration() {
        // Test that output formatting works with manager data
        let manager = ReplacementManager()
        try! manager.addShortcut("test", expansion: "expansion")

        let items = manager.getAll()

        // Test table format (headers should appear regardless of color codes)
        let tableOutput = OutputFormatter.formatList(items)
        XCTAssertTrue(tableOutput.contains("test"))
        XCTAssertTrue(tableOutput.contains("expansion"))
        XCTAssertTrue(tableOutput.lowercased().contains("shortcut")) // Header exists
        XCTAssertTrue(tableOutput.lowercased().contains("expansion")) // Header exists

        // Test JSON format
        let jsonOutput = OutputFormatter.formatJSON(items)
        XCTAssertTrue(jsonOutput.contains("\"shortcut\": \"test\""))
        XCTAssertTrue(jsonOutput.contains("\"expansion\": \"expansion\""))
        XCTAssertTrue(jsonOutput.contains("\"enabled\": true"))

        // Test summary format
        let summaryOutput = OutputFormatter.formatSummary(items)
        XCTAssertTrue(summaryOutput.contains("Total replacements: 1"))
        XCTAssertTrue(summaryOutput.contains("Enabled: 1"))
        XCTAssertTrue(summaryOutput.contains("Disabled: 0"))
    }

    func testCommandParsingIntegration() {
        // Test that command parsing works correctly
        let addCommand = CommandParser.parse(arguments: ["keymap", "add", "shortcut", "expansion"])
        if case .add(let shortcut, let expansion) = addCommand {
            XCTAssertEqual(shortcut, "shortcut")
            XCTAssertEqual(expansion, "expansion")
        } else {
            XCTFail("Expected add command")
        }

        let removeCommand = CommandParser.parse(arguments: ["keymap", "remove", "shortcut"])
        if case .remove(let shortcut) = removeCommand {
            XCTAssertEqual(shortcut, "shortcut")
        } else {
            XCTFail("Expected remove command")
        }

        let updateCommand = CommandParser.parse(arguments: ["keymap", "update", "shortcut", "new"])
        if case .update(let shortcut, let expansion) = updateCommand {
            XCTAssertEqual(shortcut, "shortcut")
            XCTAssertEqual(expansion, "new")
        } else {
            XCTFail("Expected update command")
        }

        let listCommand = CommandParser.parse(arguments: ["keymap", "list"])
        XCTAssertEqual(listCommand, .list)

        let helpCommand = CommandParser.parse(arguments: ["keymap", "help"])
        XCTAssertEqual(helpCommand, .help)
    }

    func testDataModelIntegration() {
        // Test that ReplacementItem works correctly with manager
        let manager = ReplacementManager()

        // Add item
        try! manager.addShortcut("test", expansion: "value")
        let item = manager.getReplacement("test")!

        // Verify properties
        XCTAssertEqual(item.shortcut, "test")
        XCTAssertEqual(item.expansion, "value")
        XCTAssertTrue(item.enabled)

        // Test Codable
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode([item])
        let jsonString = String(data: data, encoding: .utf8)!

        // Ensure JSON uses the underlying plist keys
        XCTAssertTrue(jsonString.contains("\"replace\""))
        XCTAssertTrue(jsonString.contains("\"with\""))
        XCTAssertTrue(jsonString.contains("\"on\" : 1")) // enabled = true

        // Test decoding
        let decoder = JSONDecoder()
        let decodedItems = try! decoder.decode([ReplacementItem].self, from: data)
        XCTAssertEqual(decodedItems.count, 1)
        XCTAssertEqual(decodedItems[0].shortcut, "test")
        XCTAssertEqual(decodedItems[0].expansion, "value")
        XCTAssertTrue(decodedItems[0].enabled)
    }

    func testWorkflowSimulation() {
        // Simulate a complete user workflow
        let manager = ReplacementManager()

        // User adds some shortcuts
        try! manager.addShortcut("omw", expansion: "On my way!")
        try! manager.addShortcut("brb", expansion: "Be right back")
        try! manager.addShortcut("ty", expansion: "Thank you!")

        // Verify all added
        XCTAssertEqual(manager.count(), 3)

        // User lists them
        let list = manager.listShortcuts()
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list.map { $0.shortcut }, ["brb", "omw", "ty"]) // Sorted

        // User updates one
        try! manager.updateShortcut("ty", expansion: "Thank you so much!")
        XCTAssertEqual(manager.getReplacement("ty")?.expansion, "Thank you so much!")

        // User removes one
        try! manager.removeShortcut("brb")
        XCTAssertEqual(manager.count(), 2)
        XCTAssertNil(manager.getReplacement("brb"))

        // Final list
        let finalList = manager.listShortcuts()
        XCTAssertEqual(finalList.count, 2)
        XCTAssertEqual(finalList.map { $0.shortcut }, ["omw", "ty"])
    }

    func testSearchEnableDisableImportExport() {
        let manager = ReplacementManager()
        try! manager.addShortcut("foo", expansion: "bar")
        try! manager.addShortcut("baz", expansion: "qux")
        
        // search
        let searchResults = manager.search("b")
        XCTAssertEqual(searchResults.map { $0.shortcut }.sorted(), ["baz", "foo"])
        
        // disable and enable
        try! manager.disableShortcut("foo")
        XCTAssertFalse(manager.getReplacement("foo")?.enabled ?? true)
        try! manager.enableShortcut("foo")
        XCTAssertTrue(manager.getReplacement("foo")?.enabled ?? false)
        
        // export and import roundtrip
        let exported = manager.exportItems()
        let jsonData = try! JSONEncoder().encode(exported)
        let decoded = try! JSONDecoder().decode([ReplacementItem].self, from: jsonData)
        let newManager = ReplacementManager()
        _ = newManager.importItems(decoded)
        XCTAssertEqual(newManager.count(), manager.count())
        XCTAssertEqual(newManager.listShortcuts().map { $0.shortcut }.sorted(), ["baz", "foo"])
    }
}