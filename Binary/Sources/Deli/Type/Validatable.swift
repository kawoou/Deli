//
//  Validatable.swift
//  Deli
//

protocol Validatable {
    func validate(by results: [Results]) throws
}
