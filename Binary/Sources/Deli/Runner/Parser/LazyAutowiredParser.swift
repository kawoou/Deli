//
//  LazyAutowiredParser.swift
//  Deli
//

import Regex
import SourceKittenFramework

final class LazyAutowiredParser: Parsable {

    // MARK: - Constant

    private struct Constant {
        static let inheritanceName = "LazyAutowired"
        static let injectorPrefix = "inject("
        
        static let typeRegex = "^([^.]+\\.)?(Dep[\\d]+)$".r!
        static func typealiasRegex(_ type: String) -> Regex {
            return "typealias[\\s]+\(type)[\\s]*=[\\s]*([^\\n]+)".r!
        }
        static let arrayRegex = "^\\[[\\s]*([^\\]]+)[\\s]*\\]$".r!
    }

    // MARK: - Private

    private func convert(name: String, fileContent: String) -> String? {
        guard let nameMatch = Constant.typeRegex.findFirst(in: name) else { return name }
        guard let nameResult = nameMatch.group(at: 2) else { return name }

        let dependencyName = nameResult

        guard let typeMatch = Constant.typealiasRegex(dependencyName).findFirst(in: fileContent) else { return nil }
        guard let typeResult = typeMatch.group(at: 1) else { return nil }
        return typeResult
    }

    private func validInjector(_ source: Structure) -> Bool {
        guard let name = source.name else { return false }
        guard name.hasPrefix(Constant.injectorPrefix) else { return false }
        guard source.substructures.count > 0 else { return false }
        return true
    }

    // MARK: - Public

    func parse(by source: Structure, fileContent: String) throws -> [Results] {
        guard let name = source.name else {
            Logger.log(.assert("Unknown structure name."))
            return []
        }
        guard source.inheritedTypes.contains(Constant.inheritanceName) else { return [] }

        let injectorList = source.substructures
            .filter { validInjector($0) }

        guard injectorList.count > 0 else {
            Logger.log(.error("Not found `\(name)` constructor.", source.getSourceLine(with: fileContent)))
            throw ParserError.constructorNotFound
        }
        guard injectorList.count == 1 else {
            for injector in injectorList {
                Logger.log(.error("Ambiguous `\(name)` constructor.", injector.getSourceLine(with: fileContent)))
            }
            throw ParserError.constructorAmbiguous
        }
        
        let scope = try parseScope(source, fileContent: fileContent)
        let qualifier = try parseQualifier(source, fileContent: fileContent)
        let dependencies = try injectorList
            .flatMap { $0.substructures }
            .filter { $0.kind == SwiftDeclarationKind.varParameter.rawValue }
            .map { info -> Dependency in
                guard let typeName = info.typeName else {
                    Logger.log(.error("Unknown `\(name)` dependency type.", info.getSourceLine(with: fileContent)))
                    throw ParserError.typeNotFound
                }
                guard let dependencyName = convert(name: typeName, fileContent: fileContent) else {
                    Logger.log(.error("Not found an aliased type named `\(name).\(typeName)`.", info.getSourceLine(with: fileContent)))
                    throw ParserError.typeNotFound
                }

                if let arrayType = Constant.arrayRegex.findFirst(in: dependencyName)?.group(at: 1) {
                    return Dependency(
                        parent: name,
                        target: injectorList.first,
                        name: arrayType,
                        type: .array
                    )
                }
                return Dependency(
                    parent: name,
                    target: injectorList.first,
                    name: dependencyName
                )
            }

        return [LazyAutowiredConstructorResult(name, scope, qualifier, dependencies)]
    }
}
