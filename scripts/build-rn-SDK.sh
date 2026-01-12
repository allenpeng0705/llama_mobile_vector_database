#!/bin/bash -e

# Build script for LlamaMobileVD React Native SDK
# This script copies pre-built iOS framework and Android libraries to the React Native SDK directory

# ==========================
# CENTRAL CONFIGURATION
# Read settings from centralized config.env file if it exists
# ==========================

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    echo "Please run the scripts from the project root directory"
    exit 1
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

# Function to update value in config file
update_config_value() {
    local section="$1"
    local key="$2"
    local value="$3"
    
    if [ -f "$CONFIG_FILE" ]; then
        # Update the config file
        sed -i '' "/\[$section\]/,/^\[/ s/^\($key\s*=\s*\).*/\1$value/" "$CONFIG_FILE"
    fi
}

# Read configuration from config.env
BUILD_TYPE="$(get_config_value core BUILD_TYPE "Release")"
VERBOSE="$(get_config_value core VERBOSE "false")"
ANDROID_VARIANT="$(get_config_value react-native RN_ANDROID_VARIANT "release")"
IOS_CONFIGURATION="$(get_config_value react-native RN_IOS_CONFIGURATION "Release")"

# Update config file with defaults
update_config_value react-native RN_ANDROID_VARIANT "$ANDROID_VARIANT"
update_config_value react-native RN_IOS_CONFIGURATION "$IOS_CONFIGURATION"

# Define directories
RN_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-react-native-SDK"
ios_FRAMEWORK_DEST="$RN_SDK_DIR/ios/LlamaMobileVD.framework"
ANDROID_JNI_DEST="$RN_SDK_DIR/android/src/main/jniLibs"
ANDROID_JAVA_SRC_DEST="$RN_SDK_DIR/android/src/main/java/com/llamamobile/vd"

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}=== Building LlamaMobileVD React Native SDK ===${NC}"

# Step 1: Copy iOS framework from iOS Swift SDK
echo -e "\n${YELLOW}Step 1: Copying iOS framework...${NC}"

# Source directory for iOS framework
ios_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-ios-SDK"
ios_FRAMEWORK_SRC="$ios_SDK_DIR/Frameworks/LlamaMobileVD.framework"

if [ -d "$ios_FRAMEWORK_SRC" ]; then
    # Remove existing framework if it exists
    if [ -d "$ios_FRAMEWORK_DEST" ]; then
        echo "Removing existing iOS framework..."
        rm -rf "$ios_FRAMEWORK_DEST"
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$ios_FRAMEWORK_DEST")"
    
    # Copy the framework
    echo "Copying iOS framework to React Native SDK..."
    cp -R "$ios_FRAMEWORK_SRC" "$ios_FRAMEWORK_DEST"
    
    echo -e "${GREEN}✓ iOS framework copied to React Native SDK${NC}"
else
    echo -e "${RED}Error: iOS framework not found at $ios_FRAMEWORK_SRC${NC}"
    exit 1
fi

# Step 2: Copy Android JNI libraries from Android Java SDK
echo -e "\n${YELLOW}Step 2: Copying Android JNI libraries...${NC}"

# Source directories for Android JNI libraries
ANDROID_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-android-SDK"
ANDROID_JNI_SRC="$ANDROID_SDK_DIR/jniLibs"

if [ -d "$ANDROID_JNI_SRC" ]; then
    # Remove existing JNI libraries if they exist
    if [ -d "$ANDROID_JNI_DEST" ]; then
        echo "Removing existing Android JNI libraries..."
        rm -rf "$ANDROID_JNI_DEST"
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$ANDROID_JNI_DEST"
    
    # Copy the JNI libraries for all architectures
    echo "Copying Android JNI libraries to React Native SDK..."
    cp -R "$ANDROID_JNI_SRC"/* "$ANDROID_JNI_DEST/"
    
    echo -e "${GREEN}✓ Android JNI libraries copied to React Native SDK${NC}"
else
    echo -e "${RED}Error: Android JNI libraries not found at $ANDROID_JNI_SRC${NC}"
    exit 1
fi

# Step 3: Copy Android Java source code from Android Java SDK
echo -e "\n${YELLOW}Step 3: Copying Android Java source code...${NC}"

ANDROID_JAVA_SRC_SRC="$ANDROID_SDK_DIR/src/main/java/com/llamamobile/vd"

if [ -d "$ANDROID_JAVA_SRC_SRC" ]; then
    # Remove existing Java source code if it exists
    if [ -d "$ANDROID_JAVA_SRC_DEST" ]; then
        echo "Removing existing Android Java source code..."
        rm -rf "$ANDROID_JAVA_SRC_DEST/*.java"
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$ANDROID_JAVA_SRC_DEST"
    
    # Copy the Java source code
    echo "Copying Android Java source code to React Native SDK..."
    cp -R "$ANDROID_JAVA_SRC_SRC"/* "$ANDROID_JAVA_SRC_DEST/"
    
    echo -e "${GREEN}✓ Android Java source code copied to React Native SDK${NC}"
else
    echo -e "${RED}Error: Android Java source code not found at $ANDROID_JAVA_SRC_SRC${NC}"
    exit 1
fi

# Step 4: Verify the results
echo -e "\n${YELLOW}Step 4: Verifying the results...${NC}"

# Verify iOS framework
echo -n "Verifying iOS framework... "
if [ -d "$ios_FRAMEWORK_DEST" ]; then
    echo -e "${GREEN}✓ Found at $ios_FRAMEWORK_DEST${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    exit 1
fi

# Verify Android JNI libraries
echo -n "Verifying Android JNI libraries... "
if [ -d "$ANDROID_JNI_DEST/arm64-v8a" ] && [ -f "$ANDROID_JNI_DEST/arm64-v8a/libquiverdb_wrapper.a" ]; then
    echo -e "${GREEN}✓ Found at $ANDROID_JNI_DEST${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    exit 1
fi

# Verify Android Java source code
echo -n "Verifying Android Java source code... "
if [ -d "$ANDROID_JAVA_SRC_DEST" ] && [ -f "$ANDROID_JAVA_SRC_DEST/LlamaMobileVD.java" ]; then
    echo -e "${GREEN}✓ Found at $ANDROID_JAVA_SRC_DEST${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    exit 1
fi

# Verify all architectures
echo -e "\nVerifying Android architectures:"
for arch in "$ANDROID_JNI_DEST"/*; do
    if [ -d "$arch" ] && [ -f "$arch/libquiverdb_wrapper.a" ]; then
        arch_name="$(basename "$arch")"
        echo -e "${GREEN}✓ $arch_name: Found libquiverdb_wrapper.a${NC}"
    fi
done

echo -e "\n${GREEN}=== LlamaMobileVD React Native SDK build completed successfully! ===${NC}"
echo -e "React Native SDK is now ready to use at: $RN_SDK_DIR"
echo -e "You can add it to your React Native project with:"
echo -e "  npm install $RN_SDK_DIR"
echo -e "  cd ios && pod install && cd .."
echo -e "\n${YELLOW}Remember to link the native modules in your React Native project.${NC}"
