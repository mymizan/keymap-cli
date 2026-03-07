// PlistReader.swift - Reads macOS text replacement plist

import Foundation

enum PlistReaderError: Error, Equatable {
    case fileNotFound
    case invalidFormat
    case decodingError(String)
    case unknown(String)
    
    var description: String {
        switch self {
        case .fileNotFound:
            return "Error: Plist file not found at ~/.GlobalPreferences.plist"
        case .invalidFormat:
            return "Error: Plist has invalid format"
        case .decodingError(let msg):
            return "Error: Failed to decode plist - \(msg)"
        case .unknown(let msg):
            return "Error: \(msg)"
        }
    }
}

class PlistReader {
    static let plistPath: String = {
        let path = "~/Library/Preferences/.GlobalPreferences.plist"
        return (path as NSString).expandingTildeInPath
    }()
    static let replacementKey = "NSUserDictionaryReplacementItems"
    
    /// Load all text replacements from the macOS plist
    static func loadReplacements() throws -> [ReplacementItem] {
        let fileManager = FileManager.default
        
        // Check if file exists
        guard fileManager.fileExists(atPath: plistPath) else {
            throw PlistReaderError.fileNotFound
        }
        
        // Read the plist file
        guard let data = fileManager.contents(atPath: plistPath) else {
            throw PlistReaderError.fileNotFound
        }
        
        // Deserialize the plist
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        ) as? [String: Any] else {
            throw PlistReaderError.invalidFormat
        }
        
        // Extract the replacement items array
        guard let itemsArray = plist[replacementKey] as? [[String: Any]] else {
            // If key doesn't exist or is not an array, return empty array
            return []
        }
        
        // Convert dictionary array to ReplacementItem array
        var replacements: [ReplacementItem] = []
        for item in itemsArray {
            do {
                // Convert dictionary to JSON data for decoding
                let jsonData = try JSONSerialization.data(withJSONObject: item)
                let decoder = JSONDecoder()
                let replacement = try decoder.decode(ReplacementItem.self, from: jsonData)
                replacements.append(replacement)
            } catch {
                // Log and skip invalid items
                continue
            }
        }
        
        return replacements
    }
    
    /// Load a specific replacement by shortcut
    static func loadReplacement(shortcut: String) throws -> ReplacementItem? {
        let replacements = try loadReplacements()
        return replacements.first { $0.shortcut == shortcut }
    }
}