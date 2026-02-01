#!/bin/bash

set -e

echo "Building Flutter SDK for Llama Mobile Vector Database..."

# Get the absolute path to the project root
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
FLUTTER_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-flutter-SDK"
SDK_BACKUP_DIR="$PROJECT_ROOT/scripts/sdk_backup"
IOS_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-ios-SDK"
ANDROID_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-android-SDK"

# Create scripts directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/scripts"

# Create backup directory if it doesn't exist
mkdir -p "$SDK_BACKUP_DIR"

# Check if Flutter SDK directory exists
if [ ! -d "$FLUTTER_SDK_DIR" ]; then
    echo "Error: Flutter SDK directory not found at $FLUTTER_SDK_DIR"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Check if iOS SDK directory exists
if [ ! -d "$IOS_SDK_DIR" ]; then
    echo "Error: iOS SDK directory not found at $IOS_SDK_DIR"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Check if Android SDK directory exists
if [ ! -d "$ANDROID_SDK_DIR" ]; then
    echo "Error: Android SDK directory not found at $ANDROID_SDK_DIR"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Backup Flutter SDK
echo "Backing up Flutter SDK to $SDK_BACKUP_DIR..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="llama_mobile_vd-flutter-SDK_$TIMESTAMP"

# Create backup directory
BACKUP_DIR="$SDK_BACKUP_DIR/$BACKUP_NAME"
mkdir -p "$BACKUP_DIR"

# Copy Flutter SDK files to backup
cp -r "$FLUTTER_SDK_DIR/"* "$BACKUP_DIR/"

# Change to Flutter SDK directory
cd "$FLUTTER_SDK_DIR"

# Clean specific directories
echo "Cleaning specific directories..."

# Clean iOS xcframework
if [ -d "ios/llama_mobile_vd.xcframework" ]; then
    echo "Cleaning iOS xcframework..."
    rm -rf "ios/llama_mobile_vd.xcframework"
fi

# Clean Android jniLibs
if [ -d "android/src/main/jniLibs" ]; then
    echo "Cleaning Android jniLibs..."
    rm -rf "android/src/main/jniLibs"
fi

# Create necessary directories
mkdir -p "ios/Classes"
mkdir -p "android/src/main/java/com/llamamobile/vd"
mkdir -p "android/src/main/kotlin/com/llamamobile/vd"
mkdir -p "android/src/main/cpp/include"
mkdir -p "android/src/main/jniLibs"

# Copy iOS xcframework
echo "Copying iOS xcframework..."
IOS_XCFRAMEWORK_SRC="$IOS_SDK_DIR/llama_mobile_vd.xcframework"
IOS_XCFRAMEWORK_DST="$FLUTTER_SDK_DIR/ios/llama_mobile_vd.xcframework"

if [ -d "$IOS_XCFRAMEWORK_SRC" ]; then
    cp -r "$IOS_XCFRAMEWORK_SRC" "$IOS_XCFRAMEWORK_DST"
else
    echo "Warning: iOS xcframework not found at $IOS_XCFRAMEWORK_SRC"
fi

# Copy Swift wrapper files from iOS SDK
echo "Copying Swift wrapper files from iOS SDK..."
SWIFT_SRC_FILE="$IOS_SDK_DIR/Sources/LlamaMobileVD/LlamaMobileVD.swift"
SWIFT_DST_DIR="$FLUTTER_SDK_DIR/ios/Classes"

if [ -f "$SWIFT_SRC_FILE" ]; then
    cp -f "$SWIFT_SRC_FILE" "$SWIFT_DST_DIR/"
else
    echo "Warning: Swift wrapper file not found at $SWIFT_SRC_FILE"
fi

# Copy Kotlin files from Android SDK (skip Java files to avoid conflicts)
echo "Copying Kotlin files from Android SDK..."
KOTLIN_SRC_FILE="$ANDROID_SDK_DIR/src/main/kotlin/com/llamamobile/vd/LlamaMobileVDKt.kt"
KOTLIN_DST_DIR="$FLUTTER_SDK_DIR/android/src/main/kotlin/com/llamamobile/vd"

if [ -f "$KOTLIN_SRC_FILE" ]; then
    cp -f "$KOTLIN_SRC_FILE" "$KOTLIN_DST_DIR/"
else
    echo "Warning: Kotlin file not found at $KOTLIN_SRC_FILE"
fi

# Copy JNI layer from Android SDK
echo "Copying JNI layer from Android SDK..."
JNI_CPP_SRC_DIR="$ANDROID_SDK_DIR/src/main/cpp"
JNI_CPP_DST_DIR="$FLUTTER_SDK_DIR/android/src/main/cpp"

if [ -d "$JNI_CPP_SRC_DIR" ]; then
    # Copy specific JNI files
    cp -f "$JNI_CPP_SRC_DIR/CMakeLists.txt" "$JNI_CPP_DST_DIR/"
    cp -f "$JNI_CPP_SRC_DIR/llama_mobile_vd_jni.cpp" "$JNI_CPP_DST_DIR/"
    # Copy include directory
    if [ -d "$JNI_CPP_SRC_DIR/include" ]; then
        cp -rf "$JNI_CPP_SRC_DIR/include" "$JNI_CPP_DST_DIR/"
    fi
else
    echo "Warning: JNI CPP directory not found at $JNI_CPP_SRC_DIR"
fi

# Copy JNI libraries from Android SDK
echo "Copying JNI libraries from Android SDK..."
JNI_LIBS_SRC_DIR="$ANDROID_SDK_DIR/src/main/jniLibs"
JNI_LIBS_DST_DIR="$FLUTTER_SDK_DIR/android/src/main/jniLibs"

if [ -d "$JNI_LIBS_SRC_DIR" ]; then
    # Copy specific architectures
    if [ -d "$JNI_LIBS_SRC_DIR/arm64-v8a" ]; then
        cp -r "$JNI_LIBS_SRC_DIR/arm64-v8a" "$JNI_LIBS_DST_DIR/"
    fi
    if [ -d "$JNI_LIBS_SRC_DIR/x86_64" ]; then
        cp -r "$JNI_LIBS_SRC_DIR/x86_64" "$JNI_LIBS_DST_DIR/"
    fi
else
    echo "Warning: JNI libraries directory not found at $JNI_LIBS_SRC_DIR"
fi

# Clean previous builds
echo "Cleaning previous builds..."
if [ -d "build" ]; then
    rm -rf build
fi

# Run Flutter pub get
echo "Running flutter pub get..."
flutter pub get

echo "Flutter SDK build completed successfully!"
echo "You can now use the Flutter SDK in your Flutter projects."
echo "To use it, add the following to your pubspec.yaml:"
echo ""
echo "dependencies:"
echo "  llama_mobile_vd_flutter_sdk:"
echo "    path: path/to/llama_mobile_vd-flutter-SDK"
echo ""
echo "To run integration tests:"
echo "  flutter test integration_test"
echo ""
echo "Backup created at: $BACKUP_DIR"

