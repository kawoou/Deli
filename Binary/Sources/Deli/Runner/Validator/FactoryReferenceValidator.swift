//
//  FactoryReferenceValidator.swift
//  Deli
//

import Foundation

final class FactoryReferenceValidator: Validatable {
    
    // MARK: - Private
    
    let parser: Parser
    
    // MARK: - Public
    
    func validate(by results: [Results]) throws {
        var map = [String: Results]()
        for result in results {
            map[result.instanceType] = result
        }
        
        var isError: Bool = false
        for result in results {
            guard !result.isResolved else { continue }
            for dependency in result.dependencies {
                guard map[dependency.name]?.isFactory == true else { continue }
                guard dependency.rule == .default else { continue }
                
                isError = true
                
                let target = dependency.target
                let content = parser.inheritanceList(dependency.parent).first?.content
                
                Logger.log(.error("The Factory type `\(dependency.name)` cannot be used as Dependency.", target?.getSourceLine(with: content)))
            }
        }
        
        guard !isError else {
            throw ValidatorError.factoryReference
        }
        return
    }
    
    // MARK: - Lifecycle
    
    init(parser: Parser) {
        self.parser = parser
    }
}
