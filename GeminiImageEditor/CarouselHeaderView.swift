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
    
    var body: some View {
        TabView(selection: $currentIndex) {
            CarouselItemView(
                title: "Text To Video",
                subtitle: "One sentence, AI makes a video",
                backgroundImage: "banner_train_mountain",
                onTap: onTextToVideoTap
            )
            .tag(0)
            
            // Additional carousel items can be added here
            CarouselItemView(
                title: "AI Photo Enhancement",
                subtitle: "Transform your photos with AI magic",
                backgroundImage: "banner_photo",
                onTap: {}
            )
            .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 200)
        .onAppear {
            // Auto-scroll functionality
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    currentIndex = (currentIndex + 1) % 2
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
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: onTap) {
                        HStack(spacing: 8) {
                            Text("Try Now")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(20)
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
