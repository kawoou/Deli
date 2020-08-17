//
//  RootStructure.swift
//  Deli
//

import SourceKittenFramework

final class RootStructure {
    
    // MARK: - Property
    
    let offset: Int64
    let length: Int64
    let filePath: String
    let substructures: [Structure]
    let content: String
    
    // MARK: - Lifecycle
    
    init?(source: KittenType, filePath: String, content: String) {
        guard let offset = source[SwiftDocKey.offset.rawValue] as? Int64 else { return nil }
        guard let length = source[SwiftDocKey.length.rawValue] as? Int64 else { return nil }
        
        self.offset = offset
        self.length = length
        self.filePath = filePath
        self.content = content
        
        if let substructuresRaw = source[SwiftDocKey.substructure.rawValue] as? [KittenType] {
            self.substructures = substructuresRaw
                .compactMap { Structure(source: $0, filePath: filePath) }
        } else {
            self.substructures = []
        }
    }
}
