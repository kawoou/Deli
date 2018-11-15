//
//  ContainerComponent.swift
//  Deli
//

import Foundation

protocol _ContainerComponent: class {
    var cache: Any? { get set }
    var weakCache: AnyObject? { get set }
    var qualifier: String { get }
    var scope: Scope { get }
    
    func resolve() -> Any?
}
protocol ContainerComponent: _ContainerComponent {
    associatedtype _Resolver
    var resolver: _Resolver { get }
}
