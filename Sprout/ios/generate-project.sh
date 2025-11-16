#!/bin/bash

# Script to generate Xcode project using XcodeGen

set -e

echo "🌱 Generating Xcode project for Sprout..."

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "❌ XcodeGen is not installed."
    echo "📦 Installing XcodeGen..."
    
    if command -v brew &> /dev/null; then
        brew install xcodegen
    else
        echo "❌ Homebrew is not installed. Please install XcodeGen manually:"
        echo "   https://github.com/yonaskolb/XcodeGen"
        exit 1
    fi
fi

# Navigate to ios directory
cd "$(dirname "$0")"

# Generate the project
echo "🔨 Generating project..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ Project generated successfully!"
    echo "📂 Opening Sprout.xcodeproj..."
    open Sprout.xcodeproj
else
    echo "❌ Failed to generate project. Please check the error messages above."
    exit 1
fi

