//
//  ConfigInfo.swift
//  Deli
//

import Foundation
import Yams

struct ConfigInfo: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case project
        case scheme
        case target
        case include
        case exclude
        case output
        case className
    }

    // MARK: - Property

    let project: String
    let scheme: String?
    let target: String?
    let include: [String]
    let exclude: [String]
    let output: String?
    let className: String?

    // MARK: - Lifecycle

    init(project: String, scheme: String? = nil, target: String? = nil, output: String? = nil, className: String? = nil) {
        self.project = project
        self.scheme = scheme
        self.target = target
        self.include = []
        self.exclude = []
        self.output = output
        self.className = className
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        project = try container.decode(String.self, forKey: .project)
        scheme = try? container.decode(String.self, forKey: .scheme)
        target = try? container.decode(String.self, forKey: .target)
        include = (try? container.decode([String].self, forKey: .include)) ?? []
        exclude = (try? container.decode([String].self, forKey: .exclude)) ?? []
        output = try? container.decode(String.self, forKey: .output)
        className = try? container.decode(String.self, forKey: .className)
    }
}
