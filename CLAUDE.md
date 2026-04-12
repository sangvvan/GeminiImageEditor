# CLAUDE.md — GeminiImageEditor (MakeIt)

This file provides guidance for AI assistants working in this codebase.

---

## Project Overview

**GeminiImageEditor** (marketed as **MakeIt**) is a native iOS application built with Swift and SwiftUI. It provides AI-powered media generation features powered by the OpenAI API, including image generation, video generation, and face swapping.

**Platform:** iOS
**Language:** Swift 5 / SwiftUI
**Build System:** Xcode (no package manager — zero external dependencies)
**API:** OpenAI (DALL-E / GPT / vision endpoints)

---

## Repository Structure

```
GeminiImageEditor/
├── GeminiImageEditor/               # All Swift source files
│   ├── GeminiImageEditorApp.swift   # App entry point and initialization
│   ├── Views/
│   │   ├── ContentView.swift            # Home screen — feature grid navigation hub
│   │   ├── SettingsView.swift           # API key config and connection test
│   │   ├── PromptToImageView.swift      # Text-to-image generation UI
│   │   ├── EnhancedPromptToVideoView.swift  # Advanced video generation
│   │   ├── TextToVideoView.swift        # Simple text-to-video UI
│   │   ├── PhotoFaceSwapView.swift      # Photo-based face swap
│   │   ├── VideoFaceSwapView.swift      # Video-based face swap
│   │   ├── FeatureCardView.swift        # Reusable home screen card component
│   │   ├── CarouselHeaderView.swift     # Scrolling banner at top of home
│   │   └── TemplateGalleryView.swift    # Template browsing UI
│   ├── Services/
│   │   ├── OpenAIService.swift          # All OpenAI API calls (~13,600 lines)
│   │   ├── PhotoSaver.swift             # Save images to the Photos library
│   │   ├── KeychainHelper.swift         # Secure API key storage (dev mode)
│   │   ├── ENVLoader.swift              # Parses .env files at runtime
│   │   ├── ConfigLoader.swift           # Loads Config.plist with env overrides
│   │   └── EnvironmentConfig.swift      # Structured environment variable access
│   ├── Models/
│   │   ├── ContentTemplates.swift       # Pre-built prompt templates (~10,800 lines)
│   │   └── ColorExtensions.swift        # Hex color parsing and dark mode colors
│   ├── Config.plist                     # Default config values (no secrets)
│   └── Assets.xcassets/                 # App icons and banner images
├── GeminiImageEditor.xcodeproj/         # Xcode project file
├── AppImages/                           # App icon source images
├── DerivedData/                         # Xcode build artifacts (gitignored)
├── .env.example                         # Environment variable template
├── setup_environment.sh                 # Creates .env and updates .gitignore
├── run_app.sh                           # Loads .env then opens Xcode
├── start_app.sh                         # Validates API key then opens Xcode
├── test_deployment.sh                   # Validates deployment config
├── generate_app_images.py               # Python utility for icon generation
└── *.md                                 # Various documentation files
```

---

## Architecture

### Pattern: MVVM with SwiftUI

Views are SwiftUI structs. Business logic and API calls live in `ObservableObject` service classes, injected into views via `@StateObject`.

```swift
// Typical view setup
struct PromptToImageView: View {
    @StateObject private var service = OpenAIService.shared
    @State private var prompt = ""
    @State private var generatedImage: UIImage?
}
```

### Singleton Services

`OpenAIService` and `ENVLoader` use the singleton pattern:

```swift
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    private init() { }
}
```

### Async/Await

All API calls use Swift's structured concurrency:

```swift
func generateImage(prompt: String) async throws -> UIImage
func testAPIConnection() async throws -> String
```

Always call these within `Task { }` blocks in SwiftUI views or in `.task { }` modifiers.

---

## Configuration System (Three-Layer Priority)

The app resolves configuration in this priority order (highest to lowest):

1. **Process environment variables** — set before launching Xcode (e.g., via `start_app.sh`)
2. **.env file** — parsed at runtime by `ENVLoader.swift` from the app bundle or Documents directory
3. **Config.plist** — fallback defaults (no real secrets, only placeholders)

### Key Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | OpenAI API key (`sk-...`) |
| `ENVIRONMENT` | No | `development` (default) or `production` |
| `DEBUG_MODE` | No | `true` or `false` |
| `SECURE_STORAGE` | No | `true` to enable Keychain storage |

### Development Setup

```bash
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
./setup_environment.sh   # Configures .gitignore and .env
./run_app.sh             # Loads .env then opens Xcode
```

### Production

In production, set `OPENAI_API_KEY` as a process environment variable before building/running. Never hard-code keys.

---

## Security Rules

**Critical — follow these in all code changes:**

- **Never commit secrets.** `.env` is gitignored. `Config.plist` must never contain real keys.
- **Never hard-code API keys** in Swift source files.
- **Always mask API keys in logs:** use `sk-[first8]***[last4]` format.
- Use `KeychainHelper.shared` for persisting API keys in development mode only.
- `ProcessInfo.processInfo.environment["OPENAI_API_KEY"]` is the authoritative runtime key source.

---

## Code Conventions

### Naming
- Types: `PascalCase` (e.g., `OpenAIService`, `FeatureCardView`)
- Variables/functions: `camelCase` (e.g., `generateImage`, `apiKey`)
- Constants: `camelCase` or `UPPER_SNAKE_CASE` for env var names

### MARK Sections
Organize files with `// MARK: -` separators:
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - API Methods
// MARK: - Helper Methods
```

### Debug Logging
Use emoji-prefixed messages for log clarity:
```swift
print("✅ API connection successful")
print("❌ Failed to generate image: \(error)")
print("⚠️ API key not configured")
print("📄 Loaded template: \(templateName)")
```

### Error Handling
- Define errors in a custom enum conforming to `Error` (see `OpenAIError` in `OpenAIService.swift`)
- Surface errors to users via SwiftUI alerts (`@State private var errorMessage: String?`)
- Never silently swallow errors

### SwiftUI Layout
- Use `LazyVGrid` with adaptive columns for responsive grids
- Use `.sheet(isPresented:)` for modal feature navigation
- Use `NavigationView` / `NavigationLink` for drill-down navigation
- Use `Color` extensions from `ColorExtensions.swift` for consistent dark mode support

---

## Building and Running

This is a pure Xcode project. There is no `make`, `npm`, `gradle`, or similar build tool.

```bash
# Open the project in Xcode
open GeminiImageEditor.xcodeproj

# Or with environment variables pre-loaded:
./run_app.sh
```

Build and run from within Xcode targeting an iOS simulator or physical device. Minimum deployment target is set in the Xcode project settings.

---

## Testing

There are currently **no automated unit or UI tests** in the Xcode project.

**Manual testing:**
- Follow `UI_TEST_GUIDE.md` for feature-by-feature test scenarios.
- Use `test_deployment.sh` to validate that `OPENAI_API_KEY` is present and correctly formatted before deploying.

When adding new features, document manual test steps in `UI_TEST_GUIDE.md`.

---

## Key Files to Know

| File | Why it matters |
|------|---------------|
| `OpenAIService.swift` | All API logic lives here. Very large (~13,600 lines). Read carefully before editing. |
| `ContentTemplates.swift` | All pre-built prompt templates (~10,800 lines). Large data file — avoid large edits. |
| `ENVLoader.swift` | Controls how secrets reach the app. Understand before changing config behavior. |
| `KeychainHelper.swift` | Only Keychain access in the app — must keep secure. |
| `Config.plist` | Must never contain real API keys or secrets. |
| `.env.example` | Source of truth for required environment variables. Keep this up to date. |

---

## iOS Permissions

The app requires these iOS permissions (declared in `Info.plist`):

| Permission | Usage |
|------------|-------|
| `NSPhotoLibraryAddUsageDescription` | Save generated images to Photos |
| `NSPhotoLibraryUsageDescription` | Read photos for face swap input |
| `NSCameraUsageDescription` | Capture photos for face swap |
| `NSMicrophoneUsageDescription` | Record audio for video features |

See `PERMISSIONS_SETUP.md` for Xcode setup instructions.

---

## Documentation Files

| File | Contents |
|------|----------|
| `DEPLOYMENT.md` | Production environment setup and deployment steps |
| `PERMISSIONS_SETUP.md` | iOS permission keys and Xcode configuration |
| `SECURE_SETUP.md` | Security best practices for API key management |
| `QUICK_FIX_GUIDE.md` | Common setup problems and solutions |
| `IMAGE_SAVING_FIXES.md` | Notes on photo library save implementation |
| `UI_TEST_GUIDE.md` | Manual testing scenarios for all features |
| `CRASH_FIX_SUMMARY.md` | App stability improvements history |
| `HUONG_DAN_SU_DUNG.md` | Vietnamese-language usage guide |

---

## Common Tasks

### Add a new AI feature view
1. Create a new SwiftUI `View` file in `GeminiImageEditor/` (follow naming: `<Feature>View.swift`)
2. Inject `OpenAIService.shared` via `@StateObject`
3. Add the corresponding API method to `OpenAIService.swift`
4. Add a `FeatureCardView` entry in `ContentView.swift`
5. Add a `.sheet` presentation in `ContentView.swift`

### Add a new template
1. Open `ContentTemplates.swift`
2. Add a new entry to the appropriate template array following the existing struct format
3. No other changes needed — templates are loaded dynamically

### Change API key handling
1. Read `ENVLoader.swift`, `KeychainHelper.swift`, and `EnvironmentConfig.swift` first
2. Ensure any change preserves the three-layer priority: env var > .env file > Config.plist
3. Never log raw key values — always mask them

### Debug API issues
- Check `SettingsView` → "Test Connection" button to verify the API key is loaded
- Look for `✅`/`❌` console output from `OpenAIService`
- Ensure `OPENAI_API_KEY` is set in the environment before launch
