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
        guard name == Constant.functionName || name.hasSuffix(".\(Constant.functionName)") else { return nil }
        guard source.kind == Constant.functionCallKey else { return nil }

        let callExpr: String = fileContent
            .utf8[Int(source.offset)..<Int(source.offset + source.length)]?
            .replacingOccurrences(of: Constant.typeRefererSuffix, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
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

        guard let firstArgument = arguments.first else {
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
        
        let isPayload = arguments.contains { $0.contains(Constant.payloadPrefix) }

        if let arrayMatch = Constant.arrayRegex.findFirst(in: firstArgument), let arrayType = arrayMatch.group(at: 1) {
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
