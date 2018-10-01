//
//  Structure.swift
//  Deli
//

import SourceKittenFramework

final class Structure {
    
    // MARK: - Enumerable
    
    enum AccessLevel: String {
        case open = "source.lang.swift.accessibility.open"
        case `public` = "source.lang.swift.accessibility.public"
        case `internal` = "source.lang.swift.accessibility.internal"
        case `fileprivate` = "source.lang.swift.accessibility.fileprivate"
        case `private` = "source.lang.swift.accessibility.private"
    }
    
    // MARK: - Property
    
    weak var parent: Structure?
    
    let name: String?
    let kind: String
    let accessLevel: AccessLevel
    let setterAccessLevel: AccessLevel?
    let runtimeName: String?
    let typeName: String?
    let inheritedTypes: [String]
    let attributes: [String]
    let substructures: [Structure]
    let offset: Int64
    let length: Int64
    let filePath: String

    // MARK: - Public

    func getSourceLine(with content: String? = nil) -> String {
        guard let content = content else { return "\(filePath):1:0" }
        let beforeIndex = content.utf8.index(content.utf8.startIndex, offsetBy: Int(offset))

        let lineList: [String] = (String(content.utf8[..<beforeIndex]) ?? "")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }

        guard let currentLine = lineList.last else { return "\(filePath):1:0" }
        return "\(filePath):\(lineList.count):\(currentLine.count)"
    }
    
    // MARK: - Lifecycle
    
    init?(source: KittenType, filePath: String) {
        guard let kind = source[SwiftDocKey.kind.rawValue] as? String else { return nil }
        guard let offset = source[SwiftDocKey.offset.rawValue] as? Int64 else { return nil }
        guard let length = source[SwiftDocKey.length.rawValue] as? Int64 else { return nil }
        
        /// Inheritances
        if let inheritedTypesRaw = source[SwiftDocKey.inheritedtypes.rawValue] as? [KittenType] {
            #if swift(>=4.1)
            self.inheritedTypes = inheritedTypesRaw
                .compactMap { $0[SwiftDocKey.name.rawValue] as? String }
            #else
            self.inheritedTypes = inheritedTypesRaw
                .flatMap { $0[SwiftDocKey.name.rawValue] as? String }
            #endif
        } else {
            self.inheritedTypes = []
        }
        
        /// Attributes
        if let attributesRaw = source["key.attributes"] as? [KittenType] {
            #if swift(>=4.1)
            self.attributes = attributesRaw
                .compactMap { $0["key.attribute"] as? String }
            #else
            self.attributes = attributesRaw
                .flatMap { $0["key.attribute"] as? String }
            #endif
        } else {
            self.attributes = []
        }
        
        /// Sub-structures
        if let substructuresRaw = source[SwiftDocKey.substructure.rawValue] as? [KittenType] {
            #if swift(>=4.1)
            self.substructures = substructuresRaw
                .compactMap { Structure(source: $0, filePath: filePath) }
            #else
            self.substructures = substructuresRaw
                .flatMap { Structure(source: $0, filePath: filePath) }
            #endif
        } else {
            self.substructures = []
        }
        
        self.name = source[SwiftDocKey.name.rawValue] as? String
        self.kind = kind
        if let accessibility = source["key.accessibility"] as? String {
            self.accessLevel = AccessLevel(rawValue: accessibility) ?? .internal
        } else {
            self.accessLevel = .internal
        }
        if let accessibility = source["key.setter_accessibility"] as? String {
            self.setterAccessLevel = AccessLevel(rawValue: accessibility) ?? .internal
        } else {
            self.setterAccessLevel = .internal
        }
        self.runtimeName = source["key.runtime_name"] as? String
        self.typeName = source[SwiftDocKey.typeName.rawValue] as? String
        self.offset = offset
        self.length = length
        self.filePath = filePath
        
        /// Bind Parent
        self.substructures.forEach { [weak self] info in
            info.parent = self
        }
    }
}
