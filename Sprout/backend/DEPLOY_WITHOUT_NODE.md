# Deploy Backend Without Installing Node.js Locally

You can deploy the backend to a cloud service that runs Node.js for you. Here are free options:

## Option 1: Railway (Recommended - Easiest)

1. **Sign up:** Go to https://railway.app (free tier available)
2. **Create new project:**
   - Click "New Project"
   - Select "Deploy from GitHub repo" (or upload the backend folder)
3. **Add environment variables:**
   - In Railway dashboard, go to "Variables" tab
   - Add:
     - `MONGO_URI` = your MongoDB connection string
     - `GEMINI_API_KEY` = your Gemini API key
     - `PORT` = 4000 (or leave default)
4. **Deploy:**
   - Railway will automatically detect it's a Node.js app
   - It will run `npm install` and `npm start` automatically
5. **Get your URL:**
   - Railway will give you a URL like: `https://your-app.railway.app`
   - Update `APIClient.swift` line 15 to use this URL instead of localhost

## Option 2: Render (Free Tier)

1. **Sign up:** Go to https://render.com (free tier available)
2. **Create new Web Service:**
   - Connect your GitHub repo or upload the backend folder
   - Select "Node" as the environment
3. **Configure:**
   - Build Command: `npm install`
   - Start Command: `npm start`
4. **Add environment variables:**
   - In Render dashboard, add:
     - `MONGO_URI`
     - `GEMINI_API_KEY`
     - `PORT` = 4000
5. **Deploy:**
   - Render will deploy automatically
   - You'll get a URL like: `https://your-app.onrender.com`

## Option 3: Use Cloud IDE (Replit/CodeSandbox)

1. **Replit:**
   - Go to https://replit.com
   - Create new "Node.js" repl
   - Upload your backend files
   - Add environment variables in Secrets tab
   - Click "Run" - it will start automatically
   - Get your URL from the repl

2. **CodeSandbox:**
   - Go to https://codesandbox.io
   - Create new "Node.js" sandbox
   - Upload backend files
   - Add environment variables
   - Get the preview URL

## Option 4: Use iOS App in DEBUG Mode (Limited)

The iOS app already has fallback code for when the backend isn't available:
- Onboarding will work (creates local profile)
- Grocery list will work locally
- But API features (scanning, recipes, etc.) won't work

This is already implemented in the code with `#if DEBUG` blocks.

## Update iOS App to Use Cloud URL

After deploying to cloud, update `APIClient.swift`:

```swift
init() {
    #if DEBUG
    // Use your cloud URL instead of localhost
    self.baseURL = "https://your-app.railway.app"  // or your Render/Replit URL
    #else
    self.baseURL = "https://your-production-url.com"
    #endif
    self.session = URLSession.shared
}
```

## Quick Start with Railway (Fastest)

1. Install Railway CLI (optional but easier):
   ```bash
   curl -fsSL https://railway.app/install.sh | sh
   ```

2. Or just use the web interface:
   - Go to railway.app
   - Click "New Project"
   - "Deploy from GitHub" or "Empty Project" and upload files
   - Add environment variables
   - Done!

