//
//  Scope.swift
//  Deli
//

/// All instances lifecycle is managed by IoC Container.
/// The `scope` property specifies how to manage it.
public enum Scope {
    
    /// Instantiated when an object graph is being created.
    case always
    
    /// An instance managed by the Container used `strong` caching strategy.
    /// Once created, will not be re-instantiating.
    case singleton
    
    /// Is always created.
    case prototype
    
    /// It is similar to `singleton` but uses `weak` caching strategy.
    /// Naturally, if not referenced will be released on memory.
    ///
    /// However, if the specified type is a value-type like `struct`, it works the same as prototype.
    case weak
    
}
