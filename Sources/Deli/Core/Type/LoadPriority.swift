//
//  LoadPriority.swift
//  Deli
//

/// Priority that load ModuleFactory.
public enum LoadPriority {
    
    // MARK: - Case
    
    /// High priority
    case high
    
    /// Normal priority
    case normal
    
    /// Low priority
    case low
    
    /// Custom priority
    case priority(UInt)
    
    // MARK: - Internal
    
    var rawValue: UInt {
        switch self {
        case .high:
            return 1000
        case .normal:
            return 500
        case .low:
            return 100
        case .priority(let priority):
            return priority
        }
    }
}
