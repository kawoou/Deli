//
//  LoadPriority.swift
//  Deli
//

public enum LoadPriority {
    case high
    case normal
    case low
    case priority(UInt)
    
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
