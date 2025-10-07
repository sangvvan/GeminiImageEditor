//
//  ContentTemplates.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI
import UIKit

// MARK: - Image Templates

struct ImageTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let category: String
    let size: String
    let quality: String
    let basePrompt: String
    
    func generatePrompt(userInput: String) -> String {
        return basePrompt.replacingOccurrences(of: "{userInput}", with: userInput)
    }
}

// MARK: - Video Templates

struct VideoTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let category: String
    let basePrompt: String
    
    func generatePrompt(userInput: String) -> String {
        return basePrompt.replacingOccurrences(of: "{userInput}", with: userInput)
    }
}

// MARK: - Template Collections

class ContentTemplates {
    static let shared = ContentTemplates()
    
    private init() {}
    
    // MARK: - Image Templates
    
    let imageTemplates: [ImageTemplate] = [
        // Social Media & Marketing
        ImageTemplate(
            name: "Instagram Post",
            description: "Create stunning Instagram posts with trendy aesthetics",
            icon: "camera.circle.fill",
            category: "Social Media",
            size: "1024x1024",
            quality: "standard",
            basePrompt: "Create a modern, Instagram-worthy post featuring {userInput}. Use vibrant colors, trendy typography, and contemporary design elements. Include subtle shadows and professional lighting. Style: minimalist, clean, social media optimized."
        ),
        
        ImageTemplate(
            name: "Product Showcase",
            description: "Professional product photography for e-commerce",
            icon: "cube.box.fill",
            category: "E-commerce",
            size: "1024x1024",
            quality: "hd",
            basePrompt: "Create a professional product showcase image of {userInput}. Use clean white background, studio lighting, multiple angles, and premium presentation. Style: commercial photography, high-end, minimalist."
        ),
        
        ImageTemplate(
            name: "Event Poster",
            description: "Eye-catching event posters and announcements",
            icon: "calendar.badge.plus",
            category: "Events",
            size: "1024x1024",
            quality: "standard",
            basePrompt: "Design an attractive event poster for {userInput}. Use bold typography, vibrant colors, and engaging visuals. Include event details layout and modern design elements. Style: promotional, dynamic, attention-grabbing."
        ),
        
        // Creative & Art
        ImageTemplate(
            name: "AI Art Portrait",
            description: "Stunning AI-generated artistic portraits",
            icon: "person.crop.circle.fill",
            category: "Art",
            size: "1024x1024",
            quality: "hd",
            basePrompt: "Create a stunning AI art portrait of {userInput}. Use artistic lighting, creative composition, and unique visual style. Blend realism with artistic interpretation. Style: contemporary art, dramatic lighting, creative."
        ),
        
        ImageTemplate(
            name: "Fantasy Landscape",
            description: "Magical fantasy worlds and dreamy landscapes",
            icon: "leaf.circle.fill",
            category: "Fantasy",
            size: "1024x1024",
            quality: "hd",
            basePrompt: "Generate a breathtaking fantasy landscape featuring {userInput}. Use magical elements, ethereal lighting, and otherworldly beauty. Include mystical atmosphere and vibrant colors. Style: fantasy art, dreamlike, magical."
        ),
        
        ImageTemplate(
            name: "Cyberpunk Scene",
            description: "Futuristic cyberpunk cityscapes and neon aesthetics",
            icon: "building.2.crop.circle.fill",
            category: "Sci-Fi",
            size: "1024x1024",
            quality: "hd",
            basePrompt: "Create a cyberpunk scene featuring {userInput}. Use neon lights, futuristic architecture, dark atmosphere, and high-tech elements. Include rain reflections and glowing effects. Style: cyberpunk, neon, futuristic."
        ),
        
        // Business & Professional
        ImageTemplate(
            name: "Business Presentation",
            description: "Professional business graphics and infographics",
            icon: "chart.bar.fill",
            category: "Business",
            size: "1024x1024",
            quality: "standard",
            basePrompt: "Create a professional business graphic about {userInput}. Use clean design, corporate colors, data visualization elements, and modern layout. Include charts or infographic elements. Style: corporate, clean, professional."
        ),
        
        ImageTemplate(
            name: "Tech Startup",
            description: "Modern tech startup branding and visuals",
            icon: "laptopcomputer",
            category: "Technology",
            size: "1024x1024",
            quality: "standard",
            basePrompt: "Design a modern tech startup visual for {userInput}. Use sleek design, tech aesthetics, gradient backgrounds, and contemporary typography. Include digital elements and innovation themes. Style: modern tech, sleek, innovative."
        )
    ]
    
    // MARK: - Video Templates
    
    let videoTemplates: [VideoTemplate] = [
        // Social Media Videos
        VideoTemplate(
            name: "TikTok Viral",
            description: "Create viral TikTok-style short videos",
            icon: "video.circle.fill",
            category: "Social Media",
            basePrompt: "Create a viral TikTok video concept about {userInput}. Include trending elements, quick cuts, engaging transitions, and catchy visual effects. Style: dynamic, fast-paced, social media optimized, trending."
        ),
        
        VideoTemplate(
            name: "Instagram Reels",
            description: "Engaging Instagram Reels content",
            icon: "play.rectangle.fill",
            category: "Social Media",
            basePrompt: "Design an engaging Instagram Reels video about {userInput}. Use vertical format, trendy transitions, music sync, and visual storytelling. Style: engaging, trendy, Instagram-optimized, vertical."
        ),
        
        VideoTemplate(
            name: "YouTube Short",
            description: "YouTube Shorts content for maximum engagement",
            icon: "tv.fill",
            category: "Social Media",
            basePrompt: "Create a YouTube Shorts video concept for {userInput}. Include hook in first 3 seconds, clear value proposition, and strong call-to-action. Style: educational, engaging, YouTube-optimized."
        ),
        
        // Marketing & Promotion
        VideoTemplate(
            name: "Product Demo",
            description: "Professional product demonstration videos",
            icon: "cube.transparent.fill",
            category: "Marketing",
            basePrompt: "Create a product demonstration video for {userInput}. Show key features, benefits, and use cases. Include smooth transitions and professional presentation. Style: professional, clear, product-focused."
        ),
        
        VideoTemplate(
            name: "Brand Story",
            description: "Compelling brand storytelling videos",
            icon: "heart.circle.fill",
            category: "Marketing",
            basePrompt: "Create a brand story video about {userInput}. Include emotional connection, brand values, and customer testimonials. Use cinematic storytelling techniques. Style: emotional, cinematic, brand-focused."
        ),
        
        VideoTemplate(
            name: "Event Promo",
            description: "Dynamic event promotion videos",
            icon: "calendar.circle.fill",
            category: "Events",
            basePrompt: "Create an event promotion video for {userInput}. Include event highlights, excitement building, and clear call-to-action. Use energetic pacing and engaging visuals. Style: energetic, promotional, event-focused."
        ),
        
        // Educational & Tutorial
        VideoTemplate(
            name: "How-To Tutorial",
            description: "Step-by-step tutorial videos",
            icon: "book.circle.fill",
            category: "Education",
            basePrompt: "Create a how-to tutorial video about {userInput}. Break down into clear steps, use visual aids, and include practical examples. Style: educational, clear, step-by-step."
        ),
        
        VideoTemplate(
            name: "Tech Review",
            description: "Technology review and unboxing videos",
            icon: "gear.circle.fill",
            category: "Technology",
            basePrompt: "Create a technology review video about {userInput}. Include hands-on demonstration, pros and cons, and honest assessment. Style: informative, detailed, tech-focused."
        ),
        
        // Creative & Entertainment
        VideoTemplate(
            name: "Music Video",
            description: "Creative music video concepts",
            icon: "music.note",
            category: "Entertainment",
            basePrompt: "Create a music video concept for {userInput}. Include visual storytelling, creative transitions, and artistic elements that match the music style. Style: creative, artistic, music-focused."
        ),
        
        VideoTemplate(
            name: "Animation Story",
            description: "Animated storytelling videos",
            icon: "theatermasks.fill",
            category: "Animation",
            basePrompt: "Create an animated story video about {userInput}. Include character development, plot progression, and visual storytelling. Style: animated, storytelling, character-driven."
        )
    ]
    
    // MARK: - Helper Methods
    
    func getImageTemplates(for category: String) -> [ImageTemplate] {
        if category == "All" {
            return imageTemplates
        }
        return imageTemplates.filter { $0.category == category }
    }
    
    func getVideoTemplates(for category: String) -> [VideoTemplate] {
        if category == "All" {
            return videoTemplates
        }
        return videoTemplates.filter { $0.category == category }
    }
    
    func getImageCategories() -> [String] {
        let categories = Set(imageTemplates.map { $0.category })
        return ["All"] + Array(categories).sorted()
    }
    
    func getVideoCategories() -> [String] {
        let categories = Set(videoTemplates.map { $0.category })
        return ["All"] + Array(categories).sorted()
    }
}
