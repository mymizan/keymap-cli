import XCTest
@testable import keymap

final class OutputFormatterTests: XCTestCase {

    let testItems: [ReplacementItem] = [
        ReplacementItem(shortcut: "x.oc", expansion: "npm install v24.14.0", enabled: true),
        ReplacementItem(shortcut: "gh.c", expansion: "git checkout", enabled: true),
        ReplacementItem(shortcut: "gs.s", expansion: "git status", enabled: true)
    ]
    
    let disabledItems: [ReplacementItem] = [
        ReplacementItem(shortcut: "disabled", expansion: "disabled replacement", enabled: false)
    ]
    
    // MARK: - List Formatting Tests
    
    func testFormatListEmpty() {
        let result = OutputFormatter.formatList([])
        XCTAssertEqual(result, "No text replacements found.")
    }
    
    func testFormatListSingle() {
        let items = [ReplacementItem(shortcut: "x.oc", expansion: "npm install", enabled: true)]
        let result = OutputFormatter.formatList(items)
        
        XCTAssertTrue(result.contains("x.oc"))
        XCTAssertTrue(result.contains("npm install"))
        XCTAssertTrue(result.contains("shortcut"))
        XCTAssertTrue(result.contains("expansion"))
    }
    
    func testFormatListMultiple() {
        let result = OutputFormatter.formatList(testItems)
        
        XCTAssertTrue(result.contains("x.oc"))
        XCTAssertTrue(result.contains("gh.c"))
        XCTAssertTrue(result.contains("gs.s"))
        XCTAssertTrue(result.contains("shortcut"))
        XCTAssertTrue(result.contains("expansion"))
    }
    
    func testFormatListSorted() {
        let unsorted = [
            ReplacementItem(shortcut: "z.test", expansion: "z", enabled: true),
            ReplacementItem(shortcut: "a.test", expansion: "a", enabled: true),
            ReplacementItem(shortcut: "m.test", expansion: "m", enabled: true)
        ]
        
        let result = OutputFormatter.formatList(unsorted)
        
        // Verify all shortcuts are present
        XCTAssertTrue(result.contains("a.test"))
        XCTAssertTrue(result.contains("m.test"))
        XCTAssertTrue(result.contains("z.test"))
        
        // Verify they appear in order by checking line positions
        let aPos = result.range(of: "a.test")?.lowerBound ?? result.startIndex
        let mPos = result.range(of: "m.test")?.lowerBound ?? result.startIndex
        let zPos = result.range(of: "z.test")?.lowerBound ?? result.startIndex
        
        XCTAssertTrue(aPos < mPos && mPos < zPos, "Items should be sorted alphabetically")
    }
    
    func testFormatListHasHeaders() {
        let result = OutputFormatter.formatList(testItems)
        
        XCTAssertTrue(result.contains("shortcut"))
        XCTAssertTrue(result.contains("expansion"))
    }
    
    func testFormatListHasSeparator() {
        let result = OutputFormatter.formatList(testItems)
        
        XCTAssertTrue(result.contains("-"))
    }
    
    // MARK: - JSON Format Tests
    
    func testFormatJSONEmpty() {
        let result = OutputFormatter.formatJSON([])
        // prettyPrinted adds formatting, so check it starts and ends properly
        XCTAssertTrue(result.contains("["))
        XCTAssertTrue(result.contains("]"))
    }
    
    func testFormatJSONSingle() {
        let items = [ReplacementItem(shortcut: "test", expansion: "value", enabled: true)]
        let result = OutputFormatter.formatJSON(items)
        
        XCTAssertTrue(result.contains("test"))
        XCTAssertTrue(result.contains("value"))
        XCTAssertTrue(result.contains("true"))
    }
    
    func testFormatJSONMultiple() {
        let result = OutputFormatter.formatJSON(testItems)
        
        XCTAssertTrue(result.contains("x.oc"))
        XCTAssertTrue(result.contains("gh.c"))
        XCTAssertTrue(result.contains("enabled"))
    }
    
    // MARK: - Summary Format Tests
    
    func testFormatSummary() {
        let result = OutputFormatter.formatSummary(testItems)
        
        XCTAssertTrue(result.contains("Summary"))
        XCTAssertTrue(result.contains("3"))
        XCTAssertTrue(result.contains("Enabled"))
    }
    
    func testFormatSummaryVary() {
        var items = testItems
        items.append(ReplacementItem(shortcut: "disabled", expansion: "test", enabled: false))
        
        let result = OutputFormatter.formatSummary(items)
        
        XCTAssertTrue(result.contains("4"))
        XCTAssertTrue(result.contains("Disabled"))
    }
    
    // MARK: - Message Formatting Tests
    
    func testFormatError() {
        let result = OutputFormatter.formatError("Error message")
        XCTAssertTrue(result.contains("Error message"))
    }
    
    func testFormatSuccess() {
        let result = OutputFormatter.formatSuccess("Operation complete")
        XCTAssertTrue(result.contains("Operation complete"))
        XCTAssertTrue(result.contains("✓"))
    }
    
    func testFormatWarning() {
        let result = OutputFormatter.formatWarning("Be careful")
        XCTAssertTrue(result.contains("Be careful"))
        XCTAssertTrue(result.contains("⚠"))
    }
    
    // MARK: - Column Width Tests
    
    func testColumnWidthCalculation() {
        let shortItems = [
            ReplacementItem(shortcut: "a.b", expansion: "short", enabled: true)
        ]
        let result = OutputFormatter.formatList(shortItems)
        
        XCTAssertTrue(result.contains("a.b"))
        XCTAssertTrue(result.contains("short"))
    }
    
    func testColumnWidthLongShortcuts() {
        let longItems = [
            ReplacementItem(shortcut: "very.long.shortcut.name", expansion: "expansion", enabled: true)
        ]
        let result = OutputFormatter.formatList(longItems)
        
        XCTAssertTrue(result.contains("very.long.shortcut.name"))
    }
    
    // MARK: - Disabled Item Tests
    
    func testFormatDisabledItems() {
        let result = OutputFormatter.formatList(disabledItems)
        
        XCTAssertTrue(result.contains("disabled"))
        XCTAssertTrue(result.contains("disabled replacement"))
    }
    
    func testFormatMixedEnabled() {
        var items = testItems
        items.append(ReplacementItem(shortcut: "disabled", expansion: "test", enabled: false))
        
        let result = OutputFormatter.formatList(items)
        
        XCTAssertTrue(result.contains("disabled"))
        XCTAssertTrue(result.contains("x.oc"))
    }
    
    // MARK: - Edge Cases
    
    func testFormatSpecialCharacters() {
        let items = [
            ReplacementItem(shortcut: "test@123", expansion: "special: chars!", enabled: true)
        ]
        let result = OutputFormatter.formatList(items)
        
        XCTAssertTrue(result.contains("test@123"))
        XCTAssertTrue(result.contains("special: chars!"))
    }
    
    func testFormatUnicodeCharacters() {
        let items = [
            ReplacementItem(shortcut: "emoji👍", expansion: "unicode✨", enabled: true)
        ]
        let result = OutputFormatter.formatList(items)
        
        XCTAssertTrue(result.contains("emoji"))
        XCTAssertTrue(result.contains("unicode"))
    }

}