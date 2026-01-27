#!/bin/bash -e

# Build script for LlamaMobileVD Capacitor Plugin
# This script builds the TypeScript code and prepares the plugin for distribution

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Building LlamaMobileVD Capacitor Plugin ===${NC}"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Step 1: Clean previous build
echo -e "\n${YELLOW}Step 1: Cleaning previous build...${NC}"
cd "$PLUGIN_DIR"
npm run clean

# Step 2: Install dependencies
echo -e "\n${YELLOW}Step 2: Installing dependencies...${NC}"
npm install

# Step 3: Build TypeScript code
echo -e "\n${YELLOW}Step 3: Building TypeScript code...${NC}"
npm run build

# Step 4: Run tests
echo -e "\n${YELLOW}Step 4: Running tests...${NC}"
npm test

# Step 5: Verify the build
echo -e "\n${YELLOW}Step 5: Verifying the build...${NC}"

# Check if dist directory exists
if [ ! -d "$PLUGIN_DIR/dist" ]; then
    echo -e "${RED}Error: dist directory not found${NC}"
    exit 1
fi

# Check if plugin.js exists
if [ ! -f "$PLUGIN_DIR/dist/plugin.js" ]; then
    echo -e "${RED}Error: dist/plugin.js not found${NC}"
    exit 1
fi

# Check if esm directory exists
if [ ! -d "$PLUGIN_DIR/dist/esm" ]; then
    echo -e "${RED}Error: dist/esm directory not found${NC}"
    exit 1
fi

# Check if iOS plugin exists
if [ ! -f "$PLUGIN_DIR/ios/Plugin/LlamaMobileVDPlugin.swift" ]; then
    echo -e "${RED}Error: iOS plugin not found${NC}"
    exit 1
fi

# Check if iOS framework exists
if [ ! -d "$PLUGIN_DIR/ios/llama_mobile_vd.xcframework" ]; then
    echo -e "${RED}Error: iOS framework not found${NC}"
    exit 1
fi

# Check if Android plugin exists
if [ ! -f "$PLUGIN_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVDPlugin.java" ]; then
    echo -e "${RED}Error: Android plugin not found${NC}"
    exit 1
fi

# Check if Android JNI libraries exist
if [ ! -d "$PLUGIN_DIR/android/src/main/jniLibs" ]; then
    echo -e "${RED}Error: Android JNI libraries not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All build artifacts verified${NC}"

# Step 6: Display build summary
echo -e "\n${GREEN}=== Build Summary ===${NC}"
echo -e "Plugin directory: ${GREEN}$PLUGIN_DIR${NC}"
echo -e "TypeScript build: ${GREEN}dist/${NC}"
echo -e "iOS plugin: ${GREEN}ios/Plugin/${NC}"
echo -e "iOS framework: ${GREEN}ios/llama_mobile_vd.xcframework/${NC}"
echo -e "Android plugin: ${GREEN}android/src/main/java/com/llamamobile/vd/${NC}"
echo -e "Android JNI libs: ${GREEN}android/src/main/jniLibs/${NC}"

echo -e "\n${GREEN}=== Build completed successfully! ===${NC}"
echo -e "You can now use the plugin in your Capacitor project:"
echo -e "  npm install $PLUGIN_DIR"
echo -e "  npx cap sync"
