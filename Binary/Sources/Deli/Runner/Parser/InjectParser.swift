//
//  InjectParser.swift
//  Deli
//

import SourceKittenFramework

final class InjectParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let inheritanceName = ["Inject", "Autowired", "LazyAutowired", "AutowiredFactory", "LazyAutowiredFactory", "Component"]
        static let functionName = "Inject"
        static let functionCallKey = "source.lang.swift.expr.call"

        static let typeRefererSuffix = ".self"
        static let injectFuncRegex = "Inject\\(([^\\(]*(\\([^\\)]*\\))*[^\\)]*)\\)".r!
        static let argumentRegex = ",[\\s]*([^:]+:[\\s]*\\([^\\)]*\\))|[\\s]*([^,]+)".r!
        
        static let qualifierName = "qualifier"
        static let qualifierPrefix = "\(qualifierName):"
        static let qualifierRegex = "\(qualifierName):[\\s]*\"([^\"]*)\"".r!
        
        static let payloadName = "with"
        static let payloadPrefix = "\(payloadName):"
        static let payloadRegex = "\(payloadName):[\\s]*\\(([^,]+,?)*\\)".r!

        static let arrayRegex = "^\\[[\\s]*([^\\]]+)[\\s]*\\]$".r!
    }

    // MARK: - Private

    private func found(_ source: Structure, root: Structure, fileContent: String) throws -> Dependency? {
        guard let rootName = root.name else { return nil }
        guard let name = source.name else { return nil }
        guard name == Constant.functionName else { return nil }
        guard source.kind == Constant.functionCallKey else { return nil }

        guard let parent = source.parent else {
            Logger.log(.assert("Not found the parent of current structure on \(name)."))
            Logger.log(.error("Unknown error in `\(name)`.", source.getSourceLine(with: fileContent)))
            throw ParserError.unknown
        }
        guard let index = parent.substructures.index(where: { $0 === source }) else {
            Logger.log(.assert("Not found the index of current structure on \(parent.name!)."))
            Logger.log(.error("Unknown error in `\(parent.name!)`.", source.getSourceLine(with: fileContent)))
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
        
        guard let callExprMatch = Constant.injectFuncRegex.findFirst(in: callExpr)?.group(at: 1) else {
            Logger.log(.assert("Mismatched usage of `\(Constant.functionName)` method on SourceKitten result. \(callExpr)"))
            Logger.log(.error("Unknown error.", source.getSourceLine(with: fileContent)))
            throw ParserError.unknown
        }
        
        let arguments = try Constant.argumentRegex
            .findAll(in: callExprMatch.trimmingCharacters(in: .whitespacesAndNewlines))
            .map { match -> String in
                guard let result = match.group(at: 1) ?? match.group(at: 2) else {
                    Logger.log(.error("Failed to parse argument `\(match.source)`.", source.getSourceLine(with: fileContent)))
                    throw ParserError.parseErrorArguments
                }
                return result
            }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard arguments.count > 0 else {
            Logger.log(.error("The `\(Constant.functionName)` method in `\(name)` required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.emptyArguments
        }
        
        let qualifier = arguments
            .first { $0.contains(Constant.qualifierPrefix) }
            .flatMap { result -> String? in
                guard let match = Constant.qualifierRegex.findFirst(in: result) else { return nil }
                return match.group(at: 1)
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let isPayload = arguments.first { $0.contains(Constant.payloadPrefix) } != nil

        if let arrayMatch = Constant.arrayRegex.findFirst(in: arguments[0]), let arrayType = arrayMatch.group(at: 1) {
            return Dependency(
                parent: rootName,
                target: source,
                name: arrayType,
                type: .array,
                rule: isPayload ? .payload : .default
            )
        }
        return Dependency(
            parent: rootName,
            target: source,
            name: arguments[0],
            rule: isPayload ? .payload : .default,
            qualifier: qualifier
        )
    }

    private func searchInject(_ source: Structure, fileContent: String) throws -> [Dependency] {
        var dependencyList = [Dependency]()

        var queue = source.substructures
        while let item = queue.popLast() {
            guard let dependency = try found(item, root: source, fileContent: fileContent) else {
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
        guard source.inheritedTypes.contains(where: { Constant.inheritanceName.contains($0) }) else { return [] }

        let dependencyList = try searchInject(source, fileContent: fileContent)
        return [InjectProtocolResult(name, dependencyList)]
    }
}
