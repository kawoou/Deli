//
//  ConfigDependency.swift
//  Deli
//

import Foundation

enum ConfigDependency: Decodable {
    enum CodingKeys: String, CodingKey {
        case target
    }

    case target(ConfigDependencyTarget)
    case resolveFile(ConfigDependencyResolveFile)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.target) {
            self = .target(try ConfigDependencyTarget(from: decoder))
        } else {
            self = .resolveFile(try ConfigDependencyResolveFile(from: decoder))
        }
    }
}

struct ConfigDependencyTarget: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case target
        case `imports` = "import"
    }

    // MARK: - Property

    let target: String
    let imports: [String]

    // MARK: - Lifecycle

    init(target: String, imports: [String]) {
        self.target = target
        self.imports = imports
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        target = try container.decode(String.self, forKey: .target)
        if let importFramework = try container.decodeIfPresent(String.self, forKey: .imports) {
            imports = [importFramework]
        } else {
            imports = try container.decodeIfPresent([String].self, forKey: .imports) ?? []
        }
    }
}

struct ConfigDependencyResolveFile: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case path
        case `imports` = "import"
    }

    // MARK: - Property

    let path: String
    let imports: [String]

    // MARK: - Lifecycle

    init(path: String, imports: [String]) {
        self.path = path
        self.imports = imports
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        path = try container.decode(String.self, forKey: .path)
        if let importFramework = try container.decodeIfPresent(String.self, forKey: .imports) {
            imports = [importFramework]
        } else {
            imports = try container.decodeIfPresent([String].self, forKey: .imports) ?? []
        }
    }
}
