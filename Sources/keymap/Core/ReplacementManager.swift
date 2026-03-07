// ReplacementManager.swift - Core business logic for managing text replacements

import Foundation

enum ReplacementManagerError: Error, Equatable {
    case shortcutNotFound(String)
    case shortcutAlreadyExists(String)
    case emptyShortcut
    case emptyExpansion
    case unknown(String)
    
    var description: String {
        switch self {
        case .shortcutNotFound(let shortcut):
            return "Error: Shortcut '\(shortcut)' not found."
        case .shortcutAlreadyExists(let shortcut):
            return "Error: Shortcut '\(shortcut)' already exists. Use update to modify."
        case .emptyShortcut:
            return "Error: Shortcut cannot be empty."
        case .emptyExpansion:
            return "Error: Expansion cannot be empty."
        case .unknown(let msg):
            return "Error: \(msg)"
        }
    }
}

class ReplacementManager {
    private var replacements: [ReplacementItem]
    
    /// Initialize with existing replacements or empty array
    init(replacements: [ReplacementItem] = []) {
        self.replacements = replacements
    }
    
    // MARK: - Core Operations
    
    /// Add a new text replacement shortcut
    /// - Parameters:
    ///   - shortcut: The text to be replaced
    ///   - expansion: The replacement text
    /// - Throws: ReplacementManagerError if shortcut already exists
    func addShortcut(_ shortcut: String, expansion: String) throws {
        // Validate input
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        
        guard !expansion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyExpansion
        }
        
        // Check for duplicates
        if replacements.contains(where: { $0.shortcut == shortcut }) {
            throw ReplacementManagerError.shortcutAlreadyExists(shortcut)
        }
        
        // Add the new item
        let item = ReplacementItem(shortcut: shortcut, expansion: expansion, enabled: true)
        replacements.append(item)
    }
    
    /// Remove a text replacement by shortcut
    /// - Parameters:
    ///   - shortcut: The shortcut to remove
    /// - Throws: ReplacementManagerError if shortcut not found
    func removeShortcut(_ shortcut: String) throws {
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        
        guard let index = replacements.firstIndex(where: { $0.shortcut == shortcut }) else {
            throw ReplacementManagerError.shortcutNotFound(shortcut)
        }
        
        replacements.remove(at: index)
    }
    
    /// Update an existing text replacement
    /// - Parameters:
    ///   - shortcut: The shortcut to update
    ///   - expansion: The new expansion text
    /// - Throws: ReplacementManagerError if shortcut not found
    func updateShortcut(_ shortcut: String, expansion: String) throws {
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        
        guard !expansion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyExpansion
        }
        
        guard let index = replacements.firstIndex(where: { $0.shortcut == shortcut }) else {
            throw ReplacementManagerError.shortcutNotFound(shortcut)
        }
        
        let updatedItem = ReplacementItem(shortcut: shortcut, expansion: expansion, enabled: replacements[index].enabled)
        replacements[index] = updatedItem
    }
    
    /// List all text replacements
    /// - Returns: Array of all ReplacementItem objects
    func listShortcuts() -> [ReplacementItem] {
        return replacements.sorted { $0.shortcut < $1.shortcut }
    }
    
    /// Get the count of replacements
    func count() -> Int {
        return replacements.count
    }
    
    /// Get a specific replacement by shortcut
    func getReplacement(_ shortcut: String) -> ReplacementItem? {
        return replacements.first { $0.shortcut == shortcut }
    }
    
    /// Get all replacements as array
    func getAll() -> [ReplacementItem] {
        return replacements
    }
}