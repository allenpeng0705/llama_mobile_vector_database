#!/bin/bash -e

# Android SDK build script for LlamaMobileVD
# Updates the Android Kotlin and Java SDKs with the latest built native library

# Set the working directory to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Library configuration
LIBRARY_NAME="libquiverdb_wrapper.a"
LIBRARY_SOURCE_DIR="$PROJECT_ROOT/build-android"
LIBRARY_PATH="$LIBRARY_SOURCE_DIR/$LIBRARY_NAME"

# SDK directories
KOTLIN_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-android-SDK"
JAVA_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-android-java-SDK"

# Check if the library exists
if [ ! -f "$LIBRARY_PATH" ]; then
    echo "❌ Error: Library not found at $LIBRARY_PATH"
    echo "Please run build-android.sh first to build the library"
    exit 1
fi

# Function to update an Android SDK
update_android_sdk() {
    local sdk_dir=$1
    local sdk_name=$2
    local kotlin_sdk=$3
    
    # Check if the SDK directory exists
    if [ ! -d "$sdk_dir" ]; then
        echo "⚠️ Warning: $sdk_name directory not found at $sdk_dir"
        echo "Creating $sdk_name directory structure..."
        
        # Create the SDK directory structure
        if [ "$kotlin_sdk" = true ]; then
            # Kotlin SDK structure
            mkdir -p "$sdk_dir/src/main/kotlin/com/llamamobile/vd" "$sdk_dir/src/main/jniLibs/arm64-v8a" "$sdk_dir/src/test/kotlin/com/llamamobile/vd"
        else
            # Java SDK structure
            mkdir -p "$sdk_dir/src/main/java/com/llamamobile/vd" "$sdk_dir/src/main/jniLibs/arm64-v8a" "$sdk_dir/src/test/java/com/llamamobile/vd"
        fi
        
        if [ $? -ne 0 ]; then
            echo "❌ Error: Failed to create $sdk_name directory structure"
            return 1
        fi
        
        echo "✅ $sdk_name directory structure created"
    fi
    
    # Ensure the jniLibs directory exists
    local jni_libs_dir="$sdk_dir/src/main/jniLibs/arm64-v8a"
    mkdir -p "$jni_libs_dir"
    
    # Update the SDK with the latest library
    echo "=== Updating $sdk_name with the latest library ==="
    echo "Copying library from $LIBRARY_PATH to $jni_libs_dir/"
    
    # Remove existing library if it exists
    if [ -f "$jni_libs_dir/$LIBRARY_NAME" ]; then
        echo "Removing existing library..."
        rm -f "$jni_libs_dir/$LIBRARY_NAME"
    fi
    
    # Copy the library
    cp "$LIBRARY_PATH" "$jni_libs_dir/"
    
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to copy library to $sdk_name"
        return 1
    fi
    
    echo "✅ Library copied successfully to $sdk_name"
    echo "Library location: $jni_libs_dir/$LIBRARY_NAME"
    echo ""
    
    return 0
}

# Update Android Kotlin SDK
echo "=== Updating Android Kotlin SDK ==="
update_android_sdk "$KOTLIN_SDK_DIR" "Android Kotlin SDK" true

# Update Android Java SDK
echo "=== Updating Android Java SDK ==="
update_android_sdk "$JAVA_SDK_DIR" "Android Java SDK" false

# Summary
echo "=== Summary ==="
echo "✅ Android SDKs updated successfully!"
echo ""
echo "To use the Android Kotlin SDK:"
echo "1. Open your Android Studio project"
echo "2. In settings.gradle, add: include ':llama_mobile_vd-android-SDK'"
echo "3. In your app's build.gradle, add: implementation project(':llama_mobile_vd-android-SDK')"
echo ""
echo "To use the Android Java SDK:"
echo "1. Open your Android Studio project"
echo "2. In settings.gradle, add: include ':llama_mobile_vd-android-java-SDK'"
echo "3. In your app's build.gradle, add: implementation project(':llama_mobile_vd-android-java-SDK')"
echo ""
echo "Or manually copy the native libraries from the SDK's jniLibs directory to your project"
