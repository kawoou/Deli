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
    }

    // MARK: - Property

    let output: String?

    // MARK: - Lifecycle

    init(output: String? = nil) {
        self.output = output
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        output = try? container.decode(String.self, forKey: .output)
    }
}
