# ⚡ Quick Railway Setup (5 Minutes)

## 🚀 Fastest Way to Deploy

### 1. Go to Railway
👉 **https://railway.app** → Sign up/Login

### 2. Create Project
- Click **"New Project"**
- Choose **"Deploy from GitHub repo"** (if you have it on GitHub)
- OR **"Empty Project"** → **"Add Service"** → Upload `backend` folder

### 3. Add Environment Variables
In Railway dashboard → Your service → **"Variables"** tab:

Click **"New Variable"** three times and add:

```
MONGO_URI = mongodb+srv://foreverarmy06_db_user:hwPZoEnjUAdJc5dR@cluster0.mnr1o3e.mongodb.net/?appName=Cluster0
```

```
GEMINI_API_KEY = AIzaSyDKr21T_6YZtWYpxPjUZxALb9KOclTbvFM
```

```
PORT = 4000
```

### 4. Get Your URL
- Railway → Your service → **"Settings"** → **"Domains"**
- Click **"Generate Domain"**
- Copy the URL (e.g., `https://sprout-backend.up.railway.app`)

### 5. Update iOS App
Open `Sprout/ios/APIClient.swift` and change line 15:

**Before:**
```swift
self.baseURL = "http://localhost:4000"
```

**After:**
```swift
self.baseURL = "https://your-railway-url.up.railway.app"  // Your Railway URL
```

### 6. Test
- Open your Railway URL in browser → Should see `{"ok":true,...}`
- Run iOS app → Should connect to backend ✅

---

**That's it!** Your backend is now live and accessible from anywhere! 🎉

For detailed instructions, see `RAILWAY_DEPLOYMENT.md`

