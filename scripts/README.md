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

### Bash Scripts (macOS/Linux)

| Script Name | Description |
|-------------|-------------|
| `build-lib.sh` | Builds the core QuiverDB wrapper library |
| `build-ios.sh` | Builds the iOS SDK |
| `build-android.sh` | Builds the Android SDK (Kotlin/Java consolidated) |
| `build-flutter-SDK.sh` | Builds the Flutter SDK |
| `build-capacitor-plugin.sh` | Builds the Capacitor plugin |
|

### Batch Files (Windows)

| Script Name | Description |
|-------------|-------------|
| `build-lib.bat` | Builds the core QuiverDB wrapper library |
| `build-android-lib.bat` | Builds the Android native libraries |
| `build-android-SDK.bat` | Builds the Android SDK |
| `build-flutter-SDK.bat` | Builds the Flutter SDK |
| `build-capacitor-plugin.bat` | Builds the Capacitor plugin |

## Core Library Build Scripts

### build-lib.sh (macOS/Linux)

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

### build-lib.bat (Windows)

Builds the core QuiverDB wrapper library using Visual Studio or Ninja.

**Usage:**
```cmd
build-lib.bat
```

**Features:**
- Uses Visual Studio 2022 as default generator
- Auto-detects number of CPU cores
- Supports both Debug and Release builds
- Runs tests if available
- Loads configuration from config.env

**Examples:**
```cmd
REM Build with default settings (Release)
build-lib.bat

REM Build with Debug configuration
REM Set BUILD_TYPE=Debug in config.env before running
```

### Environment Variables

The core library build scripts can be configured using the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `CMAKE_GENERATOR` | CMake generator to use | Xcode (macOS), Ninja (Linux), Visual Studio 2022 (Windows) |
| `CMAKE_BUILD_TYPE` | Build type | Release |
| `BUILD_DIR` | Build directory | `../build-lib` |
| `NUM_CORES` | Number of parallel jobs | Auto-detected |

## Platform SDK Build Scripts

### iOS SDK

#### build-ios.sh (macOS only)

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

### Android SDK

#### build-android.sh (macOS/Linux)

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

#### build-android-lib.bat (Windows)

Builds the Android native libraries for multiple architectures.

**Usage:**
```cmd
build-android-lib.bat
```

**Features:**
- Auto-detects Android NDK path
- Builds for arm64-v8a and x86_64
- Uses Android toolchain for CMake
- Copies built libraries to android/lib directory

#### build-android-SDK.bat (Windows)

Builds the Android SDK using Gradle.

**Usage:**
```cmd
build-android-SDK.bat
```

**Features:**
- Builds Android library first
- Supports both Debug and Release builds
- Sets up Android SDK and NDK paths
- Uses Gradle for Android build

### Flutter SDK

#### build-flutter-SDK.sh (macOS/Linux)

Builds the Flutter SDK for all supported platforms.

**Usage:**
```bash
./build-flutter-SDK.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

#### build-flutter-SDK.bat (Windows)

Builds the Flutter SDK for Android.

**Usage:**
```cmd
build-flutter-SDK.bat
```

**Features:**
- Verifies Flutter SDK installation
- Builds Android library first
- Supports clean builds
- Builds Flutter AAR for Android



### Capacitor Plugin

#### build-capacitor-plugin.sh (macOS/Linux)

Builds the Capacitor plugin for web, iOS, and Android.

**Usage:**
```bash
./build-capacitor-plugin.sh [OPTIONS]
```

**Options:**
- `-t, --type <build_type>`: Build type: Debug, Release (default: Release)
- `-v, --verbose`: Enable verbose output
- `-h, --help`: Display this help message

#### build-capacitor-plugin.bat (Windows)

Builds the Capacitor plugin for iOS and Android.

**Usage:**
```cmd
build-capacitor-plugin.bat
```

**Features:**
- Verifies and copies iOS framework (multiple sources)
- Verifies and copies Android JNI libraries
- Builds TypeScript code
- Verifies build artifacts
- Provides detailed build summary

## Master Build Script

### build-all.sh (macOS/Linux)

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

### Windows Master Build

On Windows, you can build all components by running the batch files in sequence:

```cmd
REM Build core library
scripts\build-lib.bat

REM Build Android library and SDK
scripts\build-android-lib.bat
scripts\build-android-SDK.bat

REM Build Flutter SDK
scripts\build-flutter-SDK.bat

REM Build Capacitor plugin
scripts\build-capacitor-plugin.bat
```

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
ANDROID_NDK_PATH=/Users/username/Library/Android/sdk/ndk/29.0.14206865
ANDROID_PLATFORM=android-24
ARCHITECTURES=arm64-v8a x86_64 armeabi-v7a x86
JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home

# --- Flutter SDK Build Settings ---
[flutter]
FLUTTER_SDK_PATH=
FORCE_REBUILD=false
CLEAN_BUILD=false

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
| `ANDROID_NDK_PATH` | Path to Android NDK installation | Android builds | `[android]` |
| `JAVA_HOME` | Path to Java JDK installation | Android builds | `[android]` |
| `DEVELOPER_DIR` | Path to Xcode developer directory | iOS builds (macOS) | `[ios]` |
| `BUILD_TYPE` | Build type (Debug/Release) | All builds | `[core]` |
| `CMAKE_PATH` | Path to CMake executable | All builds | `[core]` |
| `FLUTTER_PATH` | Path to Flutter SDK | Flutter builds | `[flutter]` |
| `CAPACITOR_PATH` | Path to Capacitor CLI | Capacitor builds | `[capacitor]` |

### Environment Variable Reference

These environment variables can be set to customize the build process, but most can be managed through `config.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `CMAKE_PATH` | Path to CMake executable | System path |
| `MAKE_PATH` | Path to make executable | System path |
| `NINJA_PATH` | Path to Ninja executable | System path |
| `FLUTTER_PATH` | Path to Flutter SDK | System path |
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
- **Node.js** (optional) - For Capacitor builds

### Windows

To build on Windows, you need to have the following installed:

- **Visual Studio** (2019 or later) with C++ workload - Required for Windows builds
- **CMake** (3.20 or later) - Download from https://cmake.org/download/
- **Git Bash** or **WSL** (optional) - For running shell scripts
- **Android Studio** - For Android builds
- **Flutter SDK** (optional) - For Flutter SDK builds
- **Node.js** (optional) - For Capacitor builds

#### Using Windows Batch Files

Windows users can now use the native batch files (.bat) instead of shell scripts:

1. **Run batch files directly** from the Command Prompt or PowerShell
2. **No need for Git Bash/WSL** for basic builds
3. **Same functionality** as bash scripts
4. **Leverage config.env** for centralized configuration

**Example:**
```cmd
REM Build core library
scripts\build-lib.bat

REM Build Android SDK
scripts\build-android-SDK.bat

REM Build Capacitor plugin
scripts\build-capacitor-plugin.bat
```

#### Windows-Specific Notes

- **Path Format**: Use backslashes for paths (e.g., `C:\Android\Sdk`)
- **Environment Variables**: Set in System Properties → Advanced → Environment Variables
- **Visual Studio**: Must have "Desktop development with C++" workload installed
- **CMake**: Add to PATH during installation
- **Android Studio**: Install NDK via SDK Manager

### Linux

To build on Linux, you need to have the following installed:

- **GCC** (10 or later) or **Clang** (12 or later)
- **CMake** (3.20 or later) - `apt install cmake` (Debian/Ubuntu)
- **Ninja** - `apt install ninja-build` (Debian/Ubuntu)
- **Android Studio** - For Android builds
- **Flutter SDK** (optional) - For Flutter SDK builds
- **Node.js** (optional) - For Capacitor builds

## Troubleshooting

### Common Issues

1. **CMake not found**
   - Ensure CMake is installed and added to your PATH
   - Or set the `CMAKE_PATH` environment variable

2. **Android SDK not found**
   - Ensure Android Studio is installed
   - Set the `ANDROID_HOME` environment variable
   - Set the `ANDROID_NDK_PATH` environment variable

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

1. **Cross-platform compatibility**: 
   - Write bash scripts for macOS/Linux
   - Create equivalent batch files for Windows
   - Maintain consistent functionality across platforms
   - Test scripts on all supported platforms

2. **Consistent interface**: 
   - Use similar command-line options across all scripts
   - Maintain consistent configuration through config.env
   - Provide similar output and error messages

3. **Error handling**: 
   - Provide clear error messages
   - Use proper exit codes for failure conditions
   - Include comprehensive error checking

4. **Documentation**: 
   - Update this README.md file with any changes
   - Document both bash scripts and batch files
   - Include usage examples for all platforms

5. **Testing**: 
   - Test scripts on macOS, Linux, and Windows
   - Verify that config.env works correctly
   - Test both success and failure scenarios

### Adding New Scripts

When adding new build scripts:

1. **Create both bash and batch versions** for cross-platform support
2. **Use config.env** for configuration instead of hardcoding paths
3. **Follow existing patterns** from other scripts
4. **Update README.md** with documentation for the new scripts
5. **Test thoroughly** on all supported platforms

### Windows Batch File Guidelines

When creating Windows batch files:

1. **Use proper batch file syntax** (`.bat` extension)
2. **Handle Windows paths correctly** (backslashes)
3. **Use `setlocal enabledelayedexpansion`** for proper variable handling
4. **Provide clear error messages** in Windows format
5. **Test in both Command Prompt and PowerShell**

For more information on contributing to the project, please see the main README.md file in the project root.
