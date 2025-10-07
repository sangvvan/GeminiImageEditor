//
//  TextToVideoView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI
import AVFoundation

struct TextToVideoView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var inputText = ""
    @State private var isGenerating = false
    @State private var generatedVideoURL: URL?
    @State private var generatedDescription = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Text To Video")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Describe your video idea and let AI create it for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Describe your video")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    
                    Text("Example: A cat playing with a ball of yarn in a sunny garden")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                // Generate Button
                Button(action: generateVideo) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "play.circle.fill")
                        }
                        Text(isGenerating ? "Generating Video..." : "Generate Video")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(inputText.isEmpty || isGenerating)
                .padding(.horizontal, 20)
                
                    // Generated Video Preview
                    if !generatedDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Generated Video Description")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            ScrollView {
                                Text(generatedDescription)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .frame(height: 200)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                    }
                
                Spacer()
            }
            .navigationTitle("Text to Video")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Video Generation", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func generateVideo() {
        guard !inputText.isEmpty else { return }
        
        isGenerating = true
        generatedDescription = ""
        
        Task {
            do {
                let description = try await openAIService.generateVideoFromText(inputText)
                
                await MainActor.run {
                    generatedDescription = description
                    isGenerating = false
                    alertMessage = "Video description generated successfully! 🎬"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    if error.localizedDescription.contains("API key") {
                        alertMessage = "Please configure your OpenAI API key first in Settings."
                    } else {
                        alertMessage = "Failed to generate video: \(error.localizedDescription)"
                    }
                    showingAlert = true
                }
            }
        }
    }
}

struct VideoPreviewView: View {
    let videoURL: URL
    
    var body: some View {
        // Placeholder for video preview
        ZStack {
            Color.black.opacity(0.1)
            
            VStack(spacing: 12) {
                Image(systemName: "video.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Video Preview")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button(action: {
                    // Play video action
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Video")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
        }
    }
}

#Preview {
    TextToVideoView()
}
