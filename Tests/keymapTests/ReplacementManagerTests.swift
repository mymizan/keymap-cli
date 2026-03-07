import XCTest
@testable import keymap

final class ReplacementManagerTests: XCTestCase {

    var manager: ReplacementManager!
    
    override func setUp() {
        super.setUp()
        manager = ReplacementManager()
    }
    
    // MARK: - Add Tests
    
    func testAddSingleShortcut() throws {
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        
        XCTAssertEqual(manager.count(), 1)
        XCTAssertEqual(manager.getReplacement("x.oc")?.expansion, "npm install v24.14.0")
    }
    
    func testAddMultipleShortcuts() throws {
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        try manager.addShortcut("gh.c", expansion: "git checkout")
        try manager.addShortcut("gs.s", expansion: "git status")
        
        XCTAssertEqual(manager.count(), 3)
    }
    
    func testAddShortcutDuplicate() throws {
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        
        XCTAssertThrowsError(try manager.addShortcut("x.oc", expansion: "npm install v24.15.0")) { error in
            if case .shortcutAlreadyExists(let shortcut) = error as? ReplacementManagerError {
                XCTAssertEqual(shortcut, "x.oc")
            } else {
                XCTFail("Expected shortcutAlreadyExists error")
            }
        }
    }
    
    func testAddEmptyShortcut() throws {
        XCTAssertThrowsError(try manager.addShortcut("", expansion: "expansion")) { error in
            if case .emptyShortcut = error as? ReplacementManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyShortcut error")
            }
        }
    }
    
    func testAddEmptyExpansion() throws {
        XCTAssertThrowsError(try manager.addShortcut("shortcut", expansion: "")) { error in
            if case .emptyExpansion = error as? ReplacementManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyExpansion error")
            }
        }
    }
    
    func testAddWhitespaceShortcut() throws {
        XCTAssertThrowsError(try manager.addShortcut("   ", expansion: "expansion")) { error in
            if case .emptyShortcut = error as? ReplacementManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyShortcut error for whitespace")
            }
        }
    }
    
    func testAddPreservesEnabledState() throws {
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        let item = manager.getReplacement("x.oc")!
        
        XCTAssertEqual(item.enabled, true)
    }
    
    // MARK: - Remove Tests
    
    func testRemoveSingleShortcut() throws {
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        try manager.removeShortcut("x.oc")
        
        XCTAssertEqual(manager.count(), 0)
        XCTAssertNil(manager.getReplacement("x.oc"))
    }
    
    func testRemoveNonExistentShortcut() throws {
        XCTAssertThrowsError(try manager.removeShortcut("nonexistent")) { error in
            if case .shortcutNotFound(let shortcut) = error as? ReplacementManagerError {
                XCTAssertEqual(shortcut, "nonexistent")
            } else {
                XCTFail("Expected shortcutNotFound error")
            }
        }
    }
    
    func testRemoveMultipleShortcuts() throws {
        try manager.addShortcut("x.oc", expansion: "npm install")
        try manager.addShortcut("gh.c", expansion: "git checkout")
        try manager.addShortcut("gs.s", expansion: "git status")
        
        try manager.removeShortcut("gh.c")
        
        XCTAssertEqual(manager.count(), 2)
        XCTAssertNil(manager.getReplacement("gh.c"))
        XCTAssertNotNil(manager.getReplacement("x.oc"))
    }
    
    func testRemoveEmptyShortcut() throws {
        XCTAssertThrowsError(try manager.removeShortcut("")) { error in
            if case .emptyShortcut = error as? ReplacementManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyShortcut error")
            }
        }
    }
    
    // MARK: - Update Tests
    
    func testUpdateSingleShortcut() throws {
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        try manager.updateShortcut("x.oc", expansion: "npm install v24.15.0")
        
        XCTAssertEqual(manager.getReplacement("x.oc")?.expansion, "npm install v24.15.0")
        XCTAssertEqual(manager.count(), 1)
    }
    
    func testUpdateNonExistentShortcut() throws {
        XCTAssertThrowsError(try manager.updateShortcut("nonexistent", expansion: "expansion")) { error in
            if case .shortcutNotFound(let shortcut) = error as? ReplacementManagerError {
                XCTAssertEqual(shortcut, "nonexistent")
            } else {
                XCTFail("Expected shortcutNotFound error")
            }
        }
    }
    
    func testUpdatePreservesEnabledState() throws {
        try manager.addShortcut("x.oc", expansion: "npm install")
        try manager.updateShortcut("x.oc", expansion: "new expansion")
        
        let item = manager.getReplacement("x.oc")!
        XCTAssertEqual(item.enabled, true)
    }
    
    func testUpdateWithInitializedManager() throws {
        let item = ReplacementItem(shortcut: "x.oc", expansion: "npm install", enabled: false)
        let manager = ReplacementManager(replacements: [item])
        
        try manager.updateShortcut("x.oc", expansion: "new expansion")
        
        XCTAssertEqual(manager.getReplacement("x.oc")?.enabled, false)
    }
    
    func testUpdateEmptyShortcut() throws {
        try manager.addShortcut("x.oc", expansion: "npm install")
        
        XCTAssertThrowsError(try manager.updateShortcut("", expansion: "expansion")) { error in
            if case .emptyShortcut = error as? ReplacementManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyShortcut error")
            }
        }
    }
    
    func testUpdateEmptyExpansion() throws {
        try manager.addShortcut("x.oc", expansion: "npm install")
        
        XCTAssertThrowsError(try manager.updateShortcut("x.oc", expansion: "")) { error in
            if case .emptyExpansion = error as? ReplacementManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected emptyExpansion error")
            }
        }
    }
    
    // MARK: - List Tests
    
    func testListEmptyManager() {
        let list = manager.listShortcuts()
        XCTAssertEqual(list.count, 0)
    }
    
    func testListSingleShortcut() throws {
        try manager.addShortcut("x.oc", expansion: "npm install")
        let list = manager.listShortcuts()
        
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list[0].shortcut, "x.oc")
    }
    
    func testListSortedAlphabetically() throws {
        try manager.addShortcut("z.test", expansion: "z expansion")
        try manager.addShortcut("a.test", expansion: "a expansion")
        try manager.addShortcut("m.test", expansion: "m expansion")
        
        let list = manager.listShortcuts()
        
        XCTAssertEqual(list[0].shortcut, "a.test")
        XCTAssertEqual(list[1].shortcut, "m.test")
        XCTAssertEqual(list[2].shortcut, "z.test")
    }
    
    func testListStaysConsistent() throws {
        try manager.addShortcut("x.oc", expansion: "npm install")
        try manager.addShortcut("gh.c", expansion: "git checkout")
        
        let list1 = manager.listShortcuts()
        let list2 = manager.listShortcuts()
        
        XCTAssertEqual(list1, list2)
    }
    
    // MARK: - Integration Tests
    
    func testAddUpdateRemoveFlow() throws {
        // Add
        try manager.addShortcut("x.oc", expansion: "npm install v24.14.0")
        XCTAssertEqual(manager.count(), 1)
        
        // Update
        try manager.updateShortcut("x.oc", expansion: "npm install v24.15.0")
        XCTAssertEqual(manager.getReplacement("x.oc")?.expansion, "npm install v24.15.0")
        XCTAssertEqual(manager.count(), 1)
        
        // Remove
        try manager.removeShortcut("x.oc")
        XCTAssertEqual(manager.count(), 0)
    }
    
    func testComplexWorkflow() throws {
        // Add multiple
        try manager.addShortcut("x.oc", expansion: "npm install")
        try manager.addShortcut("gh.c", expansion: "git checkout")
        try manager.addShortcut("gs.s", expansion: "git status")
        
        XCTAssertEqual(manager.count(), 3)
        
        // Update one
        try manager.updateShortcut("x.oc", expansion: "npm install && npm test")
        
        // Remove one
        try manager.removeShortcut("gs.s")
        
        // List
        let list = manager.listShortcuts()
        XCTAssertEqual(list.count, 2)
        
        // Verify state
        XCTAssertNotNil(manager.getReplacement("x.oc"))
        XCTAssertNotNil(manager.getReplacement("gh.c"))
        XCTAssertNil(manager.getReplacement("gs.s"))
    }
    
    func testInitializeWithExistingReplacements() {
        let items = [
            ReplacementItem(shortcut: "x.oc", expansion: "npm install", enabled: true),
            ReplacementItem(shortcut: "gh.c", expansion: "git checkout", enabled: true)
        ]
        
        let manager = ReplacementManager(replacements: items)
        XCTAssertEqual(manager.count(), 2)
        XCTAssertNotNil(manager.getReplacement("x.oc"))
    }
    
    // MARK: - Error Description Tests
    
    func testErrorDescriptions() {
        XCTAssertTrue(ReplacementManagerError.emptyShortcut.description.contains("empty"))
        XCTAssertTrue(ReplacementManagerError.emptyExpansion.description.contains("empty"))
        XCTAssertTrue(ReplacementManagerError.shortcutNotFound("test").description.contains("not found"))
        XCTAssertTrue(ReplacementManagerError.shortcutAlreadyExists("test").description.contains("already exists"))
    }

}