//
//  Parsable.swift
//  Deli
//

protocol Parsable {
    var dependency: [DependencyParsable] { get }
    
    func parse(by source: Structure, fileContent: String) throws -> [Results]
}
extension Parsable {
    var dependency: [DependencyParsable] {
        return []
    }
}
