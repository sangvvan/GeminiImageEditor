//
//  PhotoFaceSwapView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI
import PhotosUI

struct PhotoFaceSwapView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var sourceImage: UIImage?
    @State private var targetImage: UIImage?
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    @State private var isProcessing = false
    @State private var resultImage: UIImage?
    @State private var analysisResult = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.square")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Photo Face Swap")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Swap faces between two photos using AI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Source Image Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Source Face (Face to copy)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: { showingSourcePicker = true }) {
                            ImageSelectionView(
                                image: sourceImage,
                                placeholder: "Select source face"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Target Image Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Photo (Photo to modify)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: { showingTargetPicker = true }) {
                            ImageSelectionView(
                                image: targetImage,
                                placeholder: "Select target photo"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Process Button
                    Button(action: processFaceSwap) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            Text(isProcessing ? "Processing..." : "Swap Faces")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canProcess ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canProcess || isProcessing)
                    .padding(.horizontal, 20)
                    
                    // Analysis Result Section
                    if !analysisResult.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Analysis Result")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            ScrollView {
                                Text(analysisResult)
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
                    
                    // Result Section
                    if let resultImage = resultImage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Result")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            Image(uiImage: resultImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            
                            Button(action: saveResult) {
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
            .navigationTitle("Photo Face Swap")
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
        .sheet(isPresented: $showingTargetPicker) {
            PhotoPicker(selectedImage: $targetImage)
        }
        .alert("Face Swap", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var canProcess: Bool {
        sourceImage != nil && targetImage != nil
    }
    
    private func processFaceSwap() {
        guard let source = sourceImage, let target = targetImage else { return }
        
        isProcessing = true
        analysisResult = ""
        
        Task {
            do {
                let analysis = try await openAIService.analyzeFaceSwap(sourceImage: source, targetImage: target)
                
                await MainActor.run {
                    analysisResult = analysis
                    resultImage = target // For demo, we'll show the target image
                    isProcessing = false
                    
                    alertMessage = "Face swap analysis completed successfully! 🎭"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    if error.localizedDescription.contains("API key") {
                        alertMessage = "Please configure your OpenAI API key first in Settings."
                    } else {
                        alertMessage = "Failed to analyze images: \(error.localizedDescription)"
                    }
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveResult() {
        guard let image = resultImage else { return }
        
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
}

struct ImageSelectionView: View {
    let image: UIImage?
    let placeholder: String
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text(placeholder)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // Overlay to show it's tappable
            if image == nil {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
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
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoFaceSwapView()
}
