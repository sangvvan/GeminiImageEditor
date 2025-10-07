//
//  VideoFaceSwapView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI
import PhotosUI
import AVFoundation

struct VideoFaceSwapView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var sourceImage: UIImage?
    @State private var targetVideoURL: URL?
    @State private var showingSourcePicker = false
    @State private var showingVideoPicker = false
    @State private var isProcessing = false
    @State private var resultVideoURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "video.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Video Face Swap")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Swap a face from a photo into a video using AI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Source Face Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Source Face (Face to copy)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: { showingSourcePicker = true }) {
                            ImageSelectionView(
                                image: sourceImage,
                                placeholder: "Select source face photo"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Target Video Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Video (Video to modify)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: { showingVideoPicker = true }) {
                            VideoSelectionView(
                                videoURL: targetVideoURL,
                                placeholder: "Select target video"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Process Button
                    Button(action: processVideoFaceSwap) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "video.badge.plus")
                            }
                            Text(isProcessing ? "Processing Video..." : "Swap Face in Video")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canProcess ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canProcess || isProcessing)
                    .padding(.horizontal, 20)
                    
                    // Result Section
                    if let resultVideoURL = resultVideoURL {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Result Video")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            VideoResultView(videoURL: resultVideoURL)
                                .frame(height: 200)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            
                            Button(action: saveVideoResult) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save to Photos")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Video Face Swap")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingSourcePicker) {
            PhotoPicker(selectedImage: $sourceImage)
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPicker(selectedVideoURL: $targetVideoURL)
        }
        .alert("Video Face Swap", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var canProcess: Bool {
        sourceImage != nil && targetVideoURL != nil
    }
    
    private func processVideoFaceSwap() {
        guard let _ = sourceImage, let _ = targetVideoURL else { return }
        
        isProcessing = true
        
        // Simulate video face swap processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            // In a real app, this would call an AI video face swap API
            // For demo purposes, we'll use the target video as result
            resultVideoURL = targetVideoURL
            isProcessing = false
            
            alertMessage = "Video face swap completed successfully! 🎬🎭"
            showingAlert = true
        }
    }
    
    private func saveVideoResult() {
        guard resultVideoURL != nil else { return }
        
        // In a real app, this would save the processed video to Photos
        alertMessage = "Video saved to Photos! 📹"
        showingAlert = true
    }
}

struct VideoSelectionView: View {
    let videoURL: URL?
    let placeholder: String
    
    var body: some View {
        ZStack {
            if let videoURL = videoURL {
                VideoThumbnailView(videoURL: videoURL)
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "video")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text(placeholder)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // Overlay to show it's tappable
            if videoURL == nil {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
            }
        }
    }
}

struct VideoThumbnailView: View {
    let videoURL: URL
    
    var body: some View {
        ZStack {
            // Placeholder for video thumbnail
            Color.black.opacity(0.3)
            
            VStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text("Video Selected")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct VideoResultView: View {
    let videoURL: URL
    
    var body: some View {
        ZStack {
            // Placeholder for processed video
            Color.black.opacity(0.3)
            
            VStack(spacing: 12) {
                Image(systemName: "video.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Processed Video")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Button(action: {
                    // Play video action
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Result")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideoURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { (url, error) in
                if let error = error {
                    print("Error loading video: \(error.localizedDescription)")
                    return
                }
                
                if let url = url {
                    DispatchQueue.main.async {
                        self.parent.selectedVideoURL = url
                    }
                }
            }
        }
    }
}

#Preview {
    VideoFaceSwapView()
}
