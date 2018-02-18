//
//  Runnable.swift
//  Deli
//

import Foundation

protocol Runnable: class {
    associatedtype ArgumentType
    associatedtype ModuleType
    
    var moduleList: [ModuleType] { get }
    
    func run(_ data: [ArgumentType]) throws -> [Results]
    func reset()
    
    init(_ modules: [ModuleType])
}
extension Runnable {
    func reset() {}
}
