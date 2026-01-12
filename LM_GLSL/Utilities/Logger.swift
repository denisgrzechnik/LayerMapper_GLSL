//
//  Logger.swift
//  LM_GLSL
//
//  Created on 04/11/2025
//  System logowania do pliku
//

import Foundation

class Logger {
    static let shared = Logger()
    
    private var logFileURL: URL?
    private let queue = DispatchQueue(label: "com.layermapper.glsl.logger", qos: .background)
    
    init() {
        setupLogFile()
    }
    
    private func setupLogFile() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access documents directory")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        logFileURL = documentsDirectory.appendingPathComponent("LM_GLSL_\(dateString).log")
        
        if let url = logFileURL {
            print("📝 Log file location: \(url.path)")
            
            // Create file if it doesn't exist
            if !FileManager.default.fileExists(atPath: url.path) {
                FileManager.default.createFile(atPath: url.path, contents: nil)
            }
            
            // Write header
            let header = """
            ==========================================
            LM_GLSL - Debug Log
            Started: \(Date())
            ==========================================
            
            """
            writeToFile(header)
        }
    }
    
    func log(_ message: String, category: String = "INFO") {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(category)] \(message)"
        
        // Print to console
        print(logMessage)
        
        // Write to file
        writeToFile(logMessage + "\n")
    }
    
    private func writeToFile(_ message: String) {
        guard let url = logFileURL else { return }
        
        queue.async {
            if let data = message.data(using: .utf8) {
                if let fileHandle = try? FileHandle(forWritingTo: url) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    try? data.write(to: url, options: .atomic)
                }
            }
        }
    }
    
    func getLogFileURL() -> URL? {
        return logFileURL
    }
    
    func getLogContents() -> String? {
        guard let url = logFileURL else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }
    
    func clearLog() {
        guard let url = logFileURL else { return }
        try? FileManager.default.removeItem(at: url)
        setupLogFile()
    }
}

// Convenience global functions
func logDebug(_ message: String, category: String = "DEBUG") {
    Logger.shared.log(message, category: category)
}

func logError(_ message: String, category: String = "ERROR") {
    Logger.shared.log("❌ \(message)", category: category)
}

func logWarning(_ message: String, category: String = "WARNING") {
    Logger.shared.log("⚠️ \(message)", category: category)
}

func logInfo(_ message: String, category: String = "INFO") {
    Logger.shared.log("ℹ️ \(message)", category: category)
}
