#!/bin/bash

# Start MakeIt App with Environment Variables
# This script loads your API keys and starts the app

echo "🚀 Starting MakeIt App with API Configuration"
echo "=============================================="

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
    echo "✅ Environment variables loaded"
else
    echo "⚠️  No .env file found. Please run ./setup_environment.sh first"
    exit 1
fi

# Verify API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY not found in environment"
    echo "Please check your .env file and make sure it contains:"
    echo "OPENAI_API_KEY=your_actual_api_key_here"
    exit 1
fi

# Test the configuration
echo "🔧 Testing configuration..."
./test_deployment.sh

echo ""
echo "📱 Starting the app..."
echo "The app will now run with your API key configured!"
echo ""

# Open Xcode and run the project
open GeminiImageEditor.xcodeproj

echo "✅ App started! You can now build and run from Xcode."
echo ""
echo "💡 Tips:"
echo "- The app will automatically use your API key"
echo "- Settings will show 'Production Mode' status"
echo "- Users cannot modify API keys in production mode"
