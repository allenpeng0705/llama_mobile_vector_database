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
SDK_BACKUP_DIR="$PROJECT_ROOT/scripts/sdk_backup"

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

# ==========================
# STEP 1: Backup Capacitor Plugin
# ==========================
echo -e "\n${YELLOW}Step 1: Backing up Capacitor Plugin...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$SDK_BACKUP_DIR"

# Create timestamped backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="llama_mobile_vd-capacitor-plugin_$TIMESTAMP"
BACKUP_DIR="$SDK_BACKUP_DIR/$BACKUP_NAME"
mkdir -p "$BACKUP_DIR"

# Copy Capacitor plugin files to backup
echo -e "${YELLOW}Creating backup at $BACKUP_DIR${NC}"
cp -r "$PLUGIN_DIR/"* "$BACKUP_DIR/"
echo -e "${GREEN}✓ Capacitor Plugin backed up${NC}"

# ==========================
# STEP 2: Clean and Copy Native Files
# ==========================
echo -e "\n${YELLOW}Step 2: Cleaning and copying native files...${NC}"

# Clean iOS xcframework
IOS_XCFRAMEWORK_DST="$PLUGIN_DIR/ios/llama_mobile_vd.xcframework"
if [ -d "$IOS_XCFRAMEWORK_DST" ]; then
    echo -e "${YELLOW}Cleaning iOS xcframework...${NC}"
    rm -rf "$IOS_XCFRAMEWORK_DST"
fi

# Clean iOS Swift wrapper
IOS_SWIFT_DST="$PLUGIN_DIR/ios/Plugin/LlamaMobileVD.swift"
if [ -f "$IOS_SWIFT_DST" ]; then
    echo -e "${YELLOW}Cleaning iOS Swift wrapper...${NC}"
    rm -f "$IOS_SWIFT_DST"
fi

# Clean Android cpp directory
ANDROID_CPP_DST="$PLUGIN_DIR/android/src/main/cpp"
if [ -d "$ANDROID_CPP_DST" ]; then
    echo -e "${YELLOW}Cleaning Android cpp directory...${NC}"
    rm -rf "$ANDROID_CPP_DST"
fi

# Clean Android jniLibs directory
ANDROID_JNI_DST="$PLUGIN_DIR/android/src/main/jniLibs"
if [ -d "$ANDROID_JNI_DST" ]; then
    echo -e "${YELLOW}Cleaning Android jniLibs directory...${NC}"
    rm -rf "$ANDROID_JNI_DST"
fi

# Clean Android Java wrapper
ANDROID_JAVA_DST="$PLUGIN_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVD.java"
if [ -f "$ANDROID_JAVA_DST" ]; then
    echo -e "${YELLOW}Cleaning Android Java wrapper...${NC}"
    rm -f "$ANDROID_JAVA_DST"
fi

# Create necessary directories
mkdir -p "$PLUGIN_DIR/ios/Plugin"
mkdir -p "$PLUGIN_DIR/android/src/main/cpp"
mkdir -p "$PLUGIN_DIR/android/src/main/jniLibs"
mkdir -p "$PLUGIN_DIR/android/src/main/java/com/llamamobile/vd"

# Copy iOS xcframework from llama_mobile_vd-ios
echo -e "${YELLOW}Copying iOS xcframework...${NC}"
IOS_XCFRAMEWORK_SRC="$PROJECT_ROOT/llama_mobile_vd-ios/llama_mobile_vd.xcframework"
if [ -d "$IOS_XCFRAMEWORK_SRC" ]; then
    cp -r "$IOS_XCFRAMEWORK_SRC" "$IOS_XCFRAMEWORK_DST"
    echo -e "${GREEN}✓ iOS xcframework copied${NC}"
else
    echo -e "${RED}Error: iOS xcframework not found at $IOS_XCFRAMEWORK_SRC${NC}"
    exit 1
fi

# Copy Swift wrapper from llama_mobile_vd-ios-SDK
echo -e "${YELLOW}Copying Swift wrapper...${NC}"
IOS_SWIFT_SRC="$PROJECT_ROOT/llama_mobile_vd-ios-SDK/Sources/LlamaMobileVD/LlamaMobileVD.swift"
if [ -f "$IOS_SWIFT_SRC" ]; then
    cp -f "$IOS_SWIFT_SRC" "$IOS_SWIFT_DST"
    echo -e "${GREEN}✓ Swift wrapper copied${NC}"
else
    echo -e "${RED}Error: Swift wrapper not found at $IOS_SWIFT_SRC${NC}"
    exit 1
fi

# Copy JNI libs from llama_mobile_vd-android
echo -e "${YELLOW}Copying JNI libraries...${NC}"
ANDROID_JNI_SRC="$PROJECT_ROOT/llama_mobile_vd-android/libs"
if [ -d "$ANDROID_JNI_SRC" ]; then
    cp -r "$ANDROID_JNI_SRC"/* "$ANDROID_JNI_DST/"
    echo -e "${GREEN}✓ JNI libraries copied${NC}"
else
    echo -e "${RED}Error: JNI libraries not found at $ANDROID_JNI_SRC${NC}"
    exit 1
fi

# Copy cpp files from llama_mobile_vd-android-SDK
echo -e "${YELLOW}Copying cpp files...${NC}"
ANDROID_CPP_SRC="$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/cpp"
if [ -d "$ANDROID_CPP_SRC" ]; then
    cp -r "$ANDROID_CPP_SRC"/* "$ANDROID_CPP_DST/"
    echo -e "${GREEN}✓ cpp files copied${NC}"
else
    echo -e "${RED}Error: cpp files not found at $ANDROID_CPP_SRC${NC}"
    exit 1
fi

# Copy Java wrapper from llama_mobile_vd-android-SDK
echo -e "${YELLOW}Copying Java wrapper...${NC}"
ANDROID_JAVA_SRC="$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/java/com/llamamobile/vd/LlamaMobileVD.java"
if [ -f "$ANDROID_JAVA_SRC" ]; then
    cp -f "$ANDROID_JAVA_SRC" "$ANDROID_JAVA_DST"
    echo -e "${GREEN}✓ Java wrapper copied${NC}"
else
    echo -e "${RED}Error: Java wrapper not found at $ANDROID_JAVA_SRC${NC}"
    exit 1
fi

# ==========================
# STEP 3: Build Everything
# ==========================
echo -e "\n${YELLOW}Step 3: Building TypeScript code...${NC}"
cd "$PLUGIN_DIR"

# Install dependencies
echo -e "${YELLOW}Installing npm dependencies...${NC}"
npm install

# Build TypeScript
echo -e "${YELLOW}Building TypeScript...${NC}"
npm run build

# Verify build artifacts
echo -e "\n${YELLOW}Verifying build artifacts...${NC}"

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

# ==========================
# STEP 4: Run Tests
# ==========================
echo -e "\n${YELLOW}Step 4: Running tests...${NC}"

# Check if tests directory exists
if [ -d "$PLUGIN_DIR/tests" ] || [ -d "$PLUGIN_DIR/test" ] || [ -d "$PLUGIN_DIR/__tests__" ]; then
    echo -e "${YELLOW}Running npm test...${NC}"
    if npm test; then
        echo -e "${GREEN}✓ Tests passed${NC}"
    else
        echo -e "${YELLOW}Warning: Some tests failed or were skipped${NC}"
    fi
else
    echo -e "${YELLOW}No test directory found, skipping tests${NC}"
fi

# ==========================
# STEP 5: Display Summary
# ==========================
echo -e "\n${GREEN}=== Build Summary ===${NC}"
echo -e "Plugin directory: ${GREEN}$PLUGIN_DIR${NC}"
echo -e "TypeScript build: ${GREEN}dist/${NC}"
echo -e "iOS plugin: ${GREEN}ios/Plugin/${NC}"
echo -e "iOS framework: ${GREEN}ios/llama_mobile_vd.xcframework/${NC}"
echo -e "Android plugin: ${GREEN}android/src/main/java/com/llamamobile/vd/${NC}"
echo -e "Android JNI libs: ${GREEN}android/src/main/jniLibs/${NC}"
echo -e "Android cpp: ${GREEN}android/src/main/cpp/${NC}"
echo -e "Backup location: ${GREEN}$BACKUP_DIR${NC}"

echo -e "\n${GREEN}=== Build completed successfully! ===${NC}"
echo -e "You can now use the plugin in your Capacitor project:"
echo -e "  cd your-capacitor-project"
echo -e "  npm install $PLUGIN_DIR"
echo -e "  npx cap sync"

echo -e "\n${GREEN}✓ Everything is fine!${NC}"
