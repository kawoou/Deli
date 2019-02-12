//
//  ConfigInfo.swift
//  Deli
//

import Foundation

struct ConfigInfo: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case project
        case scheme
        case target
        case include
        case exclude
        case output
        case resolve
        case properties
        case dependencies
        case className
        case accessControl
    }

    // MARK: - Property

    let project: String
    let scheme: String?
    let target: String?
    let include: [String]
    let exclude: [String]
    let output: String?
    let resolve: ConfigResolveInfo?
    let properties: [String]
    let dependencies: [ConfigDependencyInfo]
    let className: String?
    let accessControl: String?

    // MARK: - Lifecycle

    init(project: String, scheme: String? = nil, target: String? = nil, output: String? = nil, resolve: ConfigResolveInfo? = nil, properties: [String] = [], dependencies: [ConfigDependencyInfo] = [], className: String? = nil, accessControl: String? = nil) {
        self.project = project
        self.scheme = scheme
        self.target = target
        self.include = []
        self.exclude = []
        self.output = output
        self.resolve = resolve
        self.properties = properties
        self.dependencies = dependencies
        self.className = className
        self.accessControl = accessControl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        project = try container.decode(String.self, forKey: .project)
        scheme = try? container.decode(String.self, forKey: .scheme)
        target = try? container.decode(String.self, forKey: .target)
        include = (try? container.decode([String].self, forKey: .include)) ?? []
        exclude = (try? container.decode([String].self, forKey: .exclude)) ?? []
        output = try? container.decode(String.self, forKey: .output)
        resolve = try? container.decode(ConfigResolveInfo.self, forKey: .resolve)
        properties = (try? container.decode([String].self, forKey: .properties)) ?? []
        dependencies = (try? container.decode([ConfigDependencyInfo].self, forKey: .dependencies)) ?? []
        className = try? container.decode(String.self, forKey: .className)
        accessControl = try? container.decode(String.self, forKey: .accessControl)
    }
}
