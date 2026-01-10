#!/bin/bash

# Build all SDKs for llama_mobile_vd

echo "=== Building all llama_mobile_vd SDKs ==="

# Navigate to the scripts directory
cd "$(dirname "$0")"

# Build the core library
echo "Building core library..."
bash build-lib.sh

# Build iOS SDK
echo "Building iOS SDK..."
bash build-ios.sh

# Build Android SDK (Kotlin)
echo "Building Android SDK (Kotlin)..."
bash build-android.sh

# Build Android Java SDK
echo "Building Android Java SDK..."
bash build-android.sh

# Build Flutter SDK
echo "Building Flutter SDK..."
bash build-flutter-SDK.sh

# Build React Native SDK
echo "Building React Native SDK..."
bash build-rn-SDK.sh

# Build Capacitor Plugin
echo "Building Capacitor Plugin..."
bash build-capacitor-plugin.sh

echo "=== All SDKs built successfully! ==="
