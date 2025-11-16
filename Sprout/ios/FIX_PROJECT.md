# Fixing Corrupted Xcode Project

The project file is corrupted. Here are solutions to fix it:

## Solution 1: Install XcodeGen and Regenerate (Recommended)

### Option A: Install Homebrew first, then XcodeGen

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install XcodeGen
brew install xcodegen

# Regenerate the project
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
./generate-project.sh
```

### Option B: Install XcodeGen via Mint (no Homebrew needed)

```bash
# Install Mint (Swift package manager)
git clone https://github.com/yonaskolb/Mint.git
cd Mint
swift build -c release
sudo mv .build/release/mint /usr/local/bin/

# Install XcodeGen via Mint
mint install yonaskolb/XcodeGen

# Regenerate the project
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
xcodegen generate
open Sprout.xcodeproj
```

### Option C: Download XcodeGen Binary Directly

```bash
# Download latest release
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
curl -L https://github.com/yonaskolb/XcodeGen/releases/latest/download/xcodegen.zip -o xcodegen.zip
unzip xcodegen.zip
chmod +x xcodegen/bin/xcodegen

# Use it to generate
./xcodegen/bin/xcodegen generate
open Sprout.xcodeproj
```

---

## Solution 2: Manual Fix in Xcode (If project opens)

If you can open the project in Xcode (even with errors), manually add the new files:

### Steps:

1. **Open Xcode** (try opening the workspace instead: `Sprout.xcodeproj/project.xcworkspace`)

2. **Add ConfettiView.swift:**
   - Right-click on the project navigator (left sidebar)
   - Select "Add Files to Sprout..."
   - Navigate to `ios/ConfettiView.swift`
   - Make sure "Copy items if needed" is UNCHECKED
   - Make sure "Add to targets: Sprout" is CHECKED
   - Click "Add"

3. **Add PreferenceEditors.swift:**
   - Repeat the same process for `ios/PreferenceEditors.swift`

4. **Clean and Rebuild:**
   - Press `⌘ShiftK` (Clean Build Folder)
   - Press `⌘B` (Build)

---

## Solution 3: Quick Fix Script

Run this script to try to fix the project file:

```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios

# Backup the corrupted project
cp -r Sprout.xcodeproj Sprout.xcodeproj.backup

# Try to open in Xcode and let it repair
open Sprout.xcodeproj/project.xcworkspace
```

Then manually add the files as described in Solution 2.

---

## Solution 4: Recreate Project from Scratch (Last Resort)

If nothing else works, we can create a new Xcode project and add all files. This is more time-consuming but guaranteed to work.

---

## Recommended: Quick XcodeGen Install

The fastest way is to install XcodeGen. Here's a one-liner:

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Fix the project
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
./generate-project.sh
```

This will regenerate a clean project file with all your Swift files included.

