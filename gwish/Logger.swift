//
//  Logger.swift
//  gwish
//
//  Created by Connie Zhu on 4/24/25.
//

import Foundation

// Example Use:
// Logger.debug("User tapped the save button")
// Logger.info("Creating wishlist with title: \(wishlistTitle)")
// Logger.warning("Price field is empty")
// Logger.error("Firestore save failed: \(error.localizedDescription)")

enum LogLevel: String {
    case debug = "🐛 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
}

struct Logger {
    static func log(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[\(level.rawValue)] [\(fileName):\(line) \(function)] - \(message)")
        #endif
    }

    static func debug(_ message: String) {
        log(message, level: .debug)
    }

    static func info(_ message: String) {
        log(message, level: .info)
    }

    static func warning(_ message: String) {
        log(message, level: .warning)
    }

    static func error(_ message: String) {
        log(message, level: .error)
    }
}
