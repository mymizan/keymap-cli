// ReplacementItem.swift - Data model for text replacement items

import Foundation

struct ReplacementItem: Codable, Equatable {
    let replace: String      // The shortcut to be replaced
    let with: String         // The expansion text
    let on: Bool             // Whether the replacement is enabled
    
    enum CodingKeys: String, CodingKey {
        case replace
        case with
        case on
    }
    
    // Convenience properties for clarity
    var shortcut: String {
        return replace
    }
    
    var expansion: String {
        return with
    }
    
    var enabled: Bool {
        return on
    }
    
    // Initialize with convenience parameters
    init(shortcut: String, expansion: String, enabled: Bool = true) {
        self.replace = shortcut
        self.with = expansion
        self.on = enabled
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        replace = try container.decode(String.self, forKey: .replace)
        with = try container.decode(String.self, forKey: .with)
        on = try container.decode(Bool.self, forKey: .on)
    }
    
    // Custom encoding for consistency
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(replace, forKey: .replace)
        try container.encode(with, forKey: .with)
        try container.encode(on, forKey: .on)
    }
}