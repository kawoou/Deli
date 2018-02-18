//
//  Correctable.swift
//  Deli
//

protocol Correctable {
    func correct(by results: [Results]) throws -> [Results]
    
    init(parser: Parser)
}
