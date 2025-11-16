# Manual Fix for Xcode Project

Since XcodeGen isn't installed, here's how to manually fix the project:

## Step 1: Clean the Build

1. Open Xcode
2. Press `⌘ShiftK` (Clean Build Folder)
3. Close Xcode

## Step 2: Remove Derived Data

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Sprout-*
```

## Step 3: Open Project in Xcode

Try opening the project:
```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
open Sprout.xcodeproj
```

If it still says corrupted, try:
```bash
open Sprout.xcodeproj/project.xcworkspace
```

## Step 4: Add Missing Files

If the project opens, add these files manually:

### Add ConfettiView.swift:
1. In Xcode, right-click on the project root (left sidebar)
2. Select "Add Files to Sprout..."
3. Navigate to `ios/ConfettiView.swift`
4. **IMPORTANT:** 
   - Uncheck "Copy items if needed"
   - Check "Add to targets: Sprout"
5. Click "Add"

### Add PreferenceEditors.swift:
1. Repeat the same process for `ios/PreferenceEditors.swift`

## Step 5: Remove Problematic Files from Build

If you see errors about duplicate files:

1. In Xcode, select the project (top of left sidebar)
2. Select the "Sprout" target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Find and remove any `.yml`, `.yaml`, `.sh`, or `.md` files
6. Also remove the `xcodegen` folder if it appears

## Step 6: Clean and Rebuild

1. Press `⌘ShiftK` (Clean)
2. Press `⌘B` (Build)

---

## Alternative: Install XcodeGen (Recommended)

If you can install XcodeGen, it will automatically fix everything:

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Regenerate project
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
xcodegen generate
open Sprout.xcodeproj
```

This will create a clean project with all files properly included.

