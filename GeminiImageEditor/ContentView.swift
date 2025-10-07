//
//  ContentView.swift
//  GeminiImageEditor
//
//  Created by Sang Vo on 19/6/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingPhotoPicker = false
    @State private var showingTextToVideo = false
    @State private var showingPhotoFaceSwap = false
    @State private var showingVideoFaceSwap = false
    @State private var showingPromptToImage = false
    @State private var showingPromptToVideo = false
    @State private var showingSettings = false
    @StateObject private var openAIService = OpenAIService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Carousel Header
                    CarouselHeaderView {
                        showingTextToVideo = true
                    }
                    .frame(height: 200)
                    
                    // AI Generation Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AI Generation")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            FeatureCardView(
                                title: "Prompt to Image",
                                icon: "photo.circle",
                                backgroundColor: Color(hex: "#F8F0FF")
                            ) {
                                showingPromptToImage = true
                            }
                            
                            FeatureCardView(
                                title: "Prompt to Video",
                                icon: "video.circle",
                                backgroundColor: Color(hex: "#FFF8F0")
                            ) {
                                showingPromptToVideo = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 30)
                    
                    // Face Swap Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Face Swap")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            FeatureCardView(
                                title: "Photo Face Swap",
                                icon: "person.crop.square",
                                backgroundColor: Color(hex: "#F0FAFF")
                            ) {
                                showingPhotoFaceSwap = true
                            }
                            
                            FeatureCardView(
                                title: "Video Face Swap",
                                icon: "video.badge.plus",
                                backgroundColor: Color(hex: "#F0FAFF")
                            ) {
                                showingVideoFaceSwap = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("MakeIt")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.blue)
            })
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingTextToVideo) {
            TextToVideoView()
        }
        .sheet(isPresented: $showingPromptToImage) {
            PromptToImageView()
        }
        .sheet(isPresented: $showingPromptToVideo) {
            EnhancedPromptToVideoView()
        }
        .sheet(isPresented: $showingPhotoFaceSwap) {
            PhotoFaceSwapView()
        }
        .sheet(isPresented: $showingVideoFaceSwap) {
            VideoFaceSwapView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
