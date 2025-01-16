import Foundation
import os
import OSLog

public enum Logger {
    private static var logger: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app", category: "Logger")
    }

    public static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.debug, items, separator: separator, terminator: terminator)
    }

    public static func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.info, items, separator: separator, terminator: terminator)
    }

    public static func fault(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.fault, items, separator: separator, terminator: terminator)
    }

    public static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.error, items, separator: separator, terminator: terminator)
    }

    public static func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.default, items, separator: separator, terminator: terminator)
    }

    private static func log(_ level: LogLevel, _ items: [Any], separator: String, terminator _: String) {
        #if DEBUG
            let message = items.map { stringify($0) }.joined(separator: separator)
            let osLogType: OSLogType
            switch level {
            case .debug:
                osLogType = .debug
            case .info:
                osLogType = .info
            case .fault:
                osLogType = .fault
            case .error:
                osLogType = .error
            case .default:
                osLogType = .default
            }
            os_log("[%@] %{public}@", log: logger, type: osLogType, level.rawValue, message)
        #endif
    }

    private static func stringify(_ value: Any) -> String {
        if let array = value as? [Any] {
            return "[" + array.map { stringify($0) }.joined(separator: ", ") + "]"
        }
        if let dict = value as? [AnyHashable: Any] {
            return "{" + dict.map { "\($0.key): \(stringify($0.value))" }.joined(separator: ", ") + "}"
        }
        return "\(value)"
    }
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case fault = "FAULT"
    case error = "ERROR"
    case `default` = "NOTICE"
}
