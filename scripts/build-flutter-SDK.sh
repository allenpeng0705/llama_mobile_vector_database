#!/bin/bash

set -e

echo "Building Flutter SDK for Llama Mobile Vector Database..."

# Get the absolute path to the project root
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
FLUTTER_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-flutter-SDK"

# Create scripts directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/scripts"

# Check if Flutter SDK directory exists
if [ ! -d "$FLUTTER_SDK_DIR" ]; then
    echo "Error: Flutter SDK directory not found at $FLUTTER_SDK_DIR"
    echo "Please run this script from the project root directory"
    exit 1
 fi

# Change to Flutter SDK directory
cd "$FLUTTER_SDK_DIR"

# Clean previous builds
echo "Cleaning previous builds..."
if [ -d "build" ]; then
    rm -rf build
fi

# Run Flutter pub get
echo "Running flutter pub get..."
flutter pub get

# Run tests
echo "Running tests..."
flutter test

echo "Flutter SDK build completed successfully!"
echo "You can now use the Flutter SDK in your Flutter projects."
echo "To use it, add the following to your pubspec.yaml:"
echo ""
echo "dependencies:"
echo "  llama_mobile_vd_flutter_sdk:"
echo "    path: path/to/llama_mobile_vd-flutter-SDK"
