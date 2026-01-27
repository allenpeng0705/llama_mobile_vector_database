#!/bin/bash -e

# Build script for LlamaMobileVD Capacitor Plugin
# This script builds the plugin from source and prepares it for distribution

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Building LlamaMobileVD Capacitor Plugin ===${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="$PROJECT_ROOT/llama_mobile_vd-capacitor-plugin"

# Check if plugin directory exists
if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "${RED}Error: Plugin directory not found at $PLUGIN_DIR${NC}"
    exit 1
fi

# Step 1: Verify iOS framework
echo -e "\n${YELLOW}Step 1: Verifying iOS framework...${NC}"
IOS_FRAMEWORK="$PLUGIN_DIR/ios/llama_mobile_vd.xcframework"
if [ ! -d "$IOS_FRAMEWORK" ]; then
    echo -e "${YELLOW}iOS framework not found, copying from Flutter SDK...${NC}"
    FLUTTER_IOS_FRAMEWORK="$PROJECT_ROOT/llama_mobile_vd-flutter-SDK/ios/llama_mobile_vd.xcframework"
    if [ -d "$FLUTTER_IOS_FRAMEWORK" ]; then
        cp -R "$FLUTTER_IOS_FRAMEWORK" "$PLUGIN_DIR/ios/"
        echo -e "${GREEN}✓ iOS framework copied${NC}"
    else
        echo -e "${RED}Error: Flutter iOS framework not found at $FLUTTER_IOS_FRAMEWORK${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ iOS framework found${NC}"
fi

# Step 2: Verify Android JNI libraries
echo -e "\n${YELLOW}Step 2: Verifying Android JNI libraries...${NC}"
ANDROID_JNI="$PLUGIN_DIR/android/src/main/jniLibs"
if [ ! -d "$ANDROID_JNI" ] || [ -z "$(ls -A $ANDROID_JNI 2>/dev/null)" ]; then
    echo -e "${YELLOW}Android JNI libraries not found, copying from Android SDK...${NC}"
    ANDROID_SDK_JNI="$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/jniLibs"
    if [ -d "$ANDROID_SDK_JNI" ]; then
        mkdir -p "$ANDROID_JNI"
        cp -R "$ANDROID_SDK_JNI"/* "$ANDROID_JNI/"
        echo -e "${GREEN}✓ Android JNI libraries copied${NC}"
    else
        echo -e "${RED}Error: Android SDK JNI libraries not found at $ANDROID_SDK_JNI${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Android JNI libraries found${NC}"
fi

# Step 3: Build TypeScript code
echo -e "\n${YELLOW}Step 3: Building TypeScript code...${NC}"
cd "$PLUGIN_DIR"
npm install
npm run build

# Step 4: Run tests
echo -e "\n${YELLOW}Step 4: Running tests...${NC}"
npm test

# Step 5: Verify build artifacts
echo -e "\n${YELLOW}Step 5: Verifying build artifacts...${NC}"

# Check TypeScript build
if [ ! -d "$PLUGIN_DIR/dist" ]; then
    echo -e "${RED}Error: dist directory not found${NC}"
    exit 1
fi

if [ ! -f "$PLUGIN_DIR/dist/plugin.js" ]; then
    echo -e "${RED}Error: dist/plugin.js not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ TypeScript build verified${NC}"

# Check iOS plugin
if [ ! -f "$PLUGIN_DIR/ios/Plugin/LlamaMobileVDPlugin.swift" ]; then
    echo -e "${RED}Error: iOS plugin not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ iOS plugin verified${NC}"

# Check Android plugin
if [ ! -f "$PLUGIN_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVDPlugin.java" ]; then
    echo -e "${RED}Error: Android plugin not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Android plugin verified${NC}"

# Step 6: Display summary
echo -e "\n${GREEN}=== Build Summary ===${NC}"
echo -e "Plugin directory: ${GREEN}$PLUGIN_DIR${NC}"
echo -e "TypeScript build: ${GREEN}dist/${NC}"
echo -e "iOS plugin: ${GREEN}ios/Plugin/${NC}"
echo -e "iOS framework: ${GREEN}ios/llama_mobile_vd.xcframework/${NC}"
echo -e "Android plugin: ${GREEN}android/src/main/java/com/llamamobile/vd/${NC}"
echo -e "Android JNI libs: ${GREEN}android/src/main/jniLibs/${NC}"

echo -e "\n${GREEN}=== Build completed successfully! ===${NC}"
echo -e "You can now use the plugin in your Capacitor project:"
echo -e "  cd your-capacitor-project"
echo -e "  npm install $PLUGIN_DIR"
echo -e "  npx cap sync"
