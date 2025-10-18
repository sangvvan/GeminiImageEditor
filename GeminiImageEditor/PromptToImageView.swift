//
//  PromptToImageView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI

struct PromptToImageView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var prompt: String = ""
    @State private var isLoading = false
    @State private var generatedImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedCategory = "All"
    @State private var showingTemplates = false
    
    let templates = ContentTemplates.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "photo.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("AI Image Generator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Create stunning images from your imagination")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Prompt Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Describe your image")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $prompt)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Text("Enter a detailed description of the image you want to create...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .opacity(prompt.isEmpty ? 1 : 0),
                                alignment: .topLeading
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Templates Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Quick Templates")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("View All") {
                                showingTemplates = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(templates.imageTemplates.prefix(5)) { template in
                                    TemplateCard(
                                        template: template,
                                        type: .image,
                                        onTap: {
                                            prompt = template.generatePrompt(userInput: "your content here")
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Generate Button
                    Button(action: generateImage) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(isLoading ? "Generating..." : "Generate Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(prompt.isEmpty ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(prompt.isEmpty || isLoading)
                    .padding(.horizontal, 20)
                    
                    // Generated Image
                    if let image = generatedImage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generated Image")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 400)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                Button(action: saveImage) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Save")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: regenerateImage) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Regenerate")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Generate Image")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingTemplates) {
            TemplateGalleryView(type: .image)
        }
        .alert("Image Generation", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func generateImage() {
        guard !prompt.isEmpty else { return }
        
        isLoading = true
        generatedImage = nil
        
        Task {
            do {
                let image = try await openAIService.generateImage(prompt: prompt)
                await MainActor.run {
                    generatedImage = image
                    isLoading = false
                    alertMessage = "Image generated successfully! 🎨"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    // Better error handling
                    if error.localizedDescription.contains("API key") {
                        alertMessage = "Please configure your OpenAI API key in Settings first."
                    } else if error.localizedDescription.contains("network") {
                        alertMessage = "Network error. Please check your internet connection."
                    } else {
                        alertMessage = "Error generating image: \(error.localizedDescription)"
                    }
                    
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveImage() {
        guard let image = generatedImage else { return }
        
        PhotoSaver.shared.saveImage(image) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.alertMessage = "Image saved to Photos successfully! 📸"
                } else {
                    self.alertMessage = "Failed to save image: \(error?.localizedDescription ?? "Unknown error")"
                }
                self.showingAlert = true
            }
        }
    }
    
    private func regenerateImage() {
        generateImage()
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: ImageTemplate
    let type: TemplateType
    let onTap: () -> Void
    
    enum TemplateType {
        case image, video
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: template.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                Text(template.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PromptToImageView()
}
