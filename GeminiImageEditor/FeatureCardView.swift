//
//  FeatureCardView.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI

struct FeatureCardView: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 16) {
        FeatureCardView(
            title: "Photo Face Swap",
            icon: "person.crop.square",
            backgroundColor: Color(hex: "#F0FAFF")
        ) {
            print("Photo Face Swap tapped")
        }
        
        FeatureCardView(
            title: "Video Face Swap",
            icon: "video.circle",
            backgroundColor: Color(hex: "#F0FAFF")
        ) {
            print("Video Face Swap tapped")
        }
    }
    .padding()
}
