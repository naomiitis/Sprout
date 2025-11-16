#!/bin/bash

# Quick fix script for corrupted Xcode project
# This will attempt to regenerate the project using XcodeGen

set -e

cd "$(dirname "$0")"

echo "🔧 Attempting to fix Xcode project..."

# Check if XcodeGen is available
if command -v xcodegen &> /dev/null; then
    echo "✅ XcodeGen found, regenerating project..."
    xcodegen generate
    echo "✅ Project regenerated!"
    open Sprout.xcodeproj
    exit 0
fi

# Try to install XcodeGen via Homebrew
if command -v brew &> /dev/null; then
    echo "📦 Installing XcodeGen via Homebrew..."
    brew install xcodegen
    echo "✅ XcodeGen installed, regenerating project..."
    xcodegen generate
    echo "✅ Project regenerated!"
    open Sprout.xcodeproj
    exit 0
fi

# If we get here, XcodeGen is not available
echo "❌ XcodeGen is not installed and Homebrew is not available."
echo ""
echo "Please choose one of these options:"
echo ""
echo "1. Install Homebrew first:"
echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
echo "   Then run this script again."
echo ""
echo "2. Download XcodeGen manually:"
echo "   Visit: https://github.com/yonaskolb/XcodeGen/releases"
echo "   Download the latest release and extract it."
echo "   Then run: ./xcodegen generate"
echo ""
echo "3. Manually add files in Xcode:"
echo "   - Try opening: Sprout.xcodeproj/project.xcworkspace"
echo "   - Add ConfettiView.swift and PreferenceEditors.swift manually"
echo "   - See FIX_PROJECT.md for detailed instructions"

exit 1

