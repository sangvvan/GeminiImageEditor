#!/bin/bash

# Simple script to run the MakeIt app
# This will automatically load API keys from .env file

echo "🚀 Starting MakeIt App"
echo "======================"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "Please create a .env file with your API keys:"
    echo "OPENAI_API_KEY=your_api_key_here"
    exit 1
fi

# Copy .env file to app bundle so it can be read
echo "📄 Copying .env file to app bundle..."
cp .env GeminiImageEditor/

# Open Xcode project
echo "📱 Opening Xcode project..."
open GeminiImageEditor.xcodeproj

echo ""
echo "✅ App ready to run!"
echo ""
echo "💡 The app will now automatically load your API key from the .env file"
echo "   No need to set environment variables manually!"
echo ""
echo "🎯 To run:"
echo "   1. Build and run from Xcode"
echo "   2. Settings will show 'Production Mode'"
echo "   3. Image generation will work automatically"
