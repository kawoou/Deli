//
//  RootStructure.swift
//  Deli
//

import SourceKittenFramework

final class RootStructure {
    
    // MARK: - Property
    
    let offset: Int64
    let length: Int64
    let substructures: [Structure]
    
    // MARK: - Lifecycle
    
    init?(source: KittenType) {
        guard let offset = source[SwiftDocKey.offset.rawValue] as? Int64 else { return nil }
        guard let length = source[SwiftDocKey.length.rawValue] as? Int64 else { return nil }
        
        self.offset = offset
        self.length = length
        
        if let substructuresRaw = source[SwiftDocKey.substructure.rawValue] as? [KittenType] {
            #if swift(>=4.1)
            self.substructures = substructuresRaw
                .compactMap { Structure(source: $0) }
            #else
            self.substructures = substructuresRaw
                .flatMap { Structure(source: $0) }
            #endif
        } else {
            self.substructures = []
        }
    }
}
