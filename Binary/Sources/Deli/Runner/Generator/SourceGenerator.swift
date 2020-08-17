//
//  SourceGenerator.swift
//  Deli
//

import Foundation

final class SourceGenerator: Generator {

    // MARK: - Public

    func generate() throws -> String {
        let imports = Set(results.flatMap { $0.imports } + Array(resolveFactories.keys) + ["Deli"])
            .sorted()
            .map { "import \($0)\n" }
            .joined()

        let sourceList = results
            .filter { !$0.isResolved }
            .compactMap { $0.makeSource() }
        
        let output = sourceList
            .joined(separator: "\n")
            .replacingOccurrences(of: "\n", with: "\n        ")

        let dictionaryData = generateDictionary(properties, indentDepth: 2)

        let loadList = ("\n" + resolveFactories.map { "\($0.key).\($0.value).self" }
            .sorted { $0 < $1 }
            .joined(separator: ",\n"))
            .replacingOccurrences(of: "\n", with: "\n            ")

        let loadScript: String = {
            guard !resolveFactories.isEmpty else { return "" }
            return "context.load([\(loadList)\n        ])\n\n        "
        }()

        let linkData = Dictionary(grouping: results.compactMap { $0 as? ResolveLinkerResult }) { $0.module }
            .compactMap { (module, results) -> String? in
                guard let module = module else { return nil }
                guard let moduleFactory = resolveFactories[module] else { return nil }

                var uniqueSet = Set<String>()
                let linkData = results
                    .flatMap { result -> [(ResolveLinkerResult, String)] in
                        result.linkType.map { (result, $0) }
                    }
                    .filter { (result, children) in
                        let key = "\(module).\(result.instanceType):\(children)"
                        if uniqueSet.contains(key) {
                            return false
                        } else {
                            uniqueSet.insert(key)
                            return true
                        }
                    }
                    .sorted { $0.1 < $1.1 }
                    .map { (result, children) -> String in
                        let className = "\(module).\(result.instanceType)"
                        return """
                        $0.link(
                            NSClassFromString("\(className)")!,
                            qualifier: "\(result.qualifier ?? "")",
                            children: \(children).self
                        )
                        """
                    }
                    .joined(separator: "\n")
                    .replacingOccurrences(of: "\n", with: "\n    ")

                let factoryName = "\(module).\(moduleFactory)"
                return """
                context.getFactory(\(factoryName).self).forEach {
                    \(linkData)
                }
                """
            }
            .joined(separator: "\n")
            .replacingOccurrences(of: "\n", with: "\n        ")

        let innerScript = """
                context.loadProperty(\(dictionaryData))

                \(loadScript)\(linkData.isEmpty ? "" : linkData + "\n\n        ")\(output)
        """.trimmingCharacters(in: .whitespacesAndNewlines)

        return """
        //
        //  \(className).swift
        //  Auto generated code.
        //

        \(imports)
        // swiftlint:disable all
        \(accessControl)final class \(className): ModuleFactory {
            \(accessControl)override func load(context: AppContext) {
                \(innerScript)
            }
        }
        """
    }

    // MARK: - Private

    private let className: String
    private let accessControl: String
    private let results: [Results]
    private let properties: [String: Any]
    private let resolveFactories: [String: String]

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
            accessControl: nil,
            results: results,
            properties: properties,
            resolveFactories: [:]
        )
    }

    init(
        className: String,
        accessControl: String?,
        results: [Results],
        properties: [String: Any],
        resolveFactories: [String: String]
    ) {
        self.className = className
        self.accessControl = accessControl.map { "\($0) " } ?? ""
        self.results = results
            .sorted { $0.instanceType < $1.instanceType }
        self.properties = properties
        self.resolveFactories = resolveFactories
    }
}
