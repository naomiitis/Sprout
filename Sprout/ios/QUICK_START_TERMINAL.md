# Quick Start - Terminal Commands

Copy and paste these commands into your Terminal, one at a time:

## Step 1: Install Homebrew (if you don't have it)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Note:** This will ask for your password. Type it and press Enter.

## Step 2: Install XcodeGen

```bash
brew install xcodegen
```

## Step 3: Navigate to the project and regenerate it

```bash
cd /Users/nkim31/Downloads/Sprout/Sprout/ios
xcodegen generate
```

## Step 4: Open the project in Xcode

```bash
open Sprout.xcodeproj
```

---

## All-in-One Command (if Homebrew is already installed)

If you already have Homebrew, you can run this:

```bash
brew install xcodegen && cd /Users/nkim31/Downloads/Sprout/Sprout/ios && xcodegen generate && open Sprout.xcodeproj
```

---

## What to expect:

1. **Homebrew installation:** Takes 2-5 minutes, asks for password
2. **XcodeGen installation:** Takes 1-2 minutes
3. **Project generation:** Takes 5-10 seconds
4. **Xcode opens:** Project should open automatically

After Xcode opens, you can build and run the app with `⌘R`!

