#!/bin/bash -e

# Build script for LlamaMobileVD Flutter SDK
# This script builds the iOS framework and Android libraries, then copies them to the Flutter SDK directory

# Set the working directory to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Define directories
FLUTTER_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-flutter-SDK"
ios_FRAMEWORK_DEST="$FLUTTER_SDK_DIR/ios/LlamaMobileVD.framework"
ANDROID_JNI_DEST="$FLUTTER_SDK_DIR/android/src/main/jniLibs"

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}=== Building LlamaMobileVD Flutter SDK ===${NC}"

# Step 1: Build iOS framework (only if needed)
echo -e "\n${YELLOW}Step 1: Checking iOS framework...${NC}"
if [ -f "$SCRIPT_DIR/build-ios.sh" ]; then
    # Check if iOS framework already exists in the SDK
    if [ -d "$ios_FRAMEWORK_DEST" ] && [ -f "$ios_FRAMEWORK_DEST/LlamaMobileVD" ]; then
        echo -e "${GREEN}✓ iOS framework already exists in Flutter SDK${NC}"
        echo -e "${YELLOW}Skipping iOS build (use --force to rebuild)${NC}"
    else
        echo -e "${YELLOW}Building iOS framework...${NC}"
        bash "$SCRIPT_DIR/build-ios.sh"
        echo -e "${GREEN}✓ iOS framework built successfully${NC}"
    fi
else
    echo -e "${RED}Error: build-ios.sh not found at $SCRIPT_DIR/build-ios.sh${NC}"
    exit 1
fi

# Step 2: Build Android libraries (only if needed)
echo -e "\n${YELLOW}Step 2: Checking Android libraries...${NC}"
if [ -f "$SCRIPT_DIR/build-android.sh" ]; then
    # Check if Android JNI libraries already exist in the SDK
    if [ -d "$ANDROID_JNI_DEST/arm64-v8a" ] && [ -f "$ANDROID_JNI_DEST/arm64-v8a/libquiverdb_wrapper.a" ]; then
        echo -e "${GREEN}✓ Android JNI libraries already exist in Flutter SDK${NC}"
        echo -e "${YELLOW}Skipping Android build (use --force to rebuild)${NC}"
    else
        echo -e "${YELLOW}Building Android libraries...${NC}"
        bash "$SCRIPT_DIR/build-android.sh"
        echo -e "${GREEN}✓ Android libraries built successfully${NC}"
    fi
else
    echo -e "${RED}Error: build-android.sh not found at $SCRIPT_DIR/build-android.sh${NC}"
    exit 1
fi

# Step 3: Update Flutter SDK with iOS framework
echo -e "\n${YELLOW}Step 3: Updating Flutter SDK with iOS framework...${NC}"

# Source directory for iOS framework (from build-ios.sh output)
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
    echo "Copying iOS framework to Flutter SDK..."
    cp -R "$ios_FRAMEWORK_SRC" "$ios_FRAMEWORK_DEST"
    
    echo -e "${GREEN}✓ iOS framework copied to Flutter SDK${NC}"
else
    echo -e "${RED}Error: iOS framework not found at $ios_FRAMEWORK_SRC${NC}"
    exit 1
fi

# Step 4: Update Flutter SDK with Android JNI libraries
echo -e "\n${YELLOW}Step 4: Updating Flutter SDK with Android JNI libraries...${NC}"

# Source directories for Android JNI libraries (from build-android.sh output)
ANDROID_KOTLIN_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-android-SDK"
ANDROID_JNI_SRC="$ANDROID_KOTLIN_SDK_DIR/src/main/jniLibs"

if [ -d "$ANDROID_JNI_SRC" ]; then
    # Remove existing JNI libraries if they exist
    if [ -d "$ANDROID_JNI_DEST" ]; then
        echo "Removing existing Android JNI libraries..."
        rm -rf "$ANDROID_JNI_DEST"
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$ANDROID_JNI_DEST"
    
    # Copy the JNI libraries for all architectures
    echo "Copying Android JNI libraries to Flutter SDK..."
    cp -R "$ANDROID_JNI_SRC"/* "$ANDROID_JNI_DEST/"
    
    echo -e "${GREEN}✓ Android JNI libraries copied to Flutter SDK${NC}"
else
    echo -e "${RED}Error: Android JNI libraries not found at $ANDROID_JNI_SRC${NC}"
    exit 1
fi

# Step 5: Verify the results
echo -e "\n${YELLOW}Step 5: Verifying the results...${NC}"

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

# Verify all architectures
echo -e "\nVerifying Android architectures:"
for arch in "$ANDROID_JNI_DEST"/*; do
    if [ -d "$arch" ] && [ -f "$arch/libquiverdb_wrapper.a" ]; then
        arch_name="$(basename "$arch")"
        echo -e "${GREEN}✓ $arch_name: Found libquiverdb_wrapper.a${NC}"
    fi
done

echo -e "\n${GREEN}=== LlamaMobileVD Flutter SDK build completed successfully! ===${NC}"
echo -e "Flutter SDK is now ready to use at: $FLUTTER_SDK_DIR"
echo -e "You can add it to your pubspec.yaml with:"
echo -e "  llama_mobile_vd:\n    path: $FLUTTER_SDK_DIR"
echo -e "\n${YELLOW}Remember to run 'flutter pub get' in your Flutter project after adding the dependency.${NC}"
