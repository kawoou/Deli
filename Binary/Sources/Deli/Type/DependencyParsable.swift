//
//  DependencyParsable.swift
//  Deli
//

protocol DependencyParsable {
    func parse(
        by source: Structure,
        fileContent: String,
        typePrefix: String,
        typealiasMap: [String: [String]]
    ) throws -> [Dependency]
}
