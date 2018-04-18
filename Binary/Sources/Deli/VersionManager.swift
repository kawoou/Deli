//
//  VersionManager.swift
//  Deli
//

import Foundation

class VersionManager {

    // MARK: - Constant

    private struct Constant {
        static let releaseURL = "https://api.github.com/repos/kawoou/Deli/releases"
    }

    // MARK: - Static

    static let shared = VersionManager()

    // MARK: - Property

    var current: String {
        return Version.current.value
    }

    // MARK: - Public

    func getLatestVersion(timeout: Double? = nil) -> String? {
        /// Request release api
        guard let url = URL(string: Constant.releaseURL) else { return nil }

        var jsonData: Data?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            jsonData = data
            semaphore.signal()
        }
        task.resume()
        if let timeout = timeout {
            _ = semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: UInt64(timeout)))
        } else {
            _ = semaphore.wait(timeout: .distantFuture)
        }

        /// Decode response data.
        guard let data = jsonData else { return nil }

        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
        }
        do {
            let releases = try decoder.decode([GithubRelease].self, from: data)
            guard let latestRelease = releases.first else { return nil }
            return latestRelease.tagName
        } catch {
            return nil
        }
    }
}
