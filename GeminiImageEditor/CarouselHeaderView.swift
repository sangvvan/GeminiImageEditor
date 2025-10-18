//
//  CarouselHeaderView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI

struct CarouselHeaderView: View {
    @State private var currentIndex = 0
    let onTextToVideoTap: () -> Void
    
    private let carouselItems = [
        ("Text To Video", "One sentence, AI makes a video", "banner_1"),
        ("AI Photo Enhancement", "Transform your photos with AI magic", "banner_2"),
        ("Face Swap", "Swap faces in photos and videos", "banner_3"),
        ("Image Generation", "Generate images from descriptions", "banner_4")
    ]
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<carouselItems.count, id: \.self) { index in
                CarouselItemView(
                    title: carouselItems[index].0,
                    subtitle: carouselItems[index].1,
                    backgroundImage: carouselItems[index].2,
                    onTap: index == 0 ? onTextToVideoTap : {}
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 200)
        .onAppear {
            // Auto-scroll functionality
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    currentIndex = (currentIndex + 1) % carouselItems.count
                }
            }
        }
    }
}

struct CarouselItemView: View {
    let title: String
    let subtitle: String
    let backgroundImage: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background image
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            
            // Adaptive overlay for better text readability in both light and dark modes
            Color.primary.opacity(0.15)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.2),
                            Color.clear,
                            Color.black.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 8) {
                // Title section
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Button section
                HStack {
                    Spacer()
                    Button(action: onTap) {
                        HStack(spacing: 6) {
                            Text("Try Now")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    CarouselHeaderView {
        print("Text to Video tapped")
    }
}
