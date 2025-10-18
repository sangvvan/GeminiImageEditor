//
//  GeminiImageEditorApp.swift
//  GeminiImageEditor
//
//  Created by Sang Vo on 19/6/25.
//

import SwiftUI

@main
struct GeminiImageEditorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Initialize configuration and handle any startup errors
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Print configuration status for debugging
        ENVLoader.shared.printConfigurationStatus()
        
        // Check photo library permissions
        let photoStatus = PhotoSaver.shared.checkPhotoLibraryPermission()
        print("📸 Photo Library Permission Status: \(photoStatus.rawValue)")
        
        // Handle any uncaught exceptions
        setupErrorHandling()
    }
    
    private func setupErrorHandling() {
        // Set up global error handling to prevent crashes
        NSSetUncaughtExceptionHandler { exception in
            print("❌ Uncaught Exception: \(exception)")
            print("❌ Call Stack: \(exception.callStackSymbols)")
        }
    }
}
