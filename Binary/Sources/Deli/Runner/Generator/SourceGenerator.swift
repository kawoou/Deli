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
        sourceList = results.compactMap { $0.makeSource() }
        #else
        sourceList = results.flatMap { $0.makeSource() }
        #endif
        
        let output = sourceList
            .joined(separator: "\n")
            .replacingOccurrences(of: "\n", with: "\n        ")

        return """
        //
        //  \(className).swift
        //  Auto generated code.
        //

        \(imports)
        final class \(className): ModuleFactory {
            override func load(context: AppContext) {
                \(output)
            }
        }
        """
    }

    // MARK: - Private

    private let className: String
    private let results: [Results]

    // MARK: - Lifecycle
    
    init(results: [Results]) {
        self.className = "DeliFactory"
        self.results = results
    }
    init(className: String, results: [Results]) {
        self.className = className
        self.results = results
    }
}
