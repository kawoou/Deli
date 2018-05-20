//
//  ModuleFactory.swift
//  Deli
//

/// The ModuleFactory protocol is a factory of that loads dependency graph.
///
/// The code that generates dependency graph should be written on
/// load() method.
public protocol ModuleFactory: class {
    /// Load the dependency graph on AppContext.
    ///
    /// - Parameters:
    ///     - context: Instance of AppContext.
    func load(context: AppContextType)
    
    /// Pre-generated initialize method for instantiating.
    init()
}
