//
//  ModuleFactory.swift
//  Deli
//

public protocol ModuleFactory: class {
    func load(context: AppContextType)
    
    init()
}
