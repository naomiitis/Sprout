# Fix Project Without Sudo/Admin Access

Since you don't have sudo access, here are alternatives:

## Option 1: Download XcodeGen Binary (No Installation Needed) ✅

This doesn't require sudo or installation:

```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios

# Download XcodeGen binary
curl -L https://github.com/yonaskolb/XcodeGen/releases/latest/download/xcodegen.zip -o xcodegen.zip

# Extract it
unzip xcodegen.zip

# Make it executable
chmod +x xcodegen/bin/xcodegen

# Use it to regenerate the project
./xcodegen/bin/xcodegen generate

# Open the project
open Sprout.xcodeproj
```

This downloads XcodeGen as a standalone binary - no installation needed!

---

## Option 2: Manual Fix in Xcode (Easiest) ✅

If you can open Xcode, this is the simplest:

### Step 1: Open Xcode
```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
open Sprout.xcodeproj
```

If it says "damaged", try:
```bash
open Sprout.xcodeproj/project.xcworkspace
```

### Step 2: Add Missing Files

1. In Xcode, right-click on the project root (left sidebar, "Sprout")
2. Select **"Add Files to Sprout..."**
3. Navigate to and select:
   - `ConfettiView.swift`
   - `PreferenceEditors.swift`
4. **IMPORTANT:**
   - ✅ Check "Add to targets: Sprout"
   - ❌ Uncheck "Copy items if needed"
5. Click "Add"

### Step 3: Remove Problem Files from Build

1. Select the project (top of left sidebar)
2. Select the "Sprout" target
3. Click "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Find and remove (click minus button):
   - Any `.yml` files
   - Any `.sh` files  
   - Any `.md` files
   - The `xcodegen` folder (if it appears)

### Step 4: Clean and Build

1. Press `⌘ShiftK` (Clean Build Folder)
2. Press `⌘B` (Build)

---

## Option 3: Install Homebrew to User Directory (No Sudo)

If you want to install Homebrew without sudo:

```bash
# Install Homebrew to your home directory
mkdir -p ~/homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew

# Add to your PATH (add this to ~/.zshrc)
echo 'export PATH="$HOME/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Then install XcodeGen
~/homebrew/bin/brew install xcodegen

# Use it
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
xcodegen generate
open Sprout.xcodeproj
```

---

## Recommended: Try Option 1 First

Option 1 (download XcodeGen binary) is the fastest and doesn't require any permissions. Just copy and paste those commands into Terminal.

