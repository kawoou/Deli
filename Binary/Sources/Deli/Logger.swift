//
//  Logger.swift
//  Deli
//

import Foundation

final class Logger {
    
    // MARK: - Enumerable

    enum Color: Int {
        case `default` = 0

        case black = 30
        case red = 31
        case green = 32
        case yellow = 33
        case blue = 34
        case magenta = 35
        case cyan = 36
        case white = 37

        func resolve(_ text: String) -> String {
            switch self {
            case .default:
                return text
            default:
                return "\u{001B}[\0\(self.rawValue)m\(text)\u{001B}[m"
            }
        }
    }

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
        color: Color = .default,
        _ file: String = #file,
        _ line: Int = #line,
        _ function: String = #function
    ) {
        let now = Logger.dateFormatter.string(from: Date())
        let file = URL(fileURLWithPath: file).lastPathComponent
        
        let output = "[\(now)] \(logging.prefix): \(logging.message)"
        
        switch logging {
        case .fatal:
            print(color.resolve("\(output) [\(file):\(line) (\(function))]"))
            fatalError()
            
        case .error:
            guard isError else { return }
            print(color.resolve(output))

        case .warn:
            guard isWarn else { return }
            print(color.resolve(output))

        case .info:
            guard isInfo else { return }
            print(color.resolve(logging.message))

        case .debug:
            guard isDebug else { return }
            print(color.resolve("\(output) [\(file):\(line) (\(function))]"))

        case .assert:
            guard isDebug else { return }
            print(color.resolve("\(output) [\(file):\(line) (\(function))]"))
            assertionFailure()
        }
    }
    
    // MARK: - Lifecycle
    
    private init() {}
}
