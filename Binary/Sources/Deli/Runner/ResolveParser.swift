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

    func load(_ resultList: [ResolveData.Dependency], imports: [String]) {
        dependencies += resultList.map { ResolveResult($0, imports: imports) }
    }

    func load(_ infoList: [ConfigDependencyResolveFile]) throws {
        let decoder = YAMLDecoder()

        dependencies += try infoList
            .compactMap { info -> ConfigDependencyResolveFile? in
                let url = URL(fileURLWithPath: info.path)

                let fileManager = FileManager.default
                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: info.path, isDirectory: &isDirectory) else {
                    Logger.log(.warn("Not found dependency resolved file on `\(info.path)`.", nil))
                    return nil
                }
                guard isDirectory.boolValue else { return info }

                let newPath = url.appendingPathComponent(Constant.resolveFile).path
                guard fileManager.fileExists(atPath: newPath) else {
                    Logger.log(.warn("Not found dependency resolved file on `\(newPath)`.", nil))
                    return nil
                }
                return ConfigDependencyResolveFile(path: newPath, imports: info.imports)
            }
            .flatMap { info -> [ResolveResult] in
                let data = try String(contentsOfFile: info.path, encoding: .utf8)
                let resolveData = try decoder.decode(ResolveData.self, from: data)
                return resolveData.dependency
                    .map { ResolveResult($0, imports: info.imports) }
            }
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
