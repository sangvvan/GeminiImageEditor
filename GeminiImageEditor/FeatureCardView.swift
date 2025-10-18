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
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .shadow(
                color: Color.primary.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
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
