//
//  EnvironmentConfig.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import Foundation

struct EnvironmentConfig {
    static let shared = EnvironmentConfig()
    
    private init() {}
    
    // MARK: - Environment Variables
    
    /// Load OpenAI API key from environment variables
    var openaiAPIKey: String? {
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    
    /// Load any custom API keys from environment
    var customAPIKeys: [String: String] {
        var keys: [String: String] = [:]
        
        // Check for common API key environment variables
        let envKeys = [
            "OPENAI_API_KEY",
            "GEMINI_API_KEY",
            "ANTHROPIC_API_KEY",
            "STABILITY_API_KEY"
        ]
        
        for key in envKeys {
            if let value = ProcessInfo.processInfo.environment[key] {
                keys[key] = value
            }
        }
        
        return keys
    }
    
    /// Check if running in debug mode
    var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Get app version
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// Get build number
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Security Helpers
    
    /// Check if API key is properly configured
    func isAPIKeyConfigured(for service: APIService) -> Bool {
        switch service {
        case .openai:
            return !(openaiAPIKey?.isEmpty ?? true)
        case .gemini:
            return false // Not implemented yet
        case .anthropic:
            return false // Not implemented yet
        case .stability:
            return false // Not implemented yet
        }
    }
    
    /// Get masked API key for logging (shows only first 8 and last 4 characters)
    func maskedAPIKey(for service: APIService) -> String? {
        let key: String?
        
        switch service {
        case .openai:
            key = openaiAPIKey
        case .gemini:
            key = nil // Not implemented yet
        case .anthropic:
            key = nil // Not implemented yet
        case .stability:
            key = nil // Not implemented yet
        }
        
        guard let apiKey = key, apiKey.count > 12 else {
            return nil
        }
        
        let start = String(apiKey.prefix(8))
        let end = String(apiKey.suffix(4))
        let middle = String(repeating: "*", count: apiKey.count - 12)
        
        return "\(start)\(middle)\(end)"
    }
}

// MARK: - API Service Enum

enum APIService {
    case openai
    case gemini
    case anthropic
    case stability
}

// MARK: - Configuration Validation

extension EnvironmentConfig {
    
    /// Validate all required environment variables
    func validateConfiguration() -> [String] {
        var issues: [String] = []
        
        // Check OpenAI API key
        if openaiAPIKey?.isEmpty ?? true {
            issues.append("OPENAI_API_KEY not found in environment variables")
        }
        
        // Add more validations as needed
        return issues
    }
    
    /// Print configuration status (for debugging)
    func printConfigurationStatus() {
        print("🔧 Environment Configuration Status:")
        print("   App Version: \(appVersion) (\(buildNumber))")
        print("   Debug Mode: \(isDebugMode)")
        
        print("   API Keys:")
        for (key, _) in customAPIKeys {
            if let masked = maskedAPIKey(for: key.contains("OPENAI") ? .openai : .openai) {
                print("     \(key): \(masked)")
            } else {
                print("     \(key): Not configured")
            }
        }
        
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
}

// MARK: - Extension for APIService

extension APIService {
    var environmentVariableName: String {
        switch self {
        case .openai:
            return "OPENAI_API_KEY"
        case .gemini:
            return "GEMINI_API_KEY"
        case .anthropic:
            return "ANTHROPIC_API_KEY"
        case .stability:
            return "STABILITY_API_KEY"
        }
    }
}
