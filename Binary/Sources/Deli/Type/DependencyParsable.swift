//
//  DependencyParsable.swift
//  Deli
//

protocol DependencyParsable {
    func parse(by source: Structure, fileContent: String) throws -> [Dependency]
}
