//
//  ConfigDependencyInfo.swift
//  Deli
//

import Foundation

struct ConfigDependencyInfo: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case path
        case `import`
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
        if let importFramework = try container.decodeIfPresent(String.self, forKey: .import) {
            imports = [importFramework]
        } else {
            imports = try container.decodeIfPresent([String].self, forKey: .import) ?? []
        }
    }

}
