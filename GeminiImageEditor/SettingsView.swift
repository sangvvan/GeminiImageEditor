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
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isConfigured = false
    @State private var isProductionMode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: isProductionMode ? "checkmark.shield.fill" : "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isProductionMode ? .green : .blue)
                    
                    Text("OpenAI Configuration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(isProductionMode ? "API key configured via environment variable" : "Configure your OpenAI API key to enable AI features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Production Mode Indicator
                if isProductionMode {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.green)
                            Text("Production Mode")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Text("API key is loaded from environment variable OPENAI_API_KEY")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
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
                    // Always show test connection button
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
                    
                    // Only show development mode buttons if not in production
                    if !isProductionMode {
                        Button(action: saveAPIKey) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save API Key")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
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
                }
                .padding(.horizontal, 20)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text(isProductionMode ? "Production Deployment:" : "How to get your API Key:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if isProductionMode {
                        VStack(alignment: .leading, spacing: 8) {
                            InstructionStep(number: "✓", text: "API key configured via environment variable")
                            InstructionStep(number: "✓", text: "Production deployment ready")
                            InstructionStep(number: "✓", text: "User API key input disabled for security")
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            InstructionStep(number: "1", text: "Visit https://platform.openai.com/api-keys")
                            InstructionStep(number: "2", text: "Sign in to your OpenAI account")
                            InstructionStep(number: "3", text: "Click 'Create new secret key'")
                            InstructionStep(number: "4", text: "Copy the generated key and paste it above")
                        }
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
            checkConfigurationStatus()
        }
        .alert("Settings", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAPIKey() {
        // This function is now disabled in production mode
        if isProductionMode {
            alertMessage = "API key configuration is disabled in production mode."
            showingAlert = true
            return
        }
        
        // This should not be reached in production mode
        alertMessage = "API key configuration is not available."
        showingAlert = true
    }
    
    private func testAPIKey() {
        // Simple test to verify the API key works
        Task {
            do {
                // Test with a simple API call
                let _ = try await openAIService.testAPIConnection()
                
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
        // This function is now disabled in production mode
        if isProductionMode {
            alertMessage = "API key clearing is disabled in production mode."
            showingAlert = true
            return
        }
        
        // This should not be reached in production mode
        alertMessage = "API key clearing is not available."
        showingAlert = true
    }
    
    private func checkConfigurationStatus() {
        // Check if we're in production mode (.env file or environment variable is set)
        let envKey = ENVLoader.shared.openaiAPIKey
        isProductionMode = !(envKey?.isEmpty ?? true)
        
        // Check if API key is configured (either via .env/environment or keychain)
        if isProductionMode {
            // In production mode, check .env file or environment variable
            isConfigured = !(envKey?.isEmpty ?? true)
        } else {
            // In development mode, check keychain
            let storedKey = KeychainHelper.shared.load(forKey: "openai_api_key")
            isConfigured = !(storedKey?.isEmpty ?? true)
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
