//
//  ResolveData.swift
//  Deli
//

import Foundation

struct ResolveData: Codable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case version = "VERSION"
        case dependency = "DEPENDENCY"
        case properties = "PROPERTY"
        case projectName = "PROJECT"
        case referenceName = "REFERENCE"
    }

    // MARK: - Structure

    struct DependencyTarget: Codable {
        enum CodingKeys: String, CodingKey {
            case type = "TYPE"
            case qualifier = "QUALIFIER"
            case qualifierBy = "QUALIFIER_BY"
        }

        let type: String
        let qualifier: String
        let qualifierBy: String?
    }

    struct Dependency: Codable {
        enum CodingKeys: String, CodingKey {
            case type = "TYPE"
            case qualifier = "QUALIFIER"
            case isLazy = "LAZILY"
            case isFactory = "FACTORY"
            case isValueType = "VALUE_TYPE"
            case dependencies = "DEPENDENCY"
            case linkType = "LINK"
        }

        let type: String
        let qualifier: String?
        let isLazy: Bool
        let isFactory: Bool
        let isValueType: Bool
        var dependencies: [DependencyTarget]
        var linkType: [String]
    }

    // MARK: - Property

    let dependency: [Dependency]
    let property: [String: Any]
    let projectName: String
    let referenceName: String

    // MARK: - Lifecycle

    init(dependency: [Dependency], property: [String: Any], projectName: String, referenceName: String) {
        self.dependency = dependency
        self.property = property
        self.projectName = projectName
        self.referenceName = referenceName
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //let version = try container.decode(String.self, forKey: .version)
        dependency = try container.decode([Dependency].self, forKey: .dependency)
        property = try container.decode([String: Any].self, forKey: .properties)
        projectName = try container.decode(String.self, forKey: .projectName)
        referenceName = try container.decode(String.self, forKey: .referenceName)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Version.current.value, forKey: .version)
        try container.encode(dependency, forKey: .dependency)
        try container.encode(property, forKey: .properties)
        try container.encode(projectName, forKey: .projectName)
        try container.encode(referenceName, forKey: .referenceName)
    }
}
