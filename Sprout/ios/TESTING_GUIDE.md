# Sprout iOS App - Testing Guide

## 🚀 Quick Start

### 1. Open the Project in Xcode

```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
open Sprout.xcodeproj
```

**OR** if you need to regenerate the project (if XcodeGen is installed):
```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
./generate-project.sh
```

### 2. Select a Simulator
- In Xcode, click the device selector (top toolbar)
- Choose an iOS Simulator (recommended: **iPhone 15 Pro** or **iPhone 15**)
- Make sure it's running iOS 16.0 or later

### 3. Build and Run
- Press `⌘R` (Command + R) or click the Play button
- Wait for the app to build and launch in the simulator

---

## ✅ Testing the New Features

### 1. Confetti Animations for Mission Completion

**Steps:**
1. Complete onboarding (if first time)
2. Go to **Home** tab
3. Tap **"Daily Missions"** button
4. Find an incomplete mission
5. Tap **"Complete"** button
6. **Expected:** Confetti animation appears and falls from top to bottom
7. **Expected:** Confetti disappears after 1.5 seconds
8. **Expected:** Mission shows as completed with checkmark

**What to verify:**
- ✅ Confetti particles are visible (green, yellow, orange colors)
- ✅ Animation is smooth
- ✅ Confetti doesn't block interaction (allowsHitTesting = false)
- ✅ Mission status updates correctly

---

### 2. Scan Receipt Functionality

**Steps:**
1. Go to **Cook** tab
2. Tap the **🛒 (cart)** icon in the top right
3. In Grocery List, you'll see two buttons:
   - **"Scan Receipt"** (camera icon)
   - **"Upload Receipt"** (photo library icon)
4. Tap **"Scan Receipt"** or **"Upload Receipt"**
5. Take/select a photo of a receipt
6. **Expected:** Image picker opens
7. **Expected:** After selecting image, it processes
8. **Expected:** Items from receipt appear in grocery list (categorized)

**What to verify:**
- ✅ Both buttons are visible
- ✅ Camera permission is requested (if using camera)
- ✅ Photo library permission is requested (if using library)
- ✅ Image picker works correctly
- ✅ Items are added to grocery list after scanning
- ✅ Items are properly categorized

**Note:** This requires the backend API to be running. Make sure your backend is running on `http://localhost:4000` (or update the baseURL in `APIClient.swift`).

---

### 3. Recent Scans Carousel

**Steps:**
1. Go to **Scan** tab
2. **First time:** You won't see recent scans (empty state)
3. Scan an ingredient list or menu:
   - Tap **"Take a Photo"** or **"Upload Image"**
   - Select/take a photo
   - Wait for scan results
4. **Expected:** After scanning, go back to empty state
5. **Expected:** You'll now see a **"Recent Scans"** section at the top
6. **Expected:** Horizontal carousel shows your recent scan(s)
7. Tap on a recent scan card
8. **Expected:** That scan's image and results reload

**What to verify:**
- ✅ "Recent Scans" section appears after first scan
- ✅ Carousel scrolls horizontally
- ✅ Shows thumbnail images (120x120)
- ✅ Shows scan type (Ingredients/Menu) with icon
- ✅ Tapping a card reloads that scan
- ✅ Maximum 10 recent scans are kept (oldest removed)

**Test multiple scans:**
- Scan 3-4 different images
- Verify all appear in carousel
- Verify they're in reverse chronological order (newest first)

---

### 4. Settings Preference Editors

**Steps:**

#### A. Eating Style Editor
1. Go to **Settings** tab
2. Under **"Adjust Preferences"**, tap **"Eating Style (Vegan Level)"**
3. **Expected:** Editor opens showing all 6 eating styles
4. **Expected:** Current selection is highlighted
5. Select a different eating style
6. Tap **"Save Changes"**
7. **Expected:** Returns to Settings
8. **Expected:** Profile is updated (verify by checking again)

#### B. Dietary Restrictions Editor
1. In Settings, tap **"Dietary Restrictions"**
2. **Expected:** Shows predefined chips (gluten-free, nut-free, etc.)
3. **Expected:** Shows current selections highlighted
4. Tap chips to select/deselect
5. **Test AI parsing:**
   - Type in free text: "allergic to peanuts, avoid palm oil"
   - Tap the sparkles (✨) button
   - **Expected:** AI parses and adds restrictions
6. Tap **"Save Changes"**
7. **Expected:** Changes are saved

#### C. Cuisine Preferences Editor
1. In Settings, tap **"Cuisine Preferences"**
2. **Expected:** Grid of all cuisines (Korean, Japanese, etc.)
3. **Expected:** Current selections highlighted
4. Tap multiple cuisines to select/deselect
5. Tap **"Save Changes"**
6. **Expected:** Changes are saved

#### D. Cooking Style Preferences Editor
1. In Settings, tap **"Cooking Style Preferences"**
2. **Expected:** Grid of all cooking styles
3. **Expected:** Current selections highlighted
4. Tap multiple styles to select/deselect
5. Tap **"Save Changes"**
6. **Expected:** Changes are saved

**What to verify:**
- ✅ All 4 editors open correctly
- ✅ Current preferences are loaded and displayed
- ✅ Selection/deselection works
- ✅ Save button is enabled when changes are made
- ✅ Changes persist after saving
- ✅ Navigation back to Settings works
- ✅ AI parsing works in Dietary Restrictions editor

---

## 🐛 Troubleshooting

### Build Errors

**"No such module" errors:**
- Clean build folder: `⌘ShiftK` (Command + Shift + K)
- Rebuild: `⌘B` (Command + B)

**Missing files:**
- Make sure all new files are added to the target:
  - `ConfettiView.swift`
  - `PreferenceEditors.swift`
- Check in Xcode: Select file → File Inspector → Target Membership → ✅ Sprout

### Runtime Issues

**Confetti not showing:**
- Check that `ConfettiView.swift` is in the project
- Verify the ZStack in `MissionsView` is set up correctly

**Scan Receipt not working:**
- Check backend is running
- Verify API endpoint `/grocery-list/scan-receipt` exists
- Check network permissions in Info.plist

**Recent Scans not appearing:**
- Make sure you've completed at least one scan
- Check that `recentScans` array is being populated in ViewModel

**Preference Editors not saving:**
- Check backend API is running
- Verify `/profile` PATCH endpoint works
- Check console for error messages

### Backend Connection

**If backend is not running:**
- The app will fail API calls
- Update `APIClient.swift` baseURL if needed
- Default: `http://localhost:4000` (for simulator)
- For physical device: Use your Mac's IP address

---

## 📱 Testing Checklist

### Confetti Animations
- [ ] Confetti appears on mission completion
- [ ] Animation is smooth
- [ ] Confetti disappears after 1.5s
- [ ] Mission status updates correctly

### Scan Receipt
- [ ] "Scan Receipt" button visible
- [ ] "Upload Receipt" button visible
- [ ] Camera permission requested
- [ ] Photo library permission requested
- [ ] Image picker works
- [ ] Items added to grocery list after scan

### Recent Scans
- [ ] Carousel appears after first scan
- [ ] Shows correct thumbnails
- [ ] Shows scan type (Ingredients/Menu)
- [ ] Tapping card reloads scan
- [ ] Maximum 10 scans kept

### Preference Editors
- [ ] Eating Style editor opens
- [ ] Dietary Restrictions editor opens
- [ ] Cuisine Preferences editor opens
- [ ] Cooking Style editor opens
- [ ] Current preferences loaded
- [ ] Changes can be made
- [ ] Save button works
- [ ] Changes persist
- [ ] AI parsing works in Dietary Restrictions

---

## 🎯 Quick Test Flow

1. **First Launch:**
   - Complete onboarding
   - Verify userId is stored

2. **Home Tab:**
   - Complete a mission → See confetti
   - Check streak and XP

3. **Scan Tab:**
   - Scan an ingredient list
   - Verify recent scans carousel appears
   - Tap a recent scan → Reloads

4. **Grocery List:**
   - Open from Cook tab
   - Scan a receipt
   - Verify items added

5. **Settings:**
   - Edit each preference type
   - Verify changes save
   - Test AI parsing in Dietary Restrictions

---

## 💡 Tips

- Use **iPhone 15 Pro** simulator for best experience
- Enable **Slow Animations** in simulator (Debug → Slow Animations) to see confetti better
- Check **Console** (⌘⇧Y) for any error messages
- Test on **physical device** for camera functionality
- Make sure **backend is running** for API-dependent features

---

## 🔗 Related Files

- `ConfettiView.swift` - Confetti animation
- `PreferenceEditors.swift` - All preference editors
- `GroceryListView.swift` - Receipt scanning
- `ScanView.swift` - Recent scans carousel
- `HomeView.swift` - Mission completion with confetti
- `SettingsView.swift` - Navigation to editors

