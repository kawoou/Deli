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
        case include
        case exclude
        case output
    }

    // MARK: - Property

    let project: String
    let scheme: String?
    let include: [String]
    let exclude: [String]
    let output: String?

    // MARK: - Lifecycle

    init(project: String, scheme: String? = nil, output: String? = nil) {
        self.project = project
        self.scheme = scheme
        self.include = []
        self.exclude = []
        self.output = output
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        project = try container.decode(String.self, forKey: .project)
        scheme = try? container.decode(String.self, forKey: .scheme)
        include = (try? container.decode([String].self, forKey: .include)) ?? []
        exclude = (try? container.decode([String].self, forKey: .exclude)) ?? []
        output = try? container.decode(String.self, forKey: .output)
    }
}
