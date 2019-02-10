//
//  ResolveParser.swift
//  Deli
//

import Foundation
import Yams

final class ResolveParser {

    // MARK: - Constant

    struct Constant {
        static let resolveFile = "Deli.resolved"
    }

    // MARK: - Property

    private(set) var properties: [String: [String: Any]] = [:]

    // NARK: - Public

    func load(_ pathList: [String]) throws {
        let decoder = YAMLDecoder()

        dependencies = try pathList
            .compactMap { path in
                guard let url = URL(string: path) else { return nil }

                let fileManager = FileManager.default
                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
                    Logger.log(.warn("Not found dependency resolved file on `\(path)`.", nil))
                    return nil
                }
                guard isDirectory.boolValue else { return path }

                let newPath = url.appendingPathComponent(Constant.resolveFile).path
                guard fileManager.fileExists(atPath: newPath) else {
                    Logger.log(.warn("Not found dependency resolved file on `\(newPath)`.", nil))
                    return nil
                }
                return newPath
            }
            .map { try String(contentsOfFile: $0, encoding: .utf8) }
            .map { try decoder.decode(ResolveData.self, from: $0) }
            .flatMap { $0.dependency.map(ResolveResult.init) }
    }

    func run(_ data: [Results]) throws -> [Results] {
        return data + dependencies
    }
    func reset() {
        dependencies = []
    }

    // MARK: - Private

    private var dependencies: [Results] = []

    // MARK: - Lifecycle

    init() {}
}
