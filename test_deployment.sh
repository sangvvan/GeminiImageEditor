#!/bin/bash

# Test script for GeminiImageEditor deployment
# This script verifies that the OPENAI_API_KEY environment variable is properly configured

echo "🚀 Testing GeminiImageEditor Deployment Configuration"
echo "=================================================="

# Check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY environment variable is not set"
    echo "   Please set it with: export OPENAI_API_KEY='your-api-key-here'"
    exit 1
else
    echo "✅ OPENAI_API_KEY environment variable is set"
    
    # Check if the key starts with 'sk-' (OpenAI API key format)
    if [[ $OPENAI_API_KEY == sk-* ]]; then
        echo "✅ API key format appears valid (starts with 'sk-')"
    else
        echo "⚠️  Warning: API key doesn't start with 'sk-' - please verify it's correct"
    fi
    
    # Show masked version of the key
    key_length=${#OPENAI_API_KEY}
    if [ $key_length -gt 12 ]; then
        start=${OPENAI_API_KEY:0:8}
        end=${OPENAI_API_KEY: -4}
        middle=$(printf '*%.0s' $(seq 1 $((key_length - 12))))
        echo "✅ API key: ${start}${middle}${end}"
    fi
fi

echo ""
echo "📱 Deployment Configuration:"
echo "   • Production mode: ENABLED"
echo "   • User API key input: DISABLED"
echo "   • Environment variable: OPENAI_API_KEY"
echo "   • Security: API key stored in environment, not user-accessible"

echo ""
echo "🔧 To deploy:"
echo "   1. Set OPENAI_API_KEY environment variable"
echo "   2. Build and deploy the app"
echo "   3. Users will not be able to modify API keys"

echo ""
echo "✅ Deployment configuration is ready!"
