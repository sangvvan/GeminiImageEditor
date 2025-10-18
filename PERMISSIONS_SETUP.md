# Photo Library Permissions Setup

## Required Permissions for Image Saving

To fix the image saving issues, you need to add the following permissions to your Xcode project:

### 1. Add to Info.plist (in Xcode)

Open your project in Xcode and add these entries to your Info.plist file:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to save generated images and select photos for face swapping.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save generated images to your photo library.</string>

<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos for face swapping.</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video recording features.</string>
```

### 2. How to Add in Xcode:

1. **Open Xcode project**
2. **Select your project** in the navigator
3. **Select your target** (GeminiImageEditor)
4. **Go to Info tab**
5. **Add the following keys:**
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`
   - `NSCameraUsageDescription`
   - `NSMicrophoneUsageDescription`

### 3. Alternative: Add via Build Settings

If Info.plist editing doesn't work, you can add these in Build Settings:

1. **Go to Build Settings**
2. **Search for "Info.plist"**
3. **Add the keys in "Info.plist Values"**

## What This Fixes:

- ✅ **Image saving** will work properly
- ✅ **Permission requests** will show proper messages
- ✅ **App won't crash** when saving images
- ✅ **Photo library access** will be granted correctly

## Testing:

After adding permissions:
1. **Run the app**
2. **Generate an image**
3. **Tap "Save"** - should request permission
4. **Grant permission** - image should save successfully
5. **Check Photos app** - image should be there

## Troubleshooting:

If you still have issues:
1. **Clean build folder** (Cmd+Shift+K)
2. **Delete derived data**
3. **Rebuild and run**
4. **Check console logs** for permission status
