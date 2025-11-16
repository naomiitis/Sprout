# ⚡ Railway Quick Fix Guide

## What Error Did You See?

### 🔴 "Build Failed" or "Deployment Error"

**Most Common Fix - Add Node.js Version:**

I've already updated `package.json` to specify Node.js version. Now:

1. **In Railway Dashboard:**
   - Go to your service
   - Click **"Settings"** tab
   - Scroll to **"Build & Deploy"**
   - Make sure **"Root Directory"** is set correctly:
     - If you uploaded the `backend` folder directly: Leave empty or set to `.`
     - If deploying from repo root: Set to `backend`

2. **Redeploy:**
   - Click **"Redeploy"** button
   - Or push a new commit if connected to GitHub

---

### 🔴 "MongoDB Connection Error"

**Fix:**

1. **Check Environment Variables:**
   - Railway → Your service → **"Variables"** tab
   - Make sure you have exactly these 3 variables (no quotes, no spaces):
   
   ```
   MONGO_URI=mongodb+srv://foreverarmy06_db_user:hwPZoEnjUAdJc5dR@cluster0.mnr1o3e.mongodb.net/?appName=Cluster0
   ```
   
   ```
   GEMINI_API_KEY=AIzaSyDKr21T_6YZtWYpxPjUZxALb9KOclTbvFM
   ```
   
   ```
   PORT=4000
   ```

2. **Check MongoDB Atlas:**
   - Go to https://cloud.mongodb.com
   - Network Access → Add IP Address
   - Add: `0.0.0.0/0` (allows from anywhere)
   - Save

3. **Redeploy** after fixing variables

---

### 🔴 "Cannot find module" or Import Errors

**Fix:**

1. **Check Root Directory:**
   - Railway → Settings → Root Directory
   - Should be: `backend` (if deploying from repo)
   - Or: `.` (if uploaded backend folder directly)

2. **Verify all files uploaded:**
   - Make sure all route files exist
   - Check that `server.js` is in the root of the deployed folder

---

### 🔴 "Port Already in Use"

**Fix:**

This shouldn't happen, but if it does:
- Railway sets PORT automatically
- Your code already uses `process.env.PORT || 4000` ✅
- Just remove the `PORT=4000` variable from Railway (Railway sets it automatically)

---

## Step-by-Step Fix Process

### 1. Check Railway Logs

1. Go to Railway dashboard
2. Click on your service
3. Click on the **failed deployment** (red X)
4. Check **"Build Logs"** tab
5. Check **"Deploy Logs"** tab
6. **Copy the exact error message**

### 2. Common Error Messages & Fixes

| Error Message | Fix |
|--------------|-----|
| `SyntaxError: await is only valid` | ✅ Fixed - Added Node.js version to package.json |
| `Cannot find module 'express'` | Check Root Directory is set correctly |
| `MongoServerError` | Fix MONGO_URI variable or MongoDB Atlas IP whitelist |
| `GEMINI_API_KEY not found` | Add GEMINI_API_KEY to Railway variables |
| `ENOENT: no such file` | Check Root Directory setting |
| `EADDRINUSE` | Remove PORT variable (Railway sets it automatically) |

### 3. Verify Settings

**In Railway Dashboard:**

- [ ] **Root Directory:** Set to `backend` (if from repo) or `.` (if direct upload)
- [ ] **Environment Variables:** All 3 variables added (MONGO_URI, GEMINI_API_KEY, PORT)
- [ ] **Node.js Version:** Should auto-detect from package.json (now has `engines` field)

### 4. Redeploy

After making changes:
- Click **"Redeploy"** button in Railway
- Or if connected to GitHub, push a new commit

---

## Still Not Working?

**Share these details:**

1. **The exact error message** from Railway logs (copy/paste)
2. **Which tab shows the error:** Build Logs or Deploy Logs?
3. **Screenshot** of the error (if possible)

Then I can provide a specific fix!

---

## Alternative: Try Render Instead

If Railway continues to have issues, try **Render** (similar free service):

1. Go to https://render.com
2. Create new **Web Service**
3. Connect GitHub repo or upload files
4. Set:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** Node
5. Add same 3 environment variables
6. Deploy

Render sometimes works better for Node.js apps with top-level await.

