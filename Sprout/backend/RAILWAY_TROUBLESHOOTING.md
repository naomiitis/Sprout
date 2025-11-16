# 🔧 Railway Deployment Troubleshooting

## Common Issues and Fixes

### Issue 1: "Build Failed" or "Deployment Error"

**Check Railway Logs:**
1. Go to Railway dashboard
2. Click on your service
3. Click on the failed deployment
4. Check the "Build Logs" and "Deploy Logs"

**Common Causes:**

#### A. Top-level await issue
If you see: `SyntaxError: await is only valid in async functions`

**Fix:** Add Node.js version to `package.json`:
```json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

#### B. Missing dependencies
If you see: `Cannot find module 'express'` or similar

**Fix:** Make sure `package.json` has all dependencies listed (it does)

#### C. Wrong root directory
If Railway can't find `package.json`

**Fix:** In Railway → Settings → Root Directory, set to: `backend` (if deploying from repo root)

---

### Issue 2: "MongoDB Connection Error"

**Symptoms:**
- Deployment succeeds but app crashes
- Logs show: `MongoServerError` or `MongooseError`

**Fixes:**

1. **Check MONGO_URI in Railway Variables:**
   - Go to Railway → Variables
   - Verify `MONGO_URI` is exactly:
     ```
     mongodb+srv://foreverarmy06_db_user:hwPZoEnjUAdJc5dR@cluster0.mnr1o3e.mongodb.net/?appName=Cluster0
     ```
   - No extra spaces or quotes

2. **Check MongoDB Atlas IP Whitelist:**
   - Go to MongoDB Atlas → Network Access
   - Add IP: `0.0.0.0/0` (allows from anywhere)
   - Or add Railway's IP ranges

3. **Check MongoDB Atlas Database User:**
   - Verify the user `foreverarmy06_db_user` exists
   - Verify the password is correct

---

### Issue 3: "Port Already in Use" or "EADDRINUSE"

**Fix:** Railway sets PORT automatically. Make sure your code uses:
```javascript
const PORT = process.env.PORT || 4000;
```
(Your code already does this ✅)

---

### Issue 4: "Module Not Found" Errors

**Symptoms:**
- `Cannot find module './routes/scanIngredients.js'`
- Import errors

**Fixes:**

1. **Check file extensions:**
   - Make sure all imports use `.js` extension (your code does ✅)

2. **Check package.json type:**
   - Should have `"type": "module"` (it does ✅)

3. **Verify all route files exist:**
   - Check that all imported routes exist in `routes/` folder

---

### Issue 5: "GEMINI_API_KEY not found"

**Fix:**
1. Go to Railway → Variables
2. Add `GEMINI_API_KEY` with value: `AIzaSyDKr21T_6YZtWYpxPjUZxALb9KOclTbvFM`
3. Make sure there are no spaces or quotes

---

### Issue 6: Deployment Hangs or Times Out

**Possible Causes:**

1. **MongoDB connection taking too long:**
   - Check MongoDB Atlas is accessible
   - Verify network access settings

2. **Large dependencies (tesseract.js):**
   - Railway might need more time for `npm install`
   - Wait 3-5 minutes for first deployment

**Fix:** Be patient on first deployment. Subsequent deployments are faster.

---

### Issue 7: "Cannot GET /" or 404 Errors

**Symptoms:**
- Deployment succeeds
- But visiting the URL shows 404 or error

**Fix:**
1. Check Railway logs to see if server started
2. Verify the root route exists in `server.js` (it does ✅)
3. Make sure you're using the correct Railway domain URL

---

## How to Get Detailed Error Messages

1. **In Railway Dashboard:**
   - Click on your service
   - Click on the deployment (failed or latest)
   - Check "Build Logs" tab
   - Check "Deploy Logs" tab
   - Look for red error messages

2. **Common Error Patterns:**
   - `Error: Cannot find module` → Missing dependency
   - `SyntaxError` → Code syntax issue
   - `MongoServerError` → Database connection issue
   - `EADDRINUSE` → Port conflict
   - `ENOENT` → Missing file

---

## Quick Fixes Checklist

- [ ] Added `"engines": { "node": ">=18.0.0" }` to package.json
- [ ] Set Root Directory to `backend` (if deploying from repo root)
- [ ] Added all 3 environment variables (MONGO_URI, GEMINI_API_KEY, PORT)
- [ ] Verified MongoDB Atlas IP whitelist includes `0.0.0.0/0`
- [ ] Checked Railway logs for specific error messages
- [ ] Verified all route files exist in `routes/` folder

---

## Still Not Working?

**Share these details:**
1. The exact error message from Railway logs
2. Which step failed (Build or Deploy)
3. Screenshot of Railway logs (if possible)

Then I can provide a specific fix!

