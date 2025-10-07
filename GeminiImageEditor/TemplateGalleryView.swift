//
//  TemplateGalleryView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI

struct TemplateGalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory = "All"
    @State private var selectedTemplate: Any?
    @State private var showingTemplateDetail = false
    @State private var userInput = ""
    
    let type: TemplateType
    
    enum TemplateType {
        case image, video
    }
    
    var templates: [Any] {
        switch type {
        case .image:
            return ContentTemplates.shared.getImageTemplates(for: selectedCategory)
        case .video:
            return ContentTemplates.shared.getVideoTemplates(for: selectedCategory)
        }
    }
    
    var categories: [String] {
        switch type {
        case .image:
            return ContentTemplates.shared.getImageCategories()
        case .video:
            return ContentTemplates.shared.getVideoCategories()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: type == .image ? "photo.stack" : "video.stack")
                        .font(.system(size: 40))
                        .foregroundColor(type == .image ? .purple : .orange)
                    
                    Text("\(type == .image ? "Image" : "Video") Templates")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Choose from trending templates")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ? 
                                        (type == .image ? Color.purple : Color.orange) : 
                                        Color(.systemGray5)
                                    )
                                    .foregroundColor(
                                        selectedCategory == category ? .white : .primary
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                
                // Templates Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(Array(templates.enumerated()), id: \.offset) { index, template in
                            if type == .image, let imageTemplate = template as? ImageTemplate {
                                ImageTemplateCard(
                                    template: imageTemplate,
                                    onTap: {
                                        selectedTemplate = imageTemplate
                                        showingTemplateDetail = true
                                    }
                                )
                            } else if type == .video, let videoTemplate = template as? VideoTemplate {
                                VideoTemplateCard(
                                    template: videoTemplate,
                                    onTap: {
                                        selectedTemplate = videoTemplate
                                        showingTemplateDetail = true
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingTemplateDetail) {
            if let imageTemplate = selectedTemplate as? ImageTemplate {
                TemplateDetailView(template: imageTemplate, type: .image)
            } else if let videoTemplate = selectedTemplate as? VideoTemplate {
                TemplateDetailView(template: videoTemplate, type: .video)
            }
        }
    }
}

// MARK: - Image Template Card

struct ImageTemplateCard: View {
    let template: ImageTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
                
                VStack(spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(template.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 160)
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Template Detail View

struct TemplateDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var userInput = ""
    @State private var isLoading = false
    @State private var generatedImage: UIImage?
    @State private var generatedDescription = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let template: Any
    let type: TemplateGalleryView.TemplateType
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Template Info
                    VStack(spacing: 12) {
                        if let imageTemplate = template as? ImageTemplate {
                            Image(systemName: imageTemplate.icon)
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            
                            Text(imageTemplate.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(imageTemplate.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        } else if let videoTemplate = template as? VideoTemplate {
                            Image(systemName: videoTemplate.icon)
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text(videoTemplate.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(videoTemplate.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // User Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Content")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Enter your content details...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    // Generate Button
                    Button(action: generateContent) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: type == .image ? "wand.and.stars" : "play.circle")
                            }
                            Text(isLoading ? "Generating..." : "Generate \(type == .image ? "Image" : "Video")")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(userInput.isEmpty ? Color.gray : (type == .image ? Color.purple : Color.orange))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(userInput.isEmpty || isLoading)
                    .padding(.horizontal, 20)
                    
                    // Generated Content
                    if type == .image, let image = generatedImage {
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
                            
                            Button(action: saveImage) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save Image")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                        }
                    } else if type == .video, !generatedDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generated Video Concept")
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
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Template")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Content Generation", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func generateContent() {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                if type == .image, let imageTemplate = template as? ImageTemplate {
                    let image = try await openAIService.generateImageWithTemplate(template: imageTemplate, userInput: userInput)
                    await MainActor.run {
                        generatedImage = image
                        isLoading = false
                        alertMessage = "Image generated successfully! 🎨"
                        showingAlert = true
                    }
                } else if type == .video, let videoTemplate = template as? VideoTemplate {
                    let description = try await openAIService.generateVideoWithTemplate(template: videoTemplate, userInput: userInput)
                    await MainActor.run {
                        generatedDescription = description
                        isLoading = false
                        alertMessage = "Video concept generated successfully! 🎬"
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Error generating content: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveImage() {
        guard let image = generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Image saved to Photos! 📸"
        showingAlert = true
    }
}

#Preview {
    TemplateGalleryView(type: .image)
}
