# 🚂 Railway Deployment Guide

Deploy your Sprout backend to Railway (no Node.js installation needed!)

## Step-by-Step Instructions

### Step 1: Sign Up for Railway

1. Go to **https://railway.app**
2. Click **"Start a New Project"** or **"Login"**
3. Sign up with GitHub (recommended) or email

### Step 2: Create New Project

1. Click **"New Project"**
2. Choose one of these options:

   **Option A: Deploy from GitHub (Recommended)**
   - Click **"Deploy from GitHub repo"**
   - Select your repository
   - Railway will auto-detect it's a Node.js app

   **Option B: Deploy from Local Files**
   - Click **"Empty Project"**
   - Click **"Add Service"** → **"GitHub Repo"** or **"Local Directory"**
   - Upload the `backend` folder

### Step 3: Configure Environment Variables

1. In your Railway project, click on the service
2. Go to **"Variables"** tab
3. Click **"New Variable"** and add these three:

   ```
   MONGO_URI = mongodb+srv://foreverarmy06_db_user:hwPZoEnjUAdJc5dR@cluster0.mnr1o3e.mongodb.net/?appName=Cluster0
   ```

   ```
   GEMINI_API_KEY = AIzaSyDKr21T_6YZtWYpxPjUZxALb9KOclTbvFM
   ```

   ```
   PORT = 4000
   ```

4. Click **"Save"** after each variable

### Step 4: Deploy

1. Railway will automatically:
   - Detect it's a Node.js project
   - Run `npm install`
   - Run `npm start`
2. Wait for deployment to complete (usually 1-2 minutes)
3. You'll see logs showing:
   ```
   MongoDB connected
   Server listening on 4000
   ```

### Step 5: Get Your Backend URL

1. In Railway, click on your service
2. Go to **"Settings"** tab
3. Scroll down to **"Domains"**
4. Click **"Generate Domain"** (or use the default one)
5. Copy the URL (e.g., `https://sprout-backend-production.up.railway.app`)

### Step 6: Update iOS App

Update `APIClient.swift` to use your Railway URL:

1. Open `Sprout/ios/APIClient.swift`
2. Find line 15 (inside the `init()` function)
3. Replace `http://localhost:4000` with your Railway URL:

```swift
init() {
    #if DEBUG
    self.baseURL = "https://your-app-name.up.railway.app"  // Your Railway URL here
    #else
    self.baseURL = "https://your-production-url.com"
    #endif
    self.session = URLSession.shared
}
```

**Important:** Make sure the URL starts with `https://` (Railway provides HTTPS automatically)

### Step 7: Test the Deployment

1. Open your Railway URL in a browser
2. You should see: `{"ok":true,"msg":"Veganify backend (Albert focus) running"}`
3. If you see this, your backend is working! ✅

### Step 8: Test from iOS App

1. Build and run your iOS app
2. The app should now connect to your Railway backend
3. Try completing onboarding - it should work!

## Troubleshooting

### Issue: "Build failed"
- **Solution:** Check Railway logs. Make sure `package.json` has a `start` script (it does: `"start": "node server.js"`)

### Issue: "MongoDB connection error"
- **Solution:** 
  - Verify `MONGO_URI` is correct in Railway variables
  - Make sure MongoDB Atlas allows connections from anywhere (IP whitelist: `0.0.0.0/0`)

### Issue: "Cannot connect from iOS app"
- **Solution:**
  - Make sure you're using `https://` not `http://`
  - Check that the Railway URL is correct in `APIClient.swift`
  - Verify the backend is running (check Railway logs)

### Issue: "CORS error"
- **Solution:** The backend already has CORS enabled. If issues persist, check Railway logs.

## Railway Free Tier Limits

- **$5 free credit per month** (usually enough for development)
- **Automatic HTTPS** (no SSL setup needed)
- **Auto-deploys** on git push (if connected to GitHub)

## Next Steps

Once deployed:
1. Your backend will be accessible 24/7
2. You can access it from anywhere (not just localhost)
3. The iOS app will work on physical devices without needing your computer's IP
4. Railway will auto-restart if the server crashes

## Quick Reference

- **Railway Dashboard:** https://railway.app/dashboard
- **Your Backend URL:** Check in Railway → Settings → Domains
- **Environment Variables:** Railway → Variables tab
- **Logs:** Railway → Deployments → Click on deployment → View logs

