# Build Scripts Documentation

This directory contains all the build scripts for the llama_mobile_vd project. These scripts are designed to build the core library and all SDKs across different platforms with a consistent interface.

## Table of Contents

- [Build Scripts Documentation](#build-scripts-documentation)
  - [Table of Contents](#table-of-contents)
  - [Available Scripts](#available-scripts)
  - [Core Library Build Scripts](#core-library-build-scripts)
    - [build-lib.sh](#build-libsh)
    - [Environment Variables](#environment-variables)
  - [Platform SDK Build Scripts](#platform-sdk-build-scripts)
    - [build-ios.sh](#build-iossh)
    - [build-android.sh](#build-androidsh)
    - [build-flutter-SDK.sh](#build-flutter-sdksh)
    - [build-rn-SDK.sh](#build-rn-sdksh)
    - [build-capacitor-plugin.sh](#build-capacitor-pluginsh)
  - [Master Build Script](#master-build-script)
    - [build-all.sh](#build-allsh)
  - [Environment Variables](#environment-variables-1)
    - [Required Environment Variables](#required-environment-variables)
    - [Optional Environment Variables](#optional-environment-variables)
  - [Platform-Specific Requirements](#platform-specific-requirements)
    - [macOS](#macos)
    - [Windows](#windows)
    - [Linux](#linux)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)

## Available Scripts

| Script Name | Description |
|-------------|-------------|
| `build-lib.sh` | Builds the core QuiverDB wrapper library |
| `build-ios.sh` | Builds the iOS SDK |
| `build-android.sh` | Builds the Android SDK (Kotlin/Java consolidated) |
| `build-flutter-SDK.sh` | Builds the Flutter SDK |
| `build-rn-SDK.sh` | Builds the React Native SDK |
| `build-capacitor-plugin.sh` | Builds the Capacitor plugin |
| `build-all.sh` | Builds all SDKs and the core library |

## Core Library Build Scripts

### build-lib.sh

Builds the core QuiverDB wrapper library with both static and shared library variants.

**Usage:**
```bash
./build-lib.sh [OPTIONS]
```

**Options:**
- `-g, --generator <generator>`: CMake generator to use (default: Xcode on macOS)
- `-t, --type <build_type>`: Build type: Debug, Release, RelWithDebInfo (default: Release)
- `-d, --dir <build_dir>`: Build directory (default: `../build-lib`)
- `-j, --jobs <num>`: Number of parallel jobs (default: auto-detect)
- `-s, --skip-tests`: Skip running tests after build
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

**Examples:**
```bash
# Build with default settings
./build-lib.sh

# Build with Ninja generator and Debug type
./build-lib.sh --generator Ninja --type Debug

# Build with 8 parallel jobs and skip tests
./build-lib.sh -j 8 --skip-tests
```

### Environment Variables

The build-lib.sh script can be configured using the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `CMAKE_GENERATOR` | CMake generator to use | Xcode (macOS), Ninja (Linux/Windows) |
| `CMAKE_BUILD_TYPE` | Build type | Release |
| `BUILD_DIR` | Build directory | `../build-lib` |
| `NUM_CORES` | Number of parallel jobs | Auto-detected |

## Platform SDK Build Scripts

### build-ios.sh

Builds the iOS SDK for iPhone and Simulator targets.

**Usage:**
```bash
./build-ios.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-s, --simulator-only`: Build only for simulator targets
- `-d, --device-only`: Build only for device targets
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

### build-android.sh

Builds the Android SDK for both Kotlin and Java variants.

**Usage:**
```bash
./build-android.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-a, --abi <abi>`: Specific ABI to build for (e.g., armeabi-v7a, arm64-v8a, x86, x86_64)
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

### build-flutter-SDK.sh

Builds the Flutter SDK for all supported platforms.

**Usage:**
```bash
./build-flutter-SDK.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

### build-rn-SDK.sh

Builds the React Native SDK for iOS and Android.

**Usage:**
```bash
./build-rn-SDK.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-p, --platform <platform>`: Specific platform to build for (ios, android, all)
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

### build-capacitor-plugin.sh

Builds the Capacitor plugin for web, iOS, and Android.

**Usage:**
```bash
./build-capacitor-plugin.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

## Master Build Script

### build-all.sh

Builds all SDKs and the core library in sequence.

**Usage:**
```bash
./build-all.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type for all SDKs (default: Release)
- `-s, --skip-tests`: Skip running tests for all builds
- `-v, --verbose`: Enable verbose output for all scripts
- `-h, --help`: Display this help message

## Centralized Configuration (config.env)

All build scripts now use a centralized configuration file `config.env` located in the `scripts` directory. This file contains all the settings needed for building different SDKs and allows for easy configuration without needing to set environment variables directly.

### Benefits of config.env

- **Centralized management**: All build settings in one place
- **Auto-detection**: Scripts automatically detect common paths and update the config file
- **User-friendly**: Clear sections and comments for easy editing
- **Cross-platform**: Works on macOS, Linux, and Windows
- **Persistent**: Settings are saved for future builds

### Config File Structure

The config.env file is structured with sections for different build targets:

```ini
# Centralized Build Configuration
# This file contains all environment variables needed for building different SDKs
# Build scripts will read from this file and update it with detected values

# --- Core Build Settings ---
[core]
BUILD_TYPE=Release
VERBOSE=false

# --- iOS Build Settings ---
[ios]
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
IOS_DEPLOYMENT_TARGET=14.0
IOS_ARCHS=arm64 arm64e x86_64
simulator_only=false

# --- Android Build Settings ---
[android]
ANDROID_HOME=/Users/username/Library/Android/sdk
ANDROID_NDK_ROOT=/Users/username/Library/Android/sdk/ndk/29.0.14206865
NDK_VERSION=29.0.14206865
ANDROID_PLATFORM=android-24
ARCHITECTURES=arm64-v8a x86_64 armeabi-v7a x86
JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home

# --- Flutter SDK Build Settings ---
[flutter]
FLUTTER_SDK_PATH=
FORCE_REBUILD=false
CLEAN_BUILD=false

# --- React Native SDK Build Settings ---
[react-native]
RN_CLI_PATH=
RN_ANDROID_VARIANT=release
RN_IOS_CONFIGURATION=Release

# --- Capacitor Plugin Build Settings ---
[capacitor]
CAP_CLI_PATH=
CAP_PLATFORMS=android ios
```

### How Build Scripts Use config.env

1. **Reading settings**: Scripts read configuration values from the appropriate sections
2. **Auto-detection**: If a value is not set, scripts try to detect it automatically
3. **Updating config**: Detected values are written back to the config file
4. **User guidance**: If auto-detection fails, scripts provide clear instructions for manual configuration

### Manual Configuration

To manually configure settings:

1. Open the `scripts/config.env` file in a text editor
2. Navigate to the appropriate section
3. Update the values as needed
4. Save the file and run the build scripts

### Example: Setting ANDROID_HOME

```ini
[android]
ANDROID_HOME=C:/Users/username/AppData/Local/Android/Sdk  # Windows
# OR
ANDROID_HOME=/Users/username/Library/Android/sdk  # macOS
# OR
ANDROID_HOME=/home/username/Android/Sdk  # Linux
```

## Environment Variables

### Configuration Precedence

Build scripts use configuration values in this order of precedence:

1. **Command-line arguments** (highest precedence)
2. **Environment variables** (if set)
3. **config.env file values** (if set)
4. **Default values** (lowest precedence)

### Environment Variables vs config.env

Most configuration values can be set either as environment variables or in the `config.env` file. If both are set, environment variables take precedence.

| Variable | Description | Platform | config.env Section |
|----------|-------------|----------|--------------------|
| `ANDROID_HOME` | Path to Android SDK installation | Android builds | `[android]` |
| `ANDROID_NDK_ROOT` | Path to Android NDK installation | Android builds | `[android]` |
| `NDK_VERSION` | Android NDK version | Android builds | `[android]` |
| `JAVA_HOME` | Path to Java JDK installation | Android builds | `[android]` |
| `DEVELOPER_DIR` | Path to Xcode developer directory | iOS builds (macOS) | `[ios]` |
| `BUILD_TYPE` | Build type (Debug/Release) | All builds | `[core]` |
| `CMAKE_PATH` | Path to CMake executable | All builds | `[core]` |
| `FLUTTER_PATH` | Path to Flutter SDK | Flutter builds | `[flutter]` |
| `REACT_NATIVE_PATH` | Path to React Native CLI | React Native builds | `[react-native]` |
| `CAPACITOR_PATH` | Path to Capacitor CLI | Capacitor builds | `[capacitor]` |

### Environment Variable Reference

These environment variables can be set to customize the build process, but most can be managed through `config.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `CMAKE_PATH` | Path to CMake executable | System path |
| `MAKE_PATH` | Path to make executable | System path |
| `NINJA_PATH` | Path to Ninja executable | System path |
| `FLUTTER_PATH` | Path to Flutter SDK | System path |
| `REACT_NATIVE_PATH` | Path to React Native CLI | System path |
| `CAPACITOR_PATH` | Path to Capacitor CLI | System path |

## Platform-Specific Requirements

### macOS

To build on macOS, you need to have the following installed:

- **Xcode** (13.0 or later) - Required for iOS builds
- **Homebrew** - Recommended for installing dependencies
- **CMake** (3.20 or later) - `brew install cmake`
- **Ninja** - `brew install ninja`
- **Android Studio** - For Android builds
- **Flutter SDK** (optional) - For Flutter SDK builds
- **Node.js** (optional) - For React Native and Capacitor builds

### Windows

To build on Windows, you need to have the following installed:

- **Visual Studio** (2019 or later) with C++ workload - Required for Windows builds
- **CMake** (3.20 or later) - Download from https://cmake.org/download/
- **Git Bash** or **WSL** - For running shell scripts
- **Android Studio** - For Android builds
- **Flutter SDK** (optional) - For Flutter SDK builds
- **Node.js** (optional) - For React Native and Capacitor builds

### Linux

To build on Linux, you need to have the following installed:

- **GCC** (10 or later) or **Clang** (12 or later)
- **CMake** (3.20 or later) - `apt install cmake` (Debian/Ubuntu)
- **Ninja** - `apt install ninja-build` (Debian/Ubuntu)
- **Android Studio** - For Android builds
- **Flutter SDK** (optional) - For Flutter SDK builds
- **Node.js** (optional) - For React Native and Capacitor builds

## Troubleshooting

### Common Issues

1. **CMake not found**
   - Ensure CMake is installed and added to your PATH
   - Or set the `CMAKE_PATH` environment variable

2. **Android SDK not found**
   - Ensure Android Studio is installed
   - Set the `ANDROID_HOME` environment variable
   - Set the `ANDROID_NDK_ROOT` environment variable

3. **Xcode not found** (macOS)
   - Ensure Xcode is installed from the App Store
   - Run `xcode-select --install` to install command line tools
   - Set the `XCODE_DEVELOPER_DIR` environment variable if needed

4. **Build fails with "No such file or directory"**
   - Ensure you're running the script from the correct directory
   - Check that all required dependencies are installed

### Debugging Build Issues

1. Use the `-v` or `--verbose` flag to get more detailed output
2. Check the build logs in the respective build directories
3. Ensure all environment variables are set correctly
4. Verify that you have the required versions of all dependencies

## Contributing

When adding new build scripts or modifying existing ones, please follow these guidelines:

1. **Cross-platform compatibility**: Write scripts that work on macOS, Linux, and Windows
2. **Consistent interface**: Use similar command-line options across all scripts
3. **Error handling**: Provide clear error messages and exit codes
4. **Documentation**: Update this README.md file with any changes
5. **Testing**: Test scripts on all supported platforms

For more information on contributing to the project, please see the main README.md file in the project root.
