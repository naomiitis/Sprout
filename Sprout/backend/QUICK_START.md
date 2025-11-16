# 🚀 Quick Start Guide

## Option 1: Automatic Setup (Recommended)

If you have your API keys ready, run:

```bash
# In the backend directory
node setup.js MONGO_URI="your_mongodb_uri" GEMINI_API_KEY="your_api_key"
```

This will create the `.env` file automatically.

## Option 2: Manual Setup

1. **Copy the template:**
   ```bash
   cp .env.template .env
   ```

2. **Edit `.env` file** and add your values:
   ```env
   MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/sprout
   GEMINI_API_KEY=your_actual_api_key_here
   PORT=4000
   ```

## Getting Your API Keys

### MongoDB URI:
1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free account and cluster
3. Click "Connect" → "Connect your application
4. Copy the connection string
5. Replace `<password>` with your database password

### Gemini API Key:
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google
3. Click "Create API Key"
4. Copy the key

## Start the Backend

```bash
npm install  # First time only
npm start    # Start the server
```

The server will run on http://localhost:4000

## Test the Connection

Open in browser: http://localhost:4000

Should see: `{"ok":true,"msg":"Veganify backend (Albert focus) running"}`

## iOS App

The iOS app is already configured to connect to `http://localhost:4000`

- **iOS Simulator:** Works automatically
- **Physical Device:** Update `APIClient.swift` line 15 with your computer's IP address

