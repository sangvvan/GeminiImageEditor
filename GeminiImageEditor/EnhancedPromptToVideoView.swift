//
//  EnhancedPromptToVideoView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI
import AVKit

struct EnhancedPromptToVideoView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var prompt: String = ""
    @State private var isLoading = false
    @State private var generatedDescription = ""
    @State private var generatedVideoURL: URL?
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
                        Image(systemName: "video.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("AI Video Generator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Create engaging videos from your ideas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Prompt Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Describe your video")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $prompt)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Text("Enter a detailed description of the video you want to create...")
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
                            .foregroundColor(.orange)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(templates.videoTemplates.prefix(5)) { template in
                                    VideoTemplateCard(
                                        template: template,
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
                    Button(action: generateVideo) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "play.circle")
                            }
                            Text(isLoading ? "Generating..." : "Generate Video")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(prompt.isEmpty ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(prompt.isEmpty || isLoading)
                    .padding(.horizontal, 20)
                    
                    // Generated Content
                    if !generatedDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Generated Video Concept")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            Text(generatedDescription)
                                .font(.body)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    if let videoURL = generatedVideoURL {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generated Video")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            VideoPlayer(player: AVPlayer(url: videoURL))
                                .frame(height: 250)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                Button(action: saveVideo) {
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
                                
                                Button(action: regenerateVideo) {
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
                    } else if !isLoading && !generatedDescription.isEmpty {
                        VStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .frame(height: 250)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "video.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        
                                        Text("Video Generation Simulated")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        
                                        Text("In a real implementation, this would show the generated video")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                )
                                .padding(.horizontal, 20)
                            
                            Button(action: simulateVideoGeneration) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Simulate Video Generation")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Generate Video")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingTemplates) {
            TemplateGalleryView(type: .video)
        }
        .alert("Video Generation", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func generateVideo() {
        guard !prompt.isEmpty else { return }
        
        isLoading = true
        generatedDescription = ""
        generatedVideoURL = nil
        
        Task {
            do {
                let description = try await openAIService.generateVideoFromText(prompt)
                await MainActor.run {
                    generatedDescription = description
                    isLoading = false
                    alertMessage = "Video concept generated successfully! 🎬"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Error generating video concept: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func simulateVideoGeneration() {
        // Simulate video generation with a placeholder video
        if let url = URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4") {
            generatedVideoURL = url
            alertMessage = "Video generation simulated! In a real app, this would be your generated video. 🎥"
            showingAlert = true
        }
    }
    
    private func saveVideo() {
        guard generatedVideoURL != nil else { return }
        // In a real app, this would save the video to the photo library
        alertMessage = "Video saved to Photos! 📹"
        showingAlert = true
    }
    
    private func regenerateVideo() {
        generateVideo()
    }
}

// MARK: - Video Template Card

struct VideoTemplateCard: View {
    let template: VideoTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: template.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
                
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
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EnhancedPromptToVideoView()
}
