#!/bin/bash

# Set JAVA_HOME if not already set
if [ -z "$JAVA_HOME" ]; then
    echo "📁 Setting JAVA_HOME..."
    export JAVA_HOME=$(/usr/libexec/java_home)
    echo "JAVA_HOME set to: $JAVA_HOME"
fi


# Android Core Library Build Script for Llama Mobile VD
# This script builds a pure C++ Android library without any Java/Kotlin wrappers.
# The library will contain only the C++ library and header files.

set -e

# ==========================
# CONFIGURATION
# ==========================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
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

# ==========================
# DEFAULT SETTINGS
# ==========================
DEFAULT_BUILD_TYPE="$(get_config_value core BUILD_TYPE "Release")"
DEFAULT_ANDROID_PLATFORM="$(get_config_value android ANDROID_PLATFORM "android-24")"
DEFAULT_ARCHITECTURES=($(get_config_value android ARCHITECTURES "arm64-v8a x86_64"))

# ==========================
# SCRIPT CONFIGURATION
# ==========================
BUILD_TYPE="${BUILD_TYPE:-$DEFAULT_BUILD_TYPE}"
ANDROID_PLATFORM="${ANDROID_PLATFORM:-$DEFAULT_ANDROID_PLATFORM}"
ARCHITECTURES=(${ARCHITECTURES:-${DEFAULT_ARCHITECTURES[*]}})

# ==========================
# PROJECT PATHS
# ==========================
WRAPPER_DIR="$PROJECT_ROOT/lib/wrapper"
CORE_LLAMA_DIR="$PROJECT_ROOT/lib/llama_cpp/quiverdb"
OUTPUT_DIR="$PROJECT_ROOT/llama_mobile_vd-android"
LIBRARY_NAME="libllama_mobile_vd.a"

# ==========================
# VALIDATION
# ==========================

# Validate build type
if [[ "$BUILD_TYPE" != "Debug" && "$BUILD_TYPE" != "Release" ]]; then
    echo "❌ Invalid build type: $BUILD_TYPE"
    echo "Valid build types: Debug, Release"
    exit 1
fi

# Validate architectures
VALID_ARCHITECTURES=("arm64-v8a" "x86_64" "armeabi-v7a" "x86")
for arch in "${ARCHITECTURES[@]}"; do
    if [[ ! " ${VALID_ARCHITECTURES[@]} " =~ " $arch " ]]; then
        echo "❌ Invalid architecture: $arch"
        echo "Valid architectures: ${VALID_ARCHITECTURES[*]}"
        exit 1
    fi
done

# Check for required environment variables
echo "=== Checking Environment Variables ==="

if [ -z "$ANDROID_HOME" ]; then
    echo "❌ Error: ANDROID_HOME environment variable not set"
    echo "Please set ANDROID_HOME to your Android SDK installation directory"
    exit 1
fi
echo "ANDROID_HOME: $ANDROID_HOME"

if [ -z "$JAVA_HOME" ]; then
    echo "❌ Error: JAVA_HOME environment variable not set"
    echo "Please set JAVA_HOME to your Java JDK installation directory"
    exit 1
fi
echo "JAVA_HOME: $JAVA_HOME"

# Check for required dependencies
echo "\n=== Checking Dependencies ==="

# Check for Android NDK
echo -n "Checking for Android NDK... "
ANDROID_NDK_PATH="${ANDROID_NDK_PATH:-$(find "$ANDROID_HOME/ndk" -maxdepth 1 -type d | sort -r | head -1)}"
if [ -z "$ANDROID_NDK_PATH" ] || [ ! -d "$ANDROID_NDK_PATH" ]; then
    echo "✗"
    echo "❌ Error: Android NDK not found"
    echo "Please install Android NDK or set ANDROID_NDK_PATH environment variable"
    exit 1
fi
echo "$ANDROID_NDK_PATH"

# Check for CMake
echo -n "Checking for CMake... "
if ! command -v cmake &> /dev/null; then
    echo "✗"
    echo "❌ Error: CMake not found"
    echo "Please install CMake via Homebrew: brew install cmake"
    exit 1
fi
echo "$(command -v cmake)"

# ==========================
# BUILD PROCESS
# ==========================
echo "\n=== Building Android Core Library ==="
echo "Build Type: $BUILD_TYPE"
echo "Android Platform: $ANDROID_PLATFORM"
echo "Architectures: ${ARCHITECTURES[*]}"
echo "Output Directory: $OUTPUT_DIR"

# Clean any existing build directories - preserving README.md
if [ -f "$OUTPUT_DIR/README.md" ]; then
    # Save the README.md file temporarily
    mv "$OUTPUT_DIR/README.md" "$PROJECT_ROOT/temp_README.md"
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Restore the README.md if it was saved
if [ -f "$PROJECT_ROOT/temp_README.md" ]; then
    mv "$PROJECT_ROOT/temp_README.md" "$OUTPUT_DIR/README.md"
fi

rm -rf "$PROJECT_ROOT/build-android"
mkdir -p "$PROJECT_ROOT/build-android"

# Create output directories for each architecture
mkdir -p "$OUTPUT_DIR/libs"
for arch in "${ARCHITECTURES[@]}"; do
    mkdir -p "$OUTPUT_DIR/libs/$arch"
done

# Copy header files
echo "\n=== Copying Header Files ==="
mkdir -p "$OUTPUT_DIR/include"
cp "$WRAPPER_DIR/include/llama_mobile_vd_wrapper.h" "$OUTPUT_DIR/include/"
echo "✓ Copied llama_mobile_vd_wrapper.h to $OUTPUT_DIR/include/"
cp "$WRAPPER_DIR/include/llama_mobile_vd_version.h" "$OUTPUT_DIR/include/"
echo "✓ Copied llama_mobile_vd_version.h to $OUTPUT_DIR/include/"

# Build the C++ wrapper library for each architecture
cd "$WRAPPER_DIR"
echo "\n=== Building C++ Wrapper Library ==="

build_android_library() {
    local arch=$1
    local build_dir="$PROJECT_ROOT/build-android-$arch"
    local output_dir="$OUTPUT_DIR/libs/$arch"
    
    echo "\nBuilding for $arch..."
    
    # Create build directory
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    # Run CMake configuration
    cmake "$WRAPPER_DIR" \
        -G "Unix Makefiles" \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_PATH/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI=$arch \
        -DANDROID_PLATFORM=$ANDROID_PLATFORM \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DBUILD_SHARED_LIBS=OFF \
        -DANDROID_STL=c++_static \
        -DANDROID_ARM_MODE=arm \
        -DANDROID_ARM_NEON=TRUE
    
    # Build the library
    cmake --build . --config $BUILD_TYPE
    
    # Copy the built library to the output directory
    if [ -f "libllama_mobile_vd.a" ]; then
        cp "libllama_mobile_vd.a" "$output_dir/$LIBRARY_NAME"
        echo "✓ Built and copied $LIBRARY_NAME for $arch"
    else
        echo "❌ Error: libllama_mobile_vd.a not found for $arch"
        exit 1
    fi
}

# Build for each architecture
for arch in "${ARCHITECTURES[@]}"; do
    build_android_library "$arch"
done

# ==========================
# VERIFICATION
# ==========================
echo "\n=== Verifying Build Results ==="

# Check if all libraries were built successfully
all_success=true
for arch in "${ARCHITECTURES[@]}"; do
    library_path="$OUTPUT_DIR/libs/$arch/$LIBRARY_NAME"
    if [ -f "$library_path" ]; then
        echo "✓ Library exists: $library_path"
        # Verify the library architecture
        echo -n "  Verifying architecture... "
        if file "$library_path" | grep -q "$arch\|$arch" 2>/dev/null; then
            echo "✓"
        else
            echo "⚠️  Could not verify architecture (this is normal for some architectures)"
        fi
    else
        echo "❌ Library missing: $library_path"
        all_success=false
    fi
done

if [ "$all_success" = true ]; then
    echo "\n✅ Android Core Library built successfully!"
    echo "Output location: $OUTPUT_DIR"
    echo "Architectures built: ${ARCHITECTURES[*]}"
    echo "Header files: $OUTPUT_DIR/include/"
else
    echo "\n❌ Android Core Library build failed!"
    exit 1
fi

# Clean up temporary build directories
rm -rf "$PROJECT_ROOT/build-android-*"
