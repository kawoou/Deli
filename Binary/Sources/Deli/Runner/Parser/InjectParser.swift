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

        static let qualifierName = "qualifier"
        static let qualifierPrefix = "\(qualifierName):"
        static let qualifierRegex = "\(qualifierName):[\\s]*\"([^\"]*)\"".r!

        static let qualifierByName = "qualifierBy"
        static let qualifierByPrefix = "\(qualifierByName):"
        static let qualifierByRegex = "\(qualifierByName):[\\s]*\"([^\"]*)\"".r!
        
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

        let arguments: [String] = {
            let list = source.substructures
                .map { source in
                    return fileContent.utf8[Int(source.offset)..<Int(source.offset + source.length)] ?? ""
                }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            guard list.isEmpty else { return list }

            /// Bug fixed in the empty substructure of SourceKittenFramework.
            guard let sourceData = fileContent.utf8[Int(source.offset)..<Int(source.offset + source.length)] else { return [] }
            guard !sourceData.contains(",") else { return [] }
            guard let type = Constant.injectFuncRegex.findFirst(in: sourceData)?.group(at: 1) else { return [] }
            return [type]
        }()
        

        guard let firstArgument = arguments.first else {
            Logger.log(.error("The `\(Constant.functionName)` method in `\(name)` required arguments.", source.getSourceLine(with: fileContent)))
            throw ParserError.emptyArguments
        }

        let typeName: String = {
            if firstArgument.hasSuffix(Constant.typeRefererSuffix) {
                return firstArgument[0..<(firstArgument.count - Constant.typeRefererSuffix.count)]
            } else {
                return firstArgument
            }
        }()
        
        let qualifier = arguments
            .first { $0.hasPrefix(Constant.qualifierPrefix) }
            .flatMap { result -> String? in
                guard let match = Constant.qualifierRegex.findFirst(in: result) else { return nil }
                return match.group(at: 1)
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let qualifierBy = arguments
            .first { $0.hasPrefix(Constant.qualifierByName) }
            .flatMap { result -> String? in
                guard let match = Constant.qualifierByRegex.findFirst(in: result) else { return nil }
                return match.group(at: 1)
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let isPayload = arguments.contains { $0.hasPrefix(Constant.payloadPrefix) }

        if let arrayMatch = Constant.arrayRegex.findFirst(in: typeName), let arrayType = arrayMatch.group(at: 1) {
            return Dependency(
                parent: rootName,
                target: source,
                name: arrayType,
                type: .array,
                rule: isPayload ? .payload : .default,
                qualifier: qualifier,
                qualifierBy: qualifierBy
            )
        }
        return Dependency(
            parent: rootName,
            target: source,
            name: typeName,
            rule: isPayload ? .payload : .default,
            qualifier: qualifier,
            qualifierBy: qualifierBy
        )
    }

    private func searchInject(_ source: Structure, fileContent: String) throws -> [Dependency] {
        var dependencyList = [Dependency]()

        var queue = source.substructures
        while let item = queue.popLast() {
            queue.append(contentsOf: item.substructures)
            if let dependency = try found(item, root: source, fileContent: fileContent) {
                dependencyList.append(dependency)
            }
        }

        return dependencyList
    }

    // MARK: - Public

    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        return try parse(by: source, fileContent: fileContent, isInheritanceCheck: true)
    }
    func parse(by source: Structure, fileContent: String, isInheritanceCheck: Bool) throws -> [Results] {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        if isInheritanceCheck {
            guard source.inheritedTypes.contains(where: { Constant.inheritanceName.contains($0) }) else { return [] }
        }

        let dependencyList = try searchInject(source, fileContent: fileContent)
        return [
            InjectProtocolResult(
                name,
                dependencies: dependencyList,
                valueType: source.kind == SwiftDeclarationKind.struct.rawValue
            )
        ]
    }
}
