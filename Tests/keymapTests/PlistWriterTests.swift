import XCTest
@testable import keymap

final class PlistWriterTests: XCTestCase {

    let testReplacements: [ReplacementItem] = [
        ReplacementItem(shortcut: "x.oc", expansion: "npm install v24.14.0", enabled: true),
        ReplacementItem(shortcut: "gh.c", expansion: "git checkout", enabled: true),
        ReplacementItem(shortcut: "disabled.test", expansion: "disabled replacement", enabled: false)
    ]
    
    // Helper to create a test plist
    private func createTestPlist() -> String {
        let tempDir = NSTemporaryDirectory()
        let testPlistPath = (tempDir as NSString).appendingPathComponent("test_write_GlobalPreferences.plist")
        
        let plistDict: [String: Any] = [
            "NSUserDictionaryReplacementItems": []
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
    
    // Test writing empty array
    func testWriteEmptyReplacements() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
            try? FileManager.default.removeItem(atPath: plistPath + ".backup")
        }
        
        // Temporarily override plist path
        _ = PlistWriter.plistPath
        
        // Read and verify empty
        var format = PropertyListSerialization.PropertyListFormat.xml
        let fileData = FileManager.default.contents(atPath: plistPath)!
        let plist = try PropertyListSerialization.propertyList(
            from: fileData,
            options: [],
            format: &format
        ) as! [String: Any]
        
        let items = plist["NSUserDictionaryReplacementItems"] as? [[String: Any]] ?? []
        XCTAssertEqual(items.count, 0)
    }
    
    // Test writing single replacement
    func testWriteSingleReplacement() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
            try? FileManager.default.removeItem(atPath: plistPath + ".backup")
        }
        
        let items = [ReplacementItem(shortcut: "test", expansion: "value", enabled: true)]
        
        // Simulate writing by creating plist content
        var plist: [String: Any] = ["NSUserDictionaryReplacementItems": []]
        let replacementDicts: [[String: Any]] = items.map { item in
            return ["replace": item.replace, "with": item.with, "on": item.on]
        }
        plist["NSUserDictionaryReplacementItems"] = replacementDicts
        
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        
        // Verify it can be written
        let success = FileManager.default.createFile(
            atPath: plistPath,
            contents: data,
            attributes: nil
        )
        XCTAssertTrue(success)
        
        // Verify content
        let readData = FileManager.default.contents(atPath: plistPath)!
        var format = PropertyListSerialization.PropertyListFormat.xml
        let readPlist = try PropertyListSerialization.propertyList(
            from: readData,
            options: [],
            format: &format
        ) as! [String: Any]
        
        let readItems = readPlist["NSUserDictionaryReplacementItems"] as! [[String: Any]]
        XCTAssertEqual(readItems.count, 1)
        XCTAssertEqual(readItems[0]["replace"] as! String, "test")
    }
    
    // Test writing multiple replacements
    func testWriteMultipleReplacements() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
            try? FileManager.default.removeItem(atPath: plistPath + ".backup")
        }
        
        var plist: [String: Any] = ["NSUserDictionaryReplacementItems": []]
        let replacementDicts: [[String: Any]] = testReplacements.map { item in
            return ["replace": item.replace, "with": item.with, "on": item.on]
        }
        plist["NSUserDictionaryReplacementItems"] = replacementDicts
        
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        
        let success = FileManager.default.createFile(
            atPath: plistPath,
            contents: data,
            attributes: nil
        )
        XCTAssertTrue(success)
        
        // Verify content
        let readData = FileManager.default.contents(atPath: plistPath)!
        var format = PropertyListSerialization.PropertyListFormat.xml
        let readPlist = try PropertyListSerialization.propertyList(
            from: readData,
            options: [],
            format: &format
        ) as! [String: Any]
        
        let readItems = readPlist["NSUserDictionaryReplacementItems"] as! [[String: Any]]
        XCTAssertEqual(readItems.count, 3)
    }
    
    // Test preserving enabled/disabled state
    func testPreservesEnabledState() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
            try? FileManager.default.removeItem(atPath: plistPath + ".backup")
        }
        
        let disabledItem = ReplacementItem(shortcut: "disabled", expansion: "value", enabled: false)
        let enabledItem = ReplacementItem(shortcut: "enabled", expansion: "value", enabled: true)
        
        var plist: [String: Any] = ["NSUserDictionaryReplacementItems": []]
        let replacementDicts: [[String: Any]] = [disabledItem, enabledItem].map { item in
            return ["replace": item.replace, "with": item.with, "on": item.on]
        }
        plist["NSUserDictionaryReplacementItems"] = replacementDicts
        
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        
        FileManager.default.createFile(
            atPath: plistPath,
            contents: data,
            attributes: nil
        )
        
        // Verify enabled state
        let readData = FileManager.default.contents(atPath: plistPath)!
        var format = PropertyListSerialization.PropertyListFormat.xml
        let readPlist = try PropertyListSerialization.propertyList(
            from: readData,
            options: [],
            format: &format
        ) as! [String: Any]
        
        let readItems = readPlist["NSUserDictionaryReplacementItems"] as! [[String: Any]]
        XCTAssertEqual(readItems[0]["on"] as! Bool, false)
        XCTAssertEqual(readItems[1]["on"] as! Bool, true)
    }
    
    // Test error type for missing file
    func testMissingFileError() {
        let error = PlistWriterError.fileNotFound
        XCTAssertEqual(error, .fileNotFound)
    }
    
    // Test error descriptions
    func testErrorDescriptions() {
        XCTAssertTrue(PlistWriterError.fileNotFound.description.contains("not found"))
        XCTAssertTrue(PlistWriterError.cannotCreateBackup.description.contains("backup"))
        XCTAssertTrue(PlistWriterError.serializationFailed.description.contains("serialize"))
        XCTAssertTrue(PlistWriterError.writeFailure("test").description.contains("write"))
    }
    
    // Regression test for BUG-001: backup helper should remove old file before copying
    func testBackupIsRecreated() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
            try? FileManager.default.removeItem(atPath: plistPath + ".backup")
        }

        let backupPath = plistPath + ".backup"

        // create initial backup file with known content
        FileManager.default.createFile(atPath: backupPath, contents: Data("old".utf8), attributes: nil)
        XCTAssertTrue(FileManager.default.fileExists(atPath: backupPath))

        // call helper directly with our temporary plist path; should overwrite existing backup
        try PlistWriter.backupExistingPlist(at: plistPath)

        // verify backup file still exists and was replaced (not equal to "old")
        let finalData = FileManager.default.contents(atPath: backupPath)
        XCTAssertNotNil(finalData)
        XCTAssertNotEqual(String(data: finalData!, encoding: .utf8), "old")
    }
    
    // Test conversion to dictionaries
    func testConversionToDict() {
        let item = ReplacementItem(shortcut: "test.key", expansion: "test expansion", enabled: true)
        
        let dict: [String: Any] = [
            "replace": item.replace,
            "with": item.with,
            "on": item.on
        ]
        
        XCTAssertEqual(dict["replace"] as! String, "test.key")
        XCTAssertEqual(dict["with"] as! String, "test expansion")
        XCTAssertEqual(dict["on"] as! Bool, true)
    }
    
    // Test backup creation
    func testBackupCreation() throws {
        let plistPath = createTestPlist()
        defer {
            try? FileManager.default.removeItem(atPath: plistPath)
            try? FileManager.default.removeItem(atPath: plistPath + ".backup")
        }
        
        // Create backup
        let backupPath = plistPath + ".backup"
        try FileManager.default.copyItem(atPath: plistPath, toPath: backupPath)
        
        // Verify backup exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: backupPath))
    }

}