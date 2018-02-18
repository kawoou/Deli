//
//  Logger.swift
//  Deli
//

import Foundation

final class Logger {
    
    // MARK: - Enumerable
    
    enum LoggingType {
        case fatal(String)
        case error(String)
        case warn(String)
        case info(String)
        case debug(String)
        case assert(String)
        
        var prefix: String {
            switch self {
            case .fatal:
                return "❌ Fatal"
            case .error:
                return "⛔️ Error"
            case .warn:
                return "⚠️ Warning"
            case .info:
                return ""
            case .debug,
                 .assert:
                return "🔵️ Debug"
            }
        }
        
        var message: String {
            switch self {
            case .fatal(let message),
                 .error(let message),
                 .warn(let message),
                 .info(let message),
                 .debug(let message),
                 .assert(let message):
                return message
            }
        }
    }
    
    // MARK: - Private
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSZ"
        return formatter
    }()
    
    // MARK: - Public

    static var isError: Bool = true
    static var isWarn: Bool = true
    static var isInfo: Bool = true
    static var isDebug: Bool = false
    
    static func log(
        _ logging: LoggingType,
        _ file: String = #file,
        _ line: Int = #line,
        _ function: String = #function
    ) {
        let now = Logger.dateFormatter.string(from: Date())
        let file = URL(fileURLWithPath: file).lastPathComponent
        
        let output = "[\(now)] \(logging.prefix): \(logging.message)"
        
        switch logging {
        case .fatal:
            print("\(output) [\(file):\(line) (\(function))]")
            fatalError()
            
        case .error:
            guard isError else { return }
            print(output)

        case .warn:
            guard isWarn else { return }
            print(output)

        case .info:
            guard isInfo else { return }
            print(logging.message)

        case .debug:
            guard isDebug else { return }
            print("\(output) [\(file):\(line) (\(function))]")

        case .assert:
            guard isDebug else { return }
            print("\(output) [\(file):\(line) (\(function))]")
            assertionFailure()
        }
    }
    
    // MARK: - Lifecycle
    
    private init() {}
}
