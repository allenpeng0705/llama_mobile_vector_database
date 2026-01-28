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

# ==========================
# CENTRAL CONFIGURATION
# Read settings from centralized config.env file if it exists
# ==========================

# Paths
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Config file not found: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}Using default values...${NC}"
else
    echo -e "${GREEN}✓ Using configuration from $CONFIG_FILE${NC}"
fi

# Function to read value from config file
get_config_value() {
    local section="$1"
    local key="$2"
    local default="$3"
    
    if [ -f "$CONFIG_FILE" ]; then
        local value=$(grep -A 20 "\[$section\]" "$CONFIG_FILE" | grep "^$key=" | cut -d'=' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -n "$value" ]; then
            echo "$value"
            return
        fi
    fi
    
    echo "$default"
}

# Read Capacitor configuration
CAPACITOR_PATH=$(get_config_value "capacitor" "CAPACITOR_PATH" "")

# Use Capacitor from config if set
if [ -n "$CAPACITOR_PATH" ]; then
    echo -e "${GREEN}✓ Using Capacitor from config: $CAPACITOR_PATH${NC}"
    export PATH="$CAPACITOR_PATH:$PATH"
fi

# Check if plugin directory exists
if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "${RED}Error: Plugin directory not found at $PLUGIN_DIR${NC}"
    exit 1
fi

# Step 1: Verify iOS framework
echo -e "\n${YELLOW}Step 1: Verifying iOS framework...${NC}"
IOS_FRAMEWORK="$PLUGIN_DIR/ios/llama_mobile_vd.xcframework"
if [ ! -d "$IOS_FRAMEWORK" ]; then
    echo -e "${YELLOW}iOS framework not found, searching for sources...${NC}"
    
    # Try sources in order of preference
    potential_sources=(
        "$PROJECT_ROOT/llama_mobile_vd-ios-SDK/ios/llama_mobile_vd.xcframework"  # Preferred: dedicated iOS SDK
        "$PROJECT_ROOT/llama_mobile_vd-ios/ios/llama_mobile_vd.xcframework"       # Alternative: iOS directory
        "$PROJECT_ROOT/llama_mobile_vd-flutter-SDK/ios/llama_mobile_vd.xcframework" # Fallback: Flutter SDK
    )
    
    found_source=""
    for source in "${potential_sources[@]}"; do
        if [ -d "$source" ]; then
            found_source="$source"
            break
        fi
    done
    
    if [ -n "$found_source" ]; then
        echo -e "${YELLOW}Copying iOS framework from $found_source${NC}"
        cp -R "$found_source" "$PLUGIN_DIR/ios/"
        echo -e "${GREEN}✓ iOS framework copied${NC}"
    else
        echo -e "${RED}Error: No iOS framework found at any of the potential sources:${NC}"
        for source in "${potential_sources[@]}"; do
            echo -e "${RED}  - $source${NC}"
        done
        echo -e "${YELLOW}Please ensure the iOS framework is built and available in one of these locations.${NC}"
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

# Step 4: Verify build artifacts
echo -e "\n${YELLOW}Step 4: Verifying build artifacts...${NC}"

# Check TypeScript build
if [ ! -d "$PLUGIN_DIR/dist" ]; then
    echo -e "${RED}Error: dist directory not found${NC}"
    exit 1
fi

if [ ! -f "$PLUGIN_DIR/dist/index.js" ]; then
    echo -e "${RED}Error: dist/index.js not found${NC}"
    exit 1
fi

if [ ! -f "$PLUGIN_DIR/dist/cjs/index.js" ]; then
    echo -e "${RED}Error: dist/cjs/index.js not found${NC}"
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

echo -e "\n${YELLOW}=== Important Notes ===${NC}"
echo -e "1. Tests were skipped because they require native platform implementation"
echo -e "2. The plugin is now ready for use on iOS and Android"
echo -e "3. Web platform will use fallback implementation"
echo -e "4. No source code was deleted during this process"
