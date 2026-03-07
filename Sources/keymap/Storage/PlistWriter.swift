// PlistWriter.swift - Writes macOS text replacement plist

import Foundation

enum PlistWriterError: Error, Equatable {
    case fileNotFound
    case cannotCreateBackup
    case serializationFailed
    case writeFailure(String)
    case unknown(String)
    
    var description: String {
        switch self {
        case .fileNotFound:
            return "Error: Plist file not found at ~/.GlobalPreferences.plist"
        case .cannotCreateBackup:
            return "Error: Could not create backup of plist file"
        case .serializationFailed:
            return "Error: Failed to serialize replacements"
        case .writeFailure(let msg):
            return "Error: Failed to write plist - \(msg)"
        case .unknown(let msg):
            return "Error: \(msg)"
        }
    }
}

class PlistWriter {
    static let plistPath: String = {
        let path = "~/Library/Preferences/.GlobalPreferences.plist"
        return (path as NSString).expandingTildeInPath
    }()
    static let replacementKey = "NSUserDictionaryReplacementItems"
    
    /// Write replacements back to the macOS plist
    /// - Parameters:
    ///   - replacements: Array of ReplacementItem objects to write
    /// - Throws: PlistWriterError if write fails
    static func writeReplacements(_ replacements: [ReplacementItem]) throws {
        let fileManager = FileManager.default
        
        // Check if file exists
        guard fileManager.fileExists(atPath: plistPath) else {
            throw PlistWriterError.fileNotFound
        }
        
        // Read existing plist
        guard let data = fileManager.contents(atPath: plistPath) else {
            throw PlistWriterError.fileNotFound
        }
        
        // Deserialize existing plist
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard var plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        ) as? [String: Any] else {
            throw PlistWriterError.serializationFailed
        }
        
        // Convert ReplacementItems to dictionaries
        let replacementDicts: [[String: Any]] = replacements.map { item in
            return [
                "replace": item.replace,
                "with": item.with,
                "on": item.on
            ]
        }
        
        // Update the replacement key
        plist[replacementKey] = replacementDicts
        
        // Serialize back to plist
        let serializedData = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        
        // Create backup before writing
        let backupPath = plistPath + ".backup"
        if fileManager.fileExists(atPath: plistPath) {
            do {
                try fileManager.copyItem(atPath: plistPath, toPath: backupPath)
            } catch {
                throw PlistWriterError.cannotCreateBackup
            }
        }
        
        // Write to file
        let success = fileManager.createFile(
            atPath: plistPath,
            contents: serializedData,
            attributes: nil
        )
        
        guard success else {
            throw PlistWriterError.writeFailure("Could not create file at \(plistPath)")
        }
    }
}