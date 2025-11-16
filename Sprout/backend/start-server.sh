#!/bin/bash

# Start Backend Server Script

echo "🚀 Starting Sprout Backend Server..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed or not in PATH"
    echo ""
    echo "Please install Node.js:"
    echo "1. Download from https://nodejs.org/ (LTS version)"
    echo "2. Or use nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo ""
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Please create a .env file with MONGO_URI, GEMINI_API_KEY, and PORT"
    exit 1
fi

echo "✅ .env file found"
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
    echo "✅ Dependencies installed"
    echo ""
fi

# Start the server
echo "🌱 Starting server on http://localhost:4000"
echo "Press Ctrl+C to stop the server"
echo ""

npm start

