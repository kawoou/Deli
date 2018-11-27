//
//  QualifierCorrector.swift
//  Deli
//

final class QualifierCorrector: Correctable {
    
    // MARK: - Constant
    
    private struct Constant {
        static let ignoreTypes = ["Component", "Configuration", "Inject", "Autowired", "LazyAutowired"]
    }
    
    // MARK: - Private
    
    private let parser: Parser
    
    // MARK: - Public
    
    func correct(by results: [Results]) throws -> [Results] {
        results
            .filter { $0.qualifier == nil }
            .forEach { info in
                let typeList = parser.inheritanceList(info.instanceType)
                for type in typeList {
                    guard !Constant.ignoreTypes.contains(type.name) else { continue }
                    guard let qualifier = try? parseQualifier(type.structure, fileContent: type.content) else { continue }
                    guard let safeQualifier = qualifier else { continue }
                    
                    info.qualifier = safeQualifier
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
