#!/bin/bash

# iOS Swift SDK build script for LlamaMobileVD
# Updates the iOS Swift SDK with the latest built framework

# Set the working directory to the project root
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$SCRIPT_DIR/.."

# Framework and SDK configuration
FRAMEWORK_NAME="LlamaMobileVD"
FRAMEWORK_SOURCE_DIR="$PROJECT_ROOT/build-ios-framework/Release-iphoneos"
FRAMEWORK_PATH="$FRAMEWORK_SOURCE_DIR/$FRAMEWORK_NAME.framework"

# SDK directories
IOS_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-ios-SDK"
SDK_FRAMEWORKS_DIR="$IOS_SDK_DIR/Frameworks"

# Check if the framework exists
if [ ! -d "$FRAMEWORK_PATH" ]; then
    echo "❌ Error: Framework not found at $FRAMEWORK_PATH"
    echo "Please run build-ios.sh first to build the framework"
    exit 1
fi

# Check if the iOS SDK directory exists
if [ ! -d "$IOS_SDK_DIR" ]; then
    echo "⚠️ Warning: iOS Swift SDK directory not found at $IOS_SDK_DIR"
    echo "Creating iOS Swift SDK directory structure..."
    
    # Create the SDK directory structure
    mkdir -p "$IOS_SDK_DIR/Sources/LlamaMobileVD" "$IOS_SDK_DIR/Tests/LlamaMobileVDTests" "$IOS_SDK_DIR/Frameworks"
    
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to create iOS Swift SDK directory structure"
        exit 1
    fi
    
    echo "✅ iOS Swift SDK directory structure created"
fi

# Ensure the Frameworks directory exists
mkdir -p "$SDK_FRAMEWORKS_DIR"

# Update the iOS Swift SDK with the latest framework
echo "=== Updating iOS Swift SDK with the latest framework ==="
echo "Copying framework from $FRAMEWORK_PATH to $SDK_FRAMEWORKS_DIR/"

# Remove existing framework if it exists
if [ -d "$SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework" ]; then
    echo "Removing existing framework..."
    rm -rf "$SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework"
fi

# Copy the framework
cp -R "$FRAMEWORK_PATH" "$SDK_FRAMEWORKS_DIR/"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to copy framework to iOS Swift SDK"
    exit 1
fi

echo "✅ Framework copied successfully"

# Verify the update
echo "=== Verifying iOS Swift SDK update ==="
if [ -d "$SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework" ]; then
    echo "✅ iOS Swift SDK updated successfully!"
    echo "Framework location: $SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework"
    echo ""
    echo "To use the iOS Swift SDK:"
    echo "1. Open your Xcode project"
    echo "2. Go to File > Add Packages..."
    echo "3. Enter the path to: $IOS_SDK_DIR"
    echo "4. Click Add Package"
    echo ""
    echo "Or manually copy the framework to your project's Frameworks directory"
else
    echo "❌ Error: Framework not found in iOS Swift SDK after update"
    exit 1
fi
