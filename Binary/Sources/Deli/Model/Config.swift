//
//  Config.swift
//  Deli
//

import Yams

struct Config: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case target
        case config
    }

    // MARK: - Property

    let target: Set<String>
    let config: [String: ConfigInfo]

    // MARK: - Lifecycle

    init(target: Set<String>, config: [String: ConfigInfo]) {
        self.target = target
        self.config = config
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        target = try container.decode(Set<String>.self, forKey: .target)
        config = (try? container.decode([String: ConfigInfo].self, forKey: .config)) ?? [:]
    }
}
