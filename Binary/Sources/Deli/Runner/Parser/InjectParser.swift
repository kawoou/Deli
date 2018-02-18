//
//  InjectParser.swift
//  Deli
//

import SourceKittenFramework

final class InjectParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let inheritanceName = "Inject"
        static let functionName = "Inject"
        static let functionCallKey = "source.lang.swift.expr.call"

        static let typeRefererSuffix = ".self"
        static let injectFuncPrefix = "\(functionName)("
        static let injectFuncSuffix = ")"
        
        static let qualifierName = "qualifier"
        static let qualifierPrefix = "\(qualifierName):"
        static let qualifierRegex = "\(qualifierName):[\\s]*\"([^\"]*)\"".r!

        static let arrayRegex = "^\\[[\\s]*([^\\]]+)[\\s]*\\]$".r!
    }

    // MARK: - Private

    private func found(_ source: Structure, fileContent: String) throws -> Dependency? {
        guard let name = source.name else { return nil }
        guard name == Constant.functionName else { return nil }
        guard source.kind == Constant.functionCallKey else { return nil }

        guard let parent = source.parent else {
            Logger.log(.assert("Not found the parent of current structure on \(name)."))
            Logger.log(.error("Unknown error in `\(name)`."))
            throw ParserError.unknown
        }
        guard let index = parent.substructures.index(where: { $0 === source }) else {
            Logger.log(.assert("Not found the index of current structure on \(parent.name!)."))
            Logger.log(.error("Unknown error in `\(parent.name!)`."))
            throw ParserError.unknown
        }
        let callExpr: String = {
            guard index > 0 else {
                return fileContent[Int(source.offset)..<Int(source.offset + source.length)]
                    .replacingOccurrences(of: Constant.typeRefererSuffix, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let prevSource = parent.substructures[index - 1]
            return fileContent[Int(prevSource.offset)..<Int(source.offset + source.length)]
                .replacingOccurrences(of: Constant.typeRefererSuffix, with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }()

        guard let prefixRange = callExpr.range(of: Constant.injectFuncPrefix) else {
            Logger.log(.assert("Mismatched result of SourceKitten. \(callExpr)"))
            Logger.log(.error("Unknown error."))
            throw ParserError.unknown
        }
        guard let infixRange = callExpr.range(of: Constant.injectFuncSuffix) else {
            Logger.log(.assert("Mismatched result of SourceKitten. \(callExpr)"))
            Logger.log(.error("Unknown error."))
            throw ParserError.unknown
        }

        let arguments = String(callExpr[prefixRange.upperBound..<infixRange.lowerBound])
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard arguments.count > 0 else {
            Logger.log(.error("The `\(Constant.functionName)` method in `\(name)` required arguments."))
            throw ParserError.emptyArguments
        }
        
        let qualifier = arguments
            .first(where: { $0.contains(Constant.qualifierPrefix) })
            .flatMap { result -> String? in
                guard let match = Constant.qualifierRegex.findFirst(in: result) else { return nil }
                return match.group(at: 1)
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if let arrayMatch = Constant.arrayRegex.findFirst(in: arguments[0]), let arrayType = arrayMatch.group(at: 1) {
            return Dependency(name: arrayType, type: .array)
        }
        return Dependency(name: arguments[0], qualifier: qualifier)
    }

    private func searchInject(_ source: Structure, fileContent: String) throws -> [Dependency] {
        var dependencyList = [Dependency]()

        var queue = source.substructures
        while let item = queue.popLast() {
            guard let dependency = try found(item, fileContent: fileContent) else {
                queue.append(contentsOf: item.substructures)
                continue
            }
            dependencyList.append(dependency)
        }

        return dependencyList
    }

    // MARK: - Public

    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }

        let dependencyList = try searchInject(source, fileContent: fileContent)
        return [InjectProtocolResult(name, dependencyList)]
    }
}
