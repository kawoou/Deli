//
//  ScopeCorrector.swift
//  Deli
//

final class ScopeCorrector: Correctable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let ignoreTypes = ["Component", "Configuration", "Inject", "Autowired", "LazyAutowired"]
    }
    
    // MARK: - Private
    
    private let parser: Parser
    
    // MARK: - Public
    
    func correct(by results: [Results]) throws -> [Results] {
        results
            .filter { $0.scope == nil }
            .forEach { info in
                let typeList = parser.inheritanceList(info.instanceType)
                for type in typeList {
                    guard !Constant.ignoreTypes.contains(type.name) else { continue }
                    guard let scope = try? parseScope(type.structure, fileContent: type.content) else { continue }
                    guard let safeScope = scope else { continue }
                    
                    info.scope = safeScope
                    break
                }
            }
        
        return results
    }
    
    // MARK: - Lifecycle
    
    init(parser: Parser) {
        self.parser = parser
    }
}
