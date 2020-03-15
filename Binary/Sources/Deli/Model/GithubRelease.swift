//
//  GithubRelease.swift
//  Deli
//

import Foundation

struct GithubRelease: Codable {

    // MARK: - Struct

    struct Asset: Codable {

        // MARK: - Enumerable

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case downloadURL = "browser_download_url"
            case contentType = "content_type"
            case size
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }

        // MARK: - Property

        let id: Int
        let name: String
        let downloadURL: String
        let contentType: String
        let size: Int
        let createdAt: Date
        let updatedAt: Date
    }

    // MARK: - Enumerable

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tagName = "tag_name"
        case assets
        case createdAt = "created_at"
        case publishedAt = "published_at"
    }

    // MARK: - Property

    let id: Int
    let name: String?
    let tagName: String

    let assets: [Asset]
    let createdAt: Date
    let publishedAt: Date
}
