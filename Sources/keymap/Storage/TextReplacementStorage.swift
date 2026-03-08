// TextReplacementStorage.swift - Unified storage for macOS text replacements

import Foundation
import SQLite3

enum TextReplacementStorageError: Error, Equatable {
    case databaseNotFound
    case plistNotFound
    case invalidFormat
    case decodingError(String)
    case writeFailure(String)
    case unknown(String)
    
    var description: String {
        switch self {
        case .databaseNotFound:
            return "Error: Database file not found at ~/Library/KeyboardServices/TextReplacements.db"
        case .plistNotFound:
            return "Error: Plist file not found at ~/.GlobalPreferences.plist"
        case .invalidFormat:
            return "Error: Storage has invalid format"
        case .decodingError(let msg):
            return "Error: Failed to decode storage - \(msg)"
        case .writeFailure(let msg):
            return "Error: Failed to write storage - \(msg)"
        case .unknown(let msg):
            return "Error: \(msg)"
        }
    }
}

class TextReplacementStorage {
    static let databasePath: String = {
        let path = "~/Library/KeyboardServices/TextReplacements.db"
        return (path as NSString).expandingTildeInPath
    }()
    
    static let plistPath: String = {
        let path = "~/Library/Preferences/.GlobalPreferences.plist"
        return (path as NSString).expandingTildeInPath
    }()
    
    static let replacementKey = "NSUserDictionaryReplacementItems"
    
    /// Determine which storage method to use
    static func shouldUseDatabase() -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: databasePath) && fileManager.isWritableFile(atPath: databasePath)
    }
    
    /// Load all text replacements, trying database first, then plist
    static func loadReplacements() throws -> [ReplacementItem] {
        if shouldUseDatabase() {
            do {
                return try loadFromDatabase()
            } catch {
                // Fall back to plist
                return try loadFromPlist()
            }
        } else {
            return try loadFromPlist()
        }
    }
    
    /// Write replacements, preferring database, falling back to plist
    static func writeReplacements(_ replacements: [ReplacementItem]) throws {
        if shouldUseDatabase() {
            do {
                try writeToDatabase(replacements)
            } catch {
                // Fall back to plist
                try writeToPlist(replacements)
            }
        } else {
            try writeToPlist(replacements)
        }
    }
    
    // MARK: - Database Methods
    
    private static func loadFromDatabase() throws -> [ReplacementItem] {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: databasePath) else {
            throw TextReplacementStorageError.databaseNotFound
        }
        
        var db: OpaquePointer?
        guard sqlite3_open(databasePath, &db) == SQLITE_OK else {
            throw TextReplacementStorageError.decodingError("Failed to open database")
        }
        defer { sqlite3_close(db) }
        
        let query = "SELECT ZSHORTCUT, ZPHRASE FROM ZTEXTREPLACEMENTENTRY WHERE ZWASDELETED = 0"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            throw TextReplacementStorageError.decodingError("Failed to prepare statement")
        }
        defer { sqlite3_finalize(statement) }
        
        var replacements: [ReplacementItem] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let shortcut = String(cString: sqlite3_column_text(statement, 0))
            let phrase = String(cString: sqlite3_column_text(statement, 1))
            let item = ReplacementItem(shortcut: shortcut, expansion: phrase, enabled: true)
            replacements.append(item)
        }
        
        return replacements
    }
    
    private static func writeToDatabase(_ replacements: [ReplacementItem]) throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: databasePath) else {
            throw TextReplacementStorageError.databaseNotFound
        }
        
        // Create backup
        let backupPath = databasePath + ".backup"
        if fileManager.fileExists(atPath: backupPath) {
            try fileManager.removeItem(atPath: backupPath)
        }
        try fileManager.copyItem(atPath: databasePath, toPath: backupPath)
        
        var db: OpaquePointer?
        guard sqlite3_open(databasePath, &db) == SQLITE_OK else {
            throw TextReplacementStorageError.writeFailure("Failed to open database")
        }
        defer { sqlite3_close(db) }
        
        // Begin transaction
        guard sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK else {
            throw TextReplacementStorageError.writeFailure("Failed to begin transaction")
        }
        
        // Mark all existing as deleted
        let markDeletedQuery = "UPDATE ZTEXTREPLACEMENTENTRY SET ZWASDELETED = 1 WHERE ZWASDELETED = 0"
        guard sqlite3_exec(db, markDeletedQuery, nil, nil, nil) == SQLITE_OK else {
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            throw TextReplacementStorageError.writeFailure("Failed to mark existing entries as deleted")
        }
        
        // Insert new replacements
        let insertQuery = "INSERT INTO ZTEXTREPLACEMENTENTRY (ZSHORTCUT, ZPHRASE, ZWASDELETED, ZTIMESTAMP, ZUNIQUENAME) VALUES (?, ?, 0, ?, ?)"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
            throw TextReplacementStorageError.writeFailure("Failed to prepare insert statement")
        }
        defer { sqlite3_finalize(statement) }
        
        let timestamp = Date().timeIntervalSince1970
        for item in replacements {
            sqlite3_bind_text(statement, 1, (item.shortcut as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (item.expansion as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 3, timestamp)
            let uniqueName = UUID().uuidString
            sqlite3_bind_text(statement, 4, (uniqueName as NSString).utf8String, -1, nil)
            
            guard sqlite3_step(statement) == SQLITE_DONE else {
                sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
                throw TextReplacementStorageError.writeFailure("Failed to insert replacement")
            }
            
            sqlite3_reset(statement)
        }
        
        // Commit transaction
        guard sqlite3_exec(db, "COMMIT", nil, nil, nil) == SQLITE_OK else {
            throw TextReplacementStorageError.writeFailure("Failed to commit transaction")
        }
    }
    
    // MARK: - Plist Methods
    
    private static func loadFromPlist() throws -> [ReplacementItem] {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: plistPath) else {
            // Create empty plist if it doesn't exist
            let emptyPlist: [String: Any] = [replacementKey: []]
            let data = try PropertyListSerialization.data(fromPropertyList: emptyPlist, format: .xml, options: 0)
            fileManager.createFile(atPath: plistPath, contents: data, attributes: nil)
            return []
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: &format) as? [String: Any] else {
            throw TextReplacementStorageError.invalidFormat
        }
        
        guard let itemsArray = plist[replacementKey] as? [[String: Any]] else {
            return []
        }
        
        var replacements: [ReplacementItem] = []
        for item in itemsArray {
            let jsonData = try JSONSerialization.data(withJSONObject: item)
            let decoder = JSONDecoder()
            let replacement = try decoder.decode(ReplacementItem.self, from: jsonData)
            replacements.append(replacement)
        }
        
        return replacements
    }
    
    private static func writeToPlist(_ replacements: [ReplacementItem]) throws {
        let fileManager = FileManager.default
        
        // Create backup
        let backupPath = plistPath + ".backup"
        if fileManager.fileExists(atPath: backupPath) {
            try fileManager.removeItem(atPath: backupPath)
        }
        if fileManager.fileExists(atPath: plistPath) {
            try fileManager.copyItem(atPath: plistPath, toPath: backupPath)
        }
        
        // Read existing plist or create new
        var plist: [String: Any] = [:]
        if fileManager.fileExists(atPath: plistPath) {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))
            var format = PropertyListSerialization.PropertyListFormat.xml
            plist = try PropertyListSerialization.propertyList(from: data, options: [], format: &format) as? [String: Any] ?? [:]
        }
        
        let replacementDicts: [[String: Any]] = replacements.map { item in
            return [
                "replace": item.replace,
                "with": item.with,
                "on": item.on
            ]
        }
        plist[replacementKey] = replacementDicts
        
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let success = fileManager.createFile(atPath: plistPath, contents: data, attributes: nil)
        guard success else {
            throw TextReplacementStorageError.writeFailure("Could not create file at \(plistPath)")
        }
    }
}