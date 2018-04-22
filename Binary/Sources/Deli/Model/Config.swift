//
//  Config.swift
//  Deli
//

import Foundation
import Yams

struct Config: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case project
        case scheme
        case output
    }

    // MARK: - Property

    let project: String
    let scheme: String?
    let output: String?

    // MARK: - Lifecycle

    init(project: String, scheme: String? = nil, output: String? = nil) {
        self.project = project
        self.scheme = scheme
        self.output = output
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.project = try container.decode(String.self, forKey: .project)
        self.scheme = try? container.decode(String.self, forKey: .scheme)
        self.output = try? container.decode(String.self, forKey: .output)
    }
}
