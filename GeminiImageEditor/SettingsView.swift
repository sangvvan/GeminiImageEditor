//
//  SettingsView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var apiKey: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isConfigured = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("OpenAI Configuration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Configure your OpenAI API key to enable AI features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // API Key Input Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("API Key")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    SecureField("Enter your OpenAI API key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Your API key is stored locally and never shared. Get your key from https://platform.openai.com/api-keys")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                // Configuration Status
                HStack {
                    Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(isConfigured ? .green : .orange)
                    
                    Text(isConfigured ? "API Key Configured" : "API Key Not Configured")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isConfigured ? .green : .orange)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background((isConfigured ? Color.green : Color.orange).opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: saveAPIKey) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save API Key")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(apiKey.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(apiKey.isEmpty)
                    
                    Button(action: testAPIKey) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Test Connection")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isConfigured ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isConfigured)
                    
                    Button(action: clearAPIKey) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear API Key")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to get your API Key:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionStep(number: "1", text: "Visit https://platform.openai.com/api-keys")
                        InstructionStep(number: "2", text: "Sign in to your OpenAI account")
                        InstructionStep(number: "3", text: "Click 'Create new secret key'")
                        InstructionStep(number: "4", text: "Copy the generated key and paste it above")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadStoredAPIKey()
        }
        .alert("Settings", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }
        
        // Store the API key securely (in a real app, use Keychain)
        UserDefaults.standard.set(apiKey, forKey: "OpenAI_API_Key")
        
        // Configure the service
        openAIService.configureAPIKey(apiKey)
        
        isConfigured = true
        alertMessage = "API key saved successfully! 🎉"
        showingAlert = true
    }
    
    private func testAPIKey() {
        // Simple test to verify the API key works
        Task {
            do {
                // Test with a simple image analysis
                let testImage = UIImage(systemName: "photo") ?? UIImage()
                let _ = try await openAIService.analyzeImage(testImage, prompt: "Describe this image briefly.")
                
                await MainActor.run {
                    alertMessage = "API connection successful! ✅"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "API test failed: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func clearAPIKey() {
        apiKey = ""
        UserDefaults.standard.removeObject(forKey: "OpenAI_API_Key")
        isConfigured = false
        alertMessage = "API key cleared."
        showingAlert = true
    }
    
    private func loadStoredAPIKey() {
        if let storedKey = UserDefaults.standard.string(forKey: "OpenAI_API_Key"), !storedKey.isEmpty {
            apiKey = storedKey
            openAIService.configureAPIKey(storedKey)
            isConfigured = true
        }
    }
}

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
