//
//  OpenAIService.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import Foundation
import UIKit

class OpenAIService: ObservableObject {
    private var apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    init() {
        // Try to load API key from multiple sources
        if let envKey = ENVLoader.shared.openaiAPIKey, !envKey.isEmpty {
            self.apiKey = envKey
            print("✅ OpenAI API key loaded from .env file or environment variable")
        } else {
            // Fallback to secure storage for development
            if let storedKey = KeychainHelper.shared.load(forKey: "openai_api_key"), !storedKey.isEmpty {
                self.apiKey = storedKey
                print("✅ OpenAI API key loaded from secure storage (development mode)")
            } else {
                self.apiKey = ""
                print("⚠️ WARNING: No OpenAI API key found!")
                print("Please add OPENAI_API_KEY to your .env file or set environment variable.")
                print("Get your API key from: https://platform.openai.com/api-keys")
            }
        }
    }
    
    // MARK: - Configuration
    
    /// Update the API key and store it securely in Keychain (development mode only)
    func configureAPIKey(_ newKey: String) {
        // Only allow manual configuration if no environment variable is set
        if ProcessInfo.processInfo.environment["OPENAI_API_KEY"]?.isEmpty ?? true {
            self.apiKey = newKey
            
            // Store in Keychain for secure persistence
            if KeychainHelper.shared.save(newKey, forKey: "openai_api_key") {
                print("✅ OpenAI API key configured and stored securely! (development mode)")
            } else {
                print("⚠️ Warning: API key configured but failed to store securely")
            }
        } else {
            print("⚠️ Manual API key configuration disabled in production mode")
            print("API key is loaded from environment variable OPENAI_API_KEY")
        }
    }
    
    /// Remove API key from secure storage (development mode only)
    func clearAPIKey() {
        // Only allow clearing if no environment variable is set
        if ProcessInfo.processInfo.environment["OPENAI_API_KEY"]?.isEmpty ?? true {
            self.apiKey = ""
            _ = KeychainHelper.shared.delete(forKey: "openai_api_key")
            print("✅ OpenAI API key cleared from secure storage (development mode)")
        } else {
            print("⚠️ API key clearing disabled in production mode")
            print("API key is managed via environment variable OPENAI_API_KEY")
        }
    }
    
    /// Test the OpenAI API connection
    func testAPIConnection() async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": "Hello! This is a test to verify the API key works. Please respond with 'API Test Successful!'"
                ]
            ],
            "max_tokens": 50
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError("HTTP \(httpResponse.statusCode): \(errorResponse)")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw OpenAIError.invalidResponse
        }
    }
    
    // MARK: - Text to Video Generation
    
    func generateVideoFromText(_ prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a creative video script assistant. Generate a concise and engaging description for a short video based on the user's prompt."
                ],
                [
                    "role": "user",
                    "content": "Generate a video description for: \(prompt)"
                ]
            ],
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError("HTTP \(httpResponse.statusCode): \(errorResponse)")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw OpenAIError.invalidResponse
        }
    }
    
    // MARK: - Face Swap Analysis
    
    func analyzeFaceSwap(sourceImage: UIImage, targetImage: UIImage) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }
        
        // Convert images to base64
        guard let sourceBase64 = sourceImage.jpegData(compressionQuality: 0.7)?.base64EncodedString(),
              let targetBase64 = targetImage.jpegData(compressionQuality: 0.7)?.base64EncodedString() else {
            throw OpenAIError.imageProcessingFailed
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are an expert in face swap analysis. Analyze the provided source and target images and give a brief, encouraging assessment of their compatibility for a face swap. Focus on factors like face angle, lighting, and expression. Do not actually perform the swap, just analyze."],
            ["role": "user", "content": [
                ["type": "text", "text": "Analyze these two images for face swap potential. The first is the source face, the second is the target image."],
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(sourceBase64)"]],
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(targetBase64)"]]
            ]]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o", // Using a vision-capable model
            "messages": messages,
            "max_tokens": 200,
            "temperature": 0.5
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError("HTTP \(httpResponse.statusCode): \(errorResponse)")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw OpenAIError.invalidResponse
        }
    }
}

extension OpenAIService {
    // MARK: - Image Generation
    
    /// Generates an image from a text prompt using DALL-E
    func generateImage(prompt: String, size: String = "1024x1024", quality: String = "standard") async throws -> UIImage {
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }
        
        let url = URL(string: "\(baseURL)/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": size,
            "quality": quality,
            "response_format": "url"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError("HTTP \(httpResponse.statusCode): \(errorResponse)")
        }
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let dataArray = json["data"] as? [[String: Any]],
           let firstImage = dataArray.first,
           let imageURLString = firstImage["url"] as? String,
           let imageURL = URL(string: imageURLString) {
            
            // Download the generated image
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)
            guard let image = UIImage(data: imageData) else {
                throw OpenAIError.imageProcessingFailed
            }
            return image
        } else {
            throw OpenAIError.invalidResponse
        }
    }
    
    // MARK: - Template-Based Generation
    
    /// Generates an image using a predefined template
    func generateImageWithTemplate(template: ImageTemplate, userInput: String) async throws -> UIImage {
        let prompt = template.generatePrompt(userInput: userInput)
        return try await generateImage(prompt: prompt, size: template.size, quality: template.quality)
    }
    
    /// Generates a video description using a predefined template
    func generateVideoWithTemplate(template: VideoTemplate, userInput: String) async throws -> String {
        let prompt = template.generatePrompt(userInput: userInput)
        return try await generateVideoFromText(prompt)
    }
}

// MARK: - Error Types

enum OpenAIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case encodingError
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case imageProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API Key is missing or invalid. Please configure it in settings."
        case .invalidURL:
            return "Invalid API URL."
        case .encodingError:
            return "Failed to encode request data."
        case .invalidResponse:
            return "Invalid response from OpenAI API."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "OpenAI API error: \(message)"
        case .imageProcessingFailed:
            return "Failed to process image data."
        }
    }
}
