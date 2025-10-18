#!/bin/bash

# Setup Environment Variables for MakeIt App
# This script helps you set up secure environment variables for development

echo "🔧 Setting up environment variables for MakeIt App"
echo "=================================================="

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# OpenAI API Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Environment Configuration
ENVIRONMENT=development
DEBUG_MODE=true
SECURE_STORAGE=true

# Optional: Other API Keys
# GEMINI_API_KEY=your_gemini_api_key_here
# ANTHROPIC_API_KEY=your_anthropic_api_key_here
EOF
    echo "✅ Created .env file"
else
    echo "📄 .env file already exists"
fi

# Create .gitignore entry for .env
if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore file..."
    cat > .gitignore << EOF
# Environment variables
.env
*.env

# API Keys and Secrets
*.key
*.pem
secrets.plist
config.json

# Xcode
.DS_Store
*.xcuserstate
*.xcworkspace/xcuserdata/
DerivedData/
build/

# iOS
*.ipa
*.dSYM.zip
EOF
    echo "✅ Created .gitignore file"
else
    # Check if .env is already in .gitignore
    if ! grep -q "\.env" .gitignore; then
        echo "" >> .gitignore
        echo "# Environment variables" >> .gitignore
        echo ".env" >> .gitignore
        echo "*.env" >> .gitignore
        echo "✅ Added .env to .gitignore"
    fi
fi

echo ""
echo "📋 Next Steps:"
echo "1. Edit the .env file and add your actual API keys"
echo "2. Never commit the .env file to version control"
echo "3. For production, set environment variables on your deployment platform"
echo ""
echo "🔐 Security Notes:"
echo "- The .env file is now in .gitignore and won't be committed"
echo "- API keys will be loaded from environment variables"
echo "- Keys are stored securely in iOS Keychain"
echo ""
echo "🚀 To use environment variables in Xcode:"
echo "1. Open Xcode project settings"
echo "2. Go to Build Settings"
echo "3. Add environment variables in 'Preprocessor Macros' or 'Other Swift Flags'"
echo ""
echo "✅ Setup complete! Remember to add your actual API keys to .env"
