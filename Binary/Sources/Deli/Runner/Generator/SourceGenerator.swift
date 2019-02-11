//
//  SourceGenerator.swift
//  Deli
//

import Foundation

final class SourceGenerator: Generator {

    // MARK: - Public

    func generate() throws -> String {
        let imports = Set(results.flatMap { $0.imports } + ["Deli"])
            .sorted()
            .map { "import \($0)\n" }
            .joined()

        let sourceList: [String]
        #if swift(>=4.1)
        sourceList = results
            .filter { !$0.isResolved }
            .compactMap { $0.makeSource() }
        #else
        sourceList = results
            .filter { !$0.isResolved }
            .flatMap { $0.makeSource() }
        #endif
        
        let output = sourceList
            .joined(separator: "\n")
            .replacingOccurrences(of: "\n", with: "\n        ")

        let dictionaryData = generateDictionary(properties, indentDepth: 2)

        return """
        //
        //  \(className).swift
        //  Auto generated code.
        //

        \(imports)
        final class \(className): ModuleFactory {
            override func load(context: AppContext) {
                loadProperty(\(dictionaryData))
        
                \(output)
            }
        }
        """
    }

    // MARK: - Private

    private let className: String
    private let results: [Results]
    private let properties: [String: Any]

    private func generateDictionary(_ target: Any, indentDepth: Int) -> String {
        let indent = (0..<indentDepth)
            .map { _ in "    " }
            .joined()

        var result: String = ""
        if let target = target as? [String: Any] {
            guard target.count > 0 else { return "[:]" }

            result += "[\n"

            var index = 0
            for (key, value) in target.sorted(by: { $0.key < $1.key }) {
                index += 1

                let content = generateDictionary(value, indentDepth: indentDepth + 1)
                if target.count == index {
                    result += "\(indent)    \"\(key)\": \(content)\n"
                } else {
                    result += "\(indent)    \"\(key)\": \(content),\n"
                }
            }
            result += "\(indent)]"
        } else if let target = target as? [Any] {
            result += "[\n"
            for (index, value) in target.enumerated() {
                let content = generateDictionary(value, indentDepth: indentDepth + 1)
                if target.count == index {
                    result += "\(indent)    \(content)\n"
                } else {
                    result += "\(indent)    \(content),\n"
                }
            }
            result += "\(indent)]"
        } else {
            if target is NSNull {
                result += "\"\""
            } else if let stringValue = target as? String {
                result += "\"\(stringValue.replacingOccurrences(of: "\"", with: "\\\""))\""
            } else {
                result += "\"\(target)\""
            }
        }
        return result
    }

    // MARK: - Lifecycle
    
    convenience init(results: [Results], properties: [String: Any]) {
        self.init(
            className: "DeliFactory",
            results: results,
            properties: properties
        )
    }
    init(className: String, results: [Results], properties: [String: Any]) {
        self.className = className
        self.results = results
            .sorted { $0.instanceType < $1.instanceType }
        self.properties = properties
    }
}
