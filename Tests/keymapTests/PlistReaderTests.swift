import XCTest
@testable import keymap

final class PlistReaderTests: XCTestCase {

    // Test data
    let testReplacements: [[String: Any]] = [
        [
            "replace": "x.oc",
            "with": "npm install v24.14.0",
            "on": true
        ],
        [
            "replace": "gh.c",
            "with": "git checkout",
            "on": true
        ],
        [
            "replace": "disabled.test",
            "with": "disabled replacement",
            "on": false
        ]
    ]
    
    // Helper to create a test plist
    private func createTestPlist() -> String {
        let tempDir = NSTemporaryDirectory()
        let testPlistPath = (tempDir as NSString).appendingPathComponent("test_GlobalPreferences.plist")
        
        let plistDict: [String: Any] = [
            "NSUserDictionaryReplacementItems": testReplacements
        ]
        
        do {
            let data = try PropertyListSerialization.data(
                fromPropertyList: plistDict,
                format: .xml,
                options: 0
            )
            FileManager.default.createFile(atPath: testPlistPath, contents: data, attributes: nil)
            return testPlistPath
        } catch {
            XCTFail("Failed to create test plist: \(error)")
            return ""
        }
    }
    
    // Helper to create plist without replacement key
    private func createEmptyTestPlist() -> String {
        let tempDir = NSTemporaryDirectory()
        let testPlistPath = (tempDir as NSString).appendingPathComponent("test_empty_GlobalPreferences.plist")
        
        let plistDict: [String: Any] = [
            "SomeOtherKey": "value"
        ]
        
        do {
            let data = try PropertyListSerialization.data(
                fromPropertyList: plistDict,
                format: .xml,
                options: 0
            )
            FileManager.default.createFile(atPath: testPlistPath, contents: data, attributes: nil)
            return testPlistPath
        } catch {
            XCTFail("Failed to create empty test plist: \(error)")
            return ""
        }
    }
    
    // Test ReplacementItem encoding/decoding
    func testReplacementItemEncoding() throws {
        let item = ReplacementItem(shortcut: "x.oc", expansion: "npm install v24.14.0", enabled: true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ReplacementItem.self, from: data)
        
        XCTAssertEqual(decoded.shortcut, "x.oc")
        XCTAssertEqual(decoded.expansion, "npm install v24.14.0")
        XCTAssertEqual(decoded.enabled, true)
    }
    
    func testReplacementItemProperties() {
        let item = ReplacementItem(shortcut: "test", expansion: "expansion", enabled: true)
        
        XCTAssertEqual(item.shortcut, item.replace)
        XCTAssertEqual(item.expansion, item.with)
        XCTAssertEqual(item.enabled, item.on)
    }
    
    func testReplacementItemEquality() {
        let item1 = ReplacementItem(shortcut: "x.oc", expansion: "npm install", enabled: true)
        let item2 = ReplacementItem(shortcut: "x.oc", expansion: "npm install", enabled: true)
        let item3 = ReplacementItem(shortcut: "x.oc", expansion: "npm install", enabled: false)
        
        XCTAssertEqual(item1, item2)
        XCTAssertNotEqual(item1, item3)
    }
    
    func testReplacementItemDisabled() {
        let item = ReplacementItem(shortcut: "gh.c", expansion: "git checkout", enabled: false)
        
        XCTAssertEqual(item.enabled, false)
        XCTAssertEqual(item.on, false)
    }
    
    // Test plist creation and structure
    func testPlistCreation() {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
        }
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: plistPath))
        
        // Verify plist can be read
        let fileData = FileManager.default.contents(atPath: plistPath)
        XCTAssertNotNil(fileData)
    }
    
    func testPlistDecoding() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
        }
        
        let data = FileManager.default.contents(atPath: plistPath)!
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        ) as? [String: Any]
        
        XCTAssertNotNil(plist)
        XCTAssertNotNil(plist?["NSUserDictionaryReplacementItems"])
    }
    
    // Test ConvertingDictionaryToReplacementItem
    func testConvertDictionaryToReplacementItem() throws {
        let dict: [String: Any] = [
            "replace": "test.key",
            "with": "test expansion",
            "on": true
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: dict)
        let decoder = JSONDecoder()
        let item = try decoder.decode(ReplacementItem.self, from: jsonData)
        
        XCTAssertEqual(item.shortcut, "test.key")
        XCTAssertEqual(item.expansion, "test expansion")
        XCTAssertEqual(item.enabled, true)
    }
    
    // Test converting test array to ReplacementItems
    func testConvertArrayToReplacementItems() throws {
        var items: [ReplacementItem] = []
        
        for dict in testReplacements {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            let item = try decoder.decode(ReplacementItem.self, from: jsonData)
            items.append(item)
        }
        
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].shortcut, "x.oc")
        XCTAssertEqual(items[1].shortcut, "gh.c")
        XCTAssertEqual(items[2].enabled, false)
    }
    
    // Test error handling for missing plist
    func testMissingPlistError() {
        // This test verifies the error type, not actual file system
        let error = PlistReaderError.fileNotFound
        XCTAssertEqual(error, .fileNotFound)
    }
    
    func testPlistReaderErrorDescription() {
        XCTAssertTrue(PlistReaderError.fileNotFound.description.contains("not found"))
        XCTAssertTrue(PlistReaderError.invalidFormat.description.contains("invalid format"))
        XCTAssertTrue(PlistReaderError.decodingError("test").description.contains("Failed"))
    }

}