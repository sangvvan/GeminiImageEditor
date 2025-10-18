//
//  ENVLoader.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import Foundation

class ENVLoader {
    static let shared = ENVLoader()
    
    private var envVariables: [String: String] = [:]
    
    private init() {
        loadENVFile()
    }
    
    // MARK: - Load .env File
    
    private func loadENVFile() {
        // Try to find .env file in bundle or documents directory
        let possiblePaths = [
            Bundle.main.path(forResource: ".env", ofType: nil),
            getDocumentsDirectory() + "/.env",
            getDocumentsDirectory() + "/../.env" // Project root
        ]
        
        for path in possiblePaths {
            if let envPath = path, FileManager.default.fileExists(atPath: envPath) {
                loadENVFromPath(envPath)
                print("✅ Loaded .env file from: \(envPath)")
                return
            }
        }
        
        print("⚠️ No .env file found, using environment variables only")
    }
    
    private func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    private func loadENVFromPath(_ path: String) {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines and comments
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                
                // Parse KEY=VALUE format
                if let equalIndex = trimmedLine.firstIndex(of: "=") {
                    let key = String(trimmedLine[..<equalIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = String(trimmedLine[trimmedLine.index(after: equalIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Remove quotes if present
                    let cleanValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    
                    envVariables[key] = cleanValue
                    print("📄 Loaded: \(key) = \(maskValue(key, value: cleanValue))")
                }
            }
        } catch {
            print("❌ Error loading .env file: \(error.localizedDescription)")
        }
    }
    
    private func maskValue(_ key: String, value: String) -> String {
        // Mask sensitive values for logging
        if key.lowercased().contains("key") || key.lowercased().contains("secret") || key.lowercased().contains("token") {
            if value.count > 12 {
                let start = String(value.prefix(8))
                let end = String(value.suffix(4))
                let middle = String(repeating: "*", count: value.count - 12)
                return "\(start)\(middle)\(end)"
            }
            return "***masked***"
        }
        return value
    }
    
    // MARK: - Environment Variable Access
    
    func getValue(for key: String) -> String? {
        // First check environment variables (highest priority)
        if let envValue = ProcessInfo.processInfo.environment[key], !envValue.isEmpty {
            return envValue
        }
        
        // Then check .env file
        return envVariables[key]
    }
    
    func getBool(for key: String) -> Bool {
        guard let value = getValue(for: key) else { return false }
        return value.lowercased() == "true" || value == "1"
    }
    
    // MARK: - Specific API Keys
    
    var openaiAPIKey: String? {
        return getValue(for: "OPENAI_API_KEY")
    }
    
    var geminiAPIKey: String? {
        return getValue(for: "GEMINI_API_KEY")
    }
    
    var environment: String {
        return getValue(for: "ENVIRONMENT") ?? "development"
    }
    
    var debugMode: Bool {
        return getBool(for: "DEBUG_MODE")
    }
    
    // MARK: - Configuration Status
    
    func printConfigurationStatus() {
        print("🔧 ENV Configuration Status:")
        print("   Environment: \(environment)")
        print("   Debug Mode: \(debugMode)")
        print("   OpenAI API Key: \(openaiAPIKey?.isEmpty == false ? "✅ Configured" : "❌ Missing")")
        print("   Gemini API Key: \(geminiAPIKey?.isEmpty == false ? "✅ Configured" : "❌ Missing")")
        
        let issues = validateConfiguration()
        if !issues.isEmpty {
            print("   ⚠️ Configuration Issues:")
            for issue in issues {
                print("     - \(issue)")
            }
        } else {
            print("   ✅ Configuration is valid")
        }
    }
    
    func validateConfiguration() -> [String] {
        var issues: [String] = []
        
        if openaiAPIKey?.isEmpty ?? true {
            issues.append("OPENAI_API_KEY not found")
        }
        
        return issues
    }
}
