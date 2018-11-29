//
//  PropertyParser.swift
//  Deli
//

import Foundation
import Yams

final class PropertyParser {

    // MARK: - Constant

    private struct Constant {
        static let yamlExtension = ["yaml", "yml"]
        static let jsonExtension = ["json"]
    }

    // MARK: - Property

    private(set) var properties: [String: Any] = [:]

    // MARK: - Private

    private func loadYaml(_ url: URL) -> [String: Any] {
        do {
            let content = try String(contentsOfFile: url.path, encoding: .utf8)
            guard let dict = try Yams.load(yaml: content) as? [String: Any] else { return [:] }
            return dict
        } catch {
            return [:]
        }
    }
    private func loadJson(_ url: URL) -> [String: Any] {
        do {
            let content = try String(contentsOfFile: url.path, encoding: .utf8)
            guard let data = content.data(using: .utf8) else { return [:] }
            guard let dict = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else { return [:] }
            return dict
        } catch {
            return [:]
        }
    }

    // MARK: - Public

    func load(_ fileList: [String]) {
        properties = fileList
            .compactMap { URL(string: $0) }
            .reduce([:]) { (dict, url) -> [String: Any] in
                let ext = url.pathExtension
                let result: [String: Any]

                if Constant.yamlExtension.contains(ext) {
                    result = loadYaml(url)
                } else if Constant.jsonExtension.contains(ext) {
                    result = loadJson(url)
                } else {
                    result = loadYaml(url)
                }
                return dict.merging(result) { $1 }
            }
    }
    func reset() {
        properties = [:]
    }
    func getProperty(_ path: String) throws -> Any? {
        var target: Any = properties
        var key = ""
        var isStartBracket = false
        var isStartStringKey = false
        var isStringKey = false
        var stringStarter: Character = " "

        for character in path {
            switch character {
            case ".":
                guard !isStartStringKey else { throw PropertyParserError.notEndedColon }
                guard !isStartBracket else { throw PropertyParserError.notEndedBracket }
                guard !key.isEmpty else { continue }
                guard let oldTarget = target as? [String: Any] else { return nil }
                guard let newTarget = oldTarget[key] else { return nil }
                target = newTarget
                isStartBracket = false
                isStringKey = false
                key = ""

            case "\"", "\'":
                if isStartStringKey {
                    guard character == stringStarter else { throw PropertyParserError.notMatchedColon }
                    stringStarter = " "
                    isStartStringKey = false
                    isStringKey = true
                } else {
                    guard key.isEmpty else { throw PropertyParserError.notEmtpyKey }
                    stringStarter = character
                    isStartStringKey = true
                }

            case "[":
                if !key.isEmpty {
                    guard !isStartStringKey else { throw PropertyParserError.notEndedColon }
                    guard let oldTarget = target as? [String: Any] else { return nil }
                    guard let newTarget = oldTarget[key] else { return nil }
                    target = newTarget
                    isStartBracket = false
                    isStringKey = false
                    key = ""
                }
                guard !isStartBracket else { throw PropertyParserError.notEndedBracket }
                isStartBracket = true

            case "]":
                guard !isStartStringKey else { throw PropertyParserError.notEndedColon }
                guard isStartBracket else { throw PropertyParserError.notStartedBracket }
                if isStringKey {
                    guard let oldTarget = target as? [String: Any] else { return nil }
                    guard let newTarget = oldTarget[key] else { return nil }
                    target = newTarget
                } else if let index = Int(key) {
                    guard let oldTarget = target as? [Any] else { return nil }
                    guard index >= 0 else { return nil }
                    guard oldTarget.count > index else { return nil }
                    target = oldTarget[index]
                } else {
                    return nil
                }
                isStartBracket = false
                isStringKey = false
                key = ""

            default:
                key += String(character)
            }
        }
        if key.isEmpty {
            return target
        } else {
            guard !isStartStringKey else { throw PropertyParserError.notEndedColon }
            guard !isStartBracket else { throw PropertyParserError.notEndedBracket }
            guard let oldTarget = target as? [String: Any] else { return nil }
            return oldTarget[key]
        }
    }
}
