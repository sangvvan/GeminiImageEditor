//
//  ConfigLoader.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import Foundation

class ConfigLoader {
    static let shared = ConfigLoader()
    
    private var config: [String: Any] = [:]
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - Configuration Loading
    
    private func loadConfiguration() {
        // Load from Config.plist first
        if let plistPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let plistData = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
            config = plistData
        }
        
        // Override with environment variables
        loadEnvironmentVariables()
        
        // Print configuration status in debug mode
        #if DEBUG
        printConfigurationStatus()
        #endif
    }
    
    private func loadEnvironmentVariables() {
        // Load OpenAI API key from environment
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            config["OpenAI_API_Key"] = envKey
        }
        
        // Load other environment variables
        let envKeys = [
            "ENVIRONMENT",
            "DEBUG_MODE",
            "API_BASE_URL"
        ]
        
        for key in envKeys {
            if let value = ProcessInfo.processInfo.environment[key] {
                config[key] = value
            }
        }
    }
    
    // MARK: - Configuration Access
    
    func getString(for key: String) -> String? {
        return config[key] as? String
    }
    
    func getBool(for key: String) -> Bool {
        return config[key] as? Bool ?? false
    }
    
    func getInt(for key: String) -> Int? {
        return config[key] as? Int
    }
    
    // MARK: - Specific Configuration
    
    var openaiAPIKey: String? {
        return getString(for: "OpenAI_API_Key")
    }
    
    var environment: String {
        return getString(for: "ENVIRONMENT") ?? "development"
    }
    
    var isDebugMode: Bool {
        return getBool(for: "DEBUG_MODE") || getBool(for: "DebugMode")
    }
    
    var useSecureStorage: Bool {
        return getBool(for: "SecureStorage")
    }
    
    // MARK: - Configuration Validation
    
    func validateConfiguration() -> [String] {
        var issues: [String] = []
        
        // Check required configurations
        if openaiAPIKey?.isEmpty ?? true {
            issues.append("OpenAI API key not configured")
        }
        
        return issues
    }
    
    private func printConfigurationStatus() {
        print("🔧 Configuration Status:")
        print("   Environment: \(environment)")
        print("   Debug Mode: \(isDebugMode)")
        print("   Secure Storage: \(useSecureStorage)")
        print("   OpenAI API Key: \(openaiAPIKey?.isEmpty == false ? "✅ Configured" : "❌ Missing")")
        
        let issues = validateConfiguration()
        if !issues.isEmpty {
            print("   ⚠️ Configuration Issues:")
            for issue in issues {
                print("     - \(issue)")
            }
        }
    }
    
    // MARK: - Security Helpers
    
    func getMaskedAPIKey() -> String? {
        guard let key = openaiAPIKey, key.count > 12 else { return nil }
        
        let start = String(key.prefix(8))
        let end = String(key.suffix(4))
        let middle = String(repeating: "*", count: key.count - 12)
        
        return "\(start)\(middle)\(end)"
    }
}
