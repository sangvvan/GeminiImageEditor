//
//  PhotoSaver.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import UIKit
import Photos

class PhotoSaver: NSObject {
    static let shared = PhotoSaver()
    
    private var completionHandler: ((Bool, Error?) -> Void)?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Save Image to Photos
    
    func saveImage(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        self.completionHandler = completion
        
        // Check authorization status
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            // Already authorized, save the image
            saveImageToPhotos(image)
            
        case .notDetermined:
            // Request permission
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        self?.saveImageToPhotos(image)
                    case .denied, .restricted:
                        let error = NSError(domain: "PhotoSaver", code: 403, userInfo: [
                            NSLocalizedDescriptionKey: "Photo library access denied"
                        ])
                        completion(false, error)
                    default:
                        let error = NSError(domain: "PhotoSaver", code: 404, userInfo: [
                            NSLocalizedDescriptionKey: "Photo library access not determined"
                        ])
                        completion(false, error)
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied
            let error = NSError(domain: "PhotoSaver", code: 403, userInfo: [
                NSLocalizedDescriptionKey: "Photo library access denied. Please enable access in Settings."
            ])
            completion(false, error)
            
        @unknown default:
            let error = NSError(domain: "PhotoSaver", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Unknown photo library authorization status"
            ])
            completion(false, error)
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.completionHandler?(success, error)
            }
        }
    }
    
    // MARK: - Check Authorization Status
    
    func checkPhotoLibraryPermission() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
    
    func isPhotoLibraryAuthorized() -> Bool {
        let status = checkPhotoLibraryPermission()
        return status == .authorized || status == .limited
    }
    
    // MARK: - Legacy UIImageWriteToSavedPhotosAlbum Support
    
    func saveImageLegacy(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        self.completionHandler = completion
        
        // Use the legacy method with proper error handling
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            self.completionHandler?(error == nil, error)
        }
    }
}

// MARK: - PhotoSaver Extension for SwiftUI

extension PhotoSaver {
    func saveImageAsync(_ image: UIImage) async -> (success: Bool, error: Error?) {
        return await withCheckedContinuation { continuation in
            saveImage(image) { success, error in
                continuation.resume(returning: (success: success, error: error))
            }
        }
    }
}
