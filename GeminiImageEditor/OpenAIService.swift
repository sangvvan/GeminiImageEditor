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
        // TODO: Replace with your actual OpenAI API key
        self.apiKey = "your_openai_api_key_here"
        
        // Check if we have a valid API key
        if apiKey == "your_openai_api_key_here" || apiKey.isEmpty {
            print("⚠️ WARNING: No valid OpenAI API key found!")
            print("Please configure your OpenAI API key to use AI features.")
            print("Get your API key from: https://platform.openai.com/api-keys")
        }
    }
    
    // MARK: - Configuration
    
    /// Update the API key (call this method with your actual API key)
    func configureAPIKey(_ newKey: String) {
        self.apiKey = newKey
        print("✅ OpenAI API key configured successfully!")
    }
    
    // MARK: - Text to Video Generation
    
    func generateVideoFromText(_ prompt: String) async throws -> String {
        guard apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            throw OpenAIError.missingAPIKey
        }
        
        // Note: OpenAI doesn't have direct text-to-video API yet
        // This would typically use a service like RunwayML, Stable Video Diffusion, or similar
        // For demo purposes, we'll return a simulated response
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a video generation assistant. Create a detailed description of what a video based on the given prompt would look like, including scenes, camera movements, and visual elements."
                ],
                [
                    "role": "user",
                    "content": "Generate a video description for: \(prompt)"
                ]
            ],
            "max_tokens": 500
        ]
        
        let response = try await makeAPICall(endpoint: "/chat/completions", body: requestBody)
        
        if let choices = response["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw OpenAIError.invalidResponse
    }
    
    // MARK: - Face Swap Analysis
    
    func analyzeFaceSwapImages(sourceImage: UIImage, targetImage: UIImage) async throws -> String {
        guard apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            throw OpenAIError.missingAPIKey
        }
        
        // Convert images to base64
        guard let sourceData = sourceImage.jpegData(compressionQuality: 0.8),
              let targetData = targetImage.jpegData(compressionQuality: 0.8) else {
            throw OpenAIError.imageProcessingFailed
        }
        
        let sourceBase64 = sourceData.base64EncodedString()
        let targetBase64 = targetData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze these two images for face swap compatibility. Describe the faces, lighting conditions, angles, and provide recommendations for the best face swap approach. Consider factors like face shape, skin tone, lighting, and image quality."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(sourceBase64)"
                            ]
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(targetBase64)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]
        
        let response = try await makeAPICall(endpoint: "/chat/completions", body: requestBody)
        
        if let choices = response["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw OpenAIError.invalidResponse
    }
    
    // MARK: - Video Face Swap Analysis
    
    func analyzeVideoForFaceSwap(sourceImage: UIImage, videoDescription: String) async throws -> String {
        guard apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            throw OpenAIError.missingAPIKey
        }
        
        guard let imageData = sourceImage.jpegData(compressionQuality: 0.8) else {
            throw OpenAIError.imageProcessingFailed
        }
        
        let imageBase64 = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this face image for video face swap. The video content is: \(videoDescription). Provide recommendations for face swap implementation, considering lighting, movement, and facial expressions that would work best in the video context."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(imageBase64)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]
        
        let response = try await makeAPICall(endpoint: "/chat/completions", body: requestBody)
        
        if let choices = response["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw OpenAIError.invalidResponse
    }
    
    // MARK: - General Image Analysis
    
    func analyzeImage(_ image: UIImage, prompt: String) async throws -> String {
        guard apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            throw OpenAIError.missingAPIKey
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OpenAIError.imageProcessingFailed
        }
        
        let imageBase64 = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(imageBase64)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]
        
        let response = try await makeAPICall(endpoint: "/chat/completions", body: requestBody)
        
        if let choices = response["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw OpenAIError.invalidResponse
    }
    
    // MARK: - Helper Methods
    
    private func makeAPICall(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: baseURL + endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw OpenAIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.apiError(message)
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw OpenAIError.invalidResponse
        }
        
        return jsonResponse
    }
}

// MARK: - Error Types

enum OpenAIError: Error, LocalizedError {
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
            return "OpenAI API key is missing. Please configure your API key."
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

extension OpenAIService {
    // MARK: - Image Generation
    
    /// Generates an image from a text prompt using DALL-E
    func generateImage(prompt: String, size: String = "1024x1024", quality: String = "standard") async throws -> UIImage {
        guard !apiKey.isEmpty && apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
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
