//
//  GithubRelease.swift
//  Deli
//

import Foundation

struct GithubRelease: Codable {

    // MARK: - Struct

    struct Asset: Codable {

        // MARK: - Property

        let id: Int
        let name: String
        let downloadURL: String
        let contentType: String
        let size: Int
        let createdAt: Date
        let updatedAt: Date

        // MARK: - Private

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case downloadURL = "browser_download_url"
            case contentType = "content_type"
            case size
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }

        // MARK: - Lifecycle

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(downloadURL, forKey: .downloadURL)
            try container.encode(contentType, forKey: .contentType)
            try container.encode(size, forKey: .size)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(updatedAt, forKey: .updatedAt)
        }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            downloadURL = try container.decode(String.self, forKey: .downloadURL)
            contentType = try container.decode(String.self, forKey: .contentType)
            size = try container.decode(Int.self, forKey: .size)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }

    // MARK: - Property

    let id: Int
    let name: String?
    let tagName: String

    let assets: [Asset]
    let createdAt: Date
    let publishedAt: Date

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case tagName = "tag_name"
        case assets
        case createdAt = "created_at"
        case publishedAt = "published_at"
    }

    // MARK: - Lifecycle

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(tagName, forKey: .tagName)
        try container.encode(assets, forKey: .assets)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(publishedAt, forKey: .publishedAt)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        tagName = try container.decode(String.self, forKey: .tagName)
        assets = try container.decode([Asset].self, forKey: .assets)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        publishedAt = try container.decode(Date.self, forKey: .publishedAt)
    }
}
