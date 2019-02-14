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
}
