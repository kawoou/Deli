//
//  ConfigResolveInfo.swift
//  deli
//
//  Created by Kawoou on 11/02/2019.
//

import Foundation

struct ConfigResolveInfo: Decodable {

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case output
        case isGenerate = "generate"
    }

    // MARK: - Property

    let output: String?
    let isGenerate: Bool

    // MARK: - Lifecycle

    init(output: String? = nil, isGenerate: Bool = true) {
        self.output = output
        self.isGenerate = isGenerate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        output = try container.decodeIfPresent(String.self, forKey: .output)
        isGenerate = try container.decodeIfPresent(Bool.self, forKey: .isGenerate) ?? true
    }
}
