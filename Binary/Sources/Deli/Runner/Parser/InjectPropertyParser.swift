//
//  InjectPropertyParser.swift
//  Deli
//

import Regex
import SourceKittenFramework

final class InjectPropertyParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let inheritanceName = ["Inject", "Autowired", "LazyAutowired", "AutowiredFactory", "LazyAutowiredFactory", "Component"]
        static let functionName = "InjectProperty"
        static let functionCallKey = "source.lang.swift.expr.call"

        static let pathParseRegEx = "\"((\\\"|[^\\\"]+)+)\"".r!
    }

    // MARK: - Private

    private func found(_ source: Structure, root: Structure, fileContent: String) throws -> String? {
        guard let name = source.name else { return nil }
        guard name == Constant.functionName || name.hasSuffix(".\(Constant.functionName)") else { return nil }
        guard source.kind == Constant.functionCallKey else { return nil }

        guard let content = fileContent.utf8[Int(source.offset)..<Int(source.offset + source.length)] else {
            Logger.log(.error("Failed to parse argument in `\(Constant.functionName)` method required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.parseErrorArguments
        }
        guard let path = Constant.pathParseRegEx.findFirst(in: content)?.group(at: 1) else {
            Logger.log(.error("The `\(Constant.functionName)` method required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.emptyArguments
        }
        return path
    }

    private func searchInjectProperty(_ source: Structure, fileContent: String) throws -> [String] {
        var pathList = [String]()

        var queue = source.substructures
        while let item = queue.popLast() {
            queue.append(contentsOf: item.substructures)
            if let path = try found(item, root: source, fileContent: fileContent) {
                pathList.append(path)
            }
        }

        return pathList
    }

    // MARK: - Public

    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(where: { Constant.inheritanceName.contains($0) }) else { return [] }

        let pathList = try searchInjectProperty(source, fileContent: fileContent)
        
        return [
            InjectPropertyResult(
                name,
                propertyKeys: pathList,
                valueType: source.kind == SwiftDeclarationKind.struct.rawValue
            )
        ]
    }

}
