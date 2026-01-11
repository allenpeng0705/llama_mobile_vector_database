#!/bin/bash

# Android build script for QuiverDB wrapper and Llama Mobile VD library
# Enhanced for cross-platform compatibility and user configurability

set -e

# ==========================
# CENTRAL CONFIGURATION
# Read settings from centralized config.env file if it exists
# ==========================

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

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

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    echo "Please run the scripts from the project root directory"
    exit 1
fi

# ==========================
# CONFIGURATION VARIABLES
# All build settings are centralized here for easy access
# ==========================

# --------------------------
# REQUIRED ENVIRONMENT VARIABLES
# These variables must be set, either by the user or auto-detected
# --------------------------
# ANDROID_HOME: Path to Android SDK installation
# Example: export ANDROID_HOME="$HOME/Android/Sdk"

# JAVA_HOME: Path to Java JDK installation (Java 11 recommended)
# Example: export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"

# --------------------------
# OPTIONAL ENVIRONMENT VARIABLES
# These variables have reasonable defaults but can be overridden
# --------------------------
# ANDROID_NDK_PATH: Path to Android NDK installation (auto-detected if not set)
# Example: export ANDROID_NDK_PATH="$ANDROID_HOME/ndk/29.0.14206865"

# CMAKE_PATH: Path to CMake executable (auto-detected if not set)
# Example: export CMAKE_PATH="/usr/local/bin/cmake"

# --------------------------
# DEFAULT SETTINGS
# These can be overridden by command line arguments or environment variables
# --------------------------
DEFAULT_FORCE_BUILD=false
DEFAULT_BUILD_TYPE="$(get_config_value core BUILD_TYPE "Release")"
DEFAULT_ANDROID_PLATFORM="$(get_config_value android ANDROID_PLATFORM "android-24")"
DEFAULT_ARCHITECTURES=($(get_config_value android ARCHITECTURES "arm64-v8a x86_64 armeabi-v7a x86"))
DEFAULT_VERBOSE=false
DEFAULT_CLEAN=false

# --------------------------
# SCRIPT CONFIGURATION
# These variables are used internally by the script
# --------------------------
FORCE_BUILD="$DEFAULT_FORCE_BUILD"
BUILD_TYPE="${BUILD_TYPE:-$DEFAULT_BUILD_TYPE}"
ANDROID_PLATFORM="${ANDROID_PLATFORM:-$DEFAULT_ANDROID_PLATFORM}"
ARCHITECTURES=(${ARCHITECTURES:-${DEFAULT_ARCHITECTURES[*]}})
VERBOSE="$DEFAULT_VERBOSE"
CLEAN="$DEFAULT_CLEAN"

# Read values from config file if they exist
ANDROID_HOME="$(get_config_value android ANDROID_HOME "")"
ANDROID_NDK_PATH="$(get_config_value android ANDROID_NDK_PATH "")"
JAVA_HOME="$(get_config_value android JAVA_HOME "")"

# Update config file with defaults
update_config_value android ANDROID_PLATFORM "$DEFAULT_ANDROID_PLATFORM"
update_config_value android ARCHITECTURES "${DEFAULT_ARCHITECTURES[*]}"
update_config_value core BUILD_TYPE "$DEFAULT_BUILD_TYPE"

# Function to display help message
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build the Android SDK for Llama Mobile VD"
    echo ""
    echo "REQUIRED ENVIRONMENT VARIABLES:"
    echo "  ANDROID_HOME          Path to Android SDK installation"
    echo "  JAVA_HOME             Path to Java JDK installation (Java 11 recommended)"
    echo ""
    echo "OPTIONAL ENVIRONMENT VARIABLES:"
    echo "  ANDROID_NDK_PATH      Path to Android NDK installation (auto-detected)"
    echo "  CMAKE_PATH            Path to CMake executable"
    echo ""
    echo "OPTIONS:"
    echo "  --force                   Force rebuild even if libraries exist"
    echo "  --build-type <type>       Build type: Debug, Release (default: $DEFAULT_BUILD_TYPE)"
    echo "  --platform <platform>     Android platform (default: $DEFAULT_ANDROID_PLATFORM)"
    echo "  --arch <arch>             Single architecture to build (default: all supported)"
    echo "  -v, --verbose             Enable verbose output"
    echo "  -c, --clean               Clean existing build directories before building"
    echo "  -h, --help                Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Build with default settings"
    echo "  $0 --force"
    echo "  $0 --build-type Debug --arch arm64-v8a"
    echo "  $0 --clean --verbose        # Clean and build with verbose output"
    echo ""
    echo "Supported architectures: ${DEFAULT_ARCHITECTURES[*]}"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE_BUILD=true
            shift 1
            ;;
        --build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --build-type=*)
            BUILD_TYPE="${1#*=}"
            shift 1
            ;;
        --platform)
            ANDROID_PLATFORM="$2"
            shift 2
            ;;
        --platform=*)
            ANDROID_PLATFORM="${1#*=}"
            shift 1
            ;;
        --arch)
            ARCHITECTURES=("$2")  # Build only this architecture
            shift 2
            ;;
        --arch=*)
            ARCHITECTURES=("${1#*=}")
            shift 1
            ;;
        -v|--verbose)
            VERBOSE=true
            shift 1
            ;;
        -c|--clean)
            CLEAN=true
            shift 1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# Set the working directory to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WRAPPER_DIR="$PROJECT_ROOT/lib/wrapper"
ANDROID_DIR="$PROJECT_ROOT/llama_mobile_vd-android-SDK"

# NDK and CMake configuration
CMAKE_BUILD_TYPE="$BUILD_TYPE"

# Set default ANDROID_HOME if not set
if [ -z "$ANDROID_HOME" ]; then
    echo "🔍 ANDROID_HOME not set, trying to detect from system..."
    
    # Platform-specific detection - check common paths
    OS=$(uname -s)
    
    # Add more common paths for better detection
    if [ "$OS" = "Darwin" ]; then
        # macOS
        COMMON_PATHS=(
            "$HOME/Library/Android/sdk"
            "$HOME/android-sdk"
            "/Applications/Android Studio.app/Contents/sdk"
            "/Library/Android/sdk"
        )
    elif [ "$OS" = "Linux" ]; then
        # Linux
        COMMON_PATHS=(
            "$HOME/Android/Sdk"
            "$HOME/android-sdk"
            "/opt/android-sdk"
            "/usr/local/android-sdk"
            "/usr/android-sdk"
        )
    elif [[ "$OS" = MINGW* ]] || [[ "$OS" = CYGWIN* ]]; then
        # Windows (Git Bash or Cygwin)
        COMMON_PATHS=(
            "$USERPROFILE/AppData/Local/Android/Sdk"
            "$USERPROFILE/Android/Sdk"
            "C:/Android/Sdk"
            "C:/Program Files (x86)/Android/sdk"
            "C:/Users/Public/Android/Sdk"
        )
    else
        echo "❌ Unsupported operating system: $OS"
        exit 1
    fi
    
    # Check common paths
    for path in "${COMMON_PATHS[@]}"; do
        if [ -d "$path" ]; then
            # Verify it's actually an Android SDK directory by checking for key subdirectories
            if [ -d "$path/platforms" ] || [ -d "$path/build-tools" ] || [ -d "$path/ndk" ]; then
                ANDROID_HOME=$path
                echo "✅ Detected ANDROID_HOME: $ANDROID_HOME"
                # Update config file with detected value
                update_config_value android ANDROID_HOME "$ANDROID_HOME"
                break
            fi
        fi
    done
    
    # Final check: if still not found, prompt user with detailed instructions
    if [ -z "$ANDROID_HOME" ] || [ ! -d "$ANDROID_HOME" ]; then
        echo "❌ Failed to auto-detect ANDROID_HOME"
        echo ""
        echo "📋 How to set ANDROID_HOME:"
        echo ""
        echo "1. First, locate your Android SDK installation:"
        echo "   - On macOS: Typically in ~/Library/Android/sdk or /Applications/Android Studio.app/Contents/sdk"
        echo "   - On Linux: Typically in ~/Android/Sdk or /opt/android-sdk"
        echo "   - On Windows: Typically in %LOCALAPPDATA%/Android/Sdk or C:/Android/Sdk"
        echo ""
        echo "2. You can set it temporarily:"
        echo ""
        echo "On macOS/Linux:"
        echo "  export ANDROID_HOME=/path/to/your/android/sdk"
        echo "  ./scripts/build-android.sh"
        echo ""
        echo "On Windows (Git Bash):"
        echo "  export ANDROID_HOME=C:/path/to/your/android/sdk"
        echo "  ./scripts/build-android.sh"
        echo ""
        echo "On Windows (Command Prompt):"
        echo "  set ANDROID_HOME=C:\path\to\your\android\sdk"
        echo "  build-android.bat"
        echo ""
        echo "3. Or permanently add it to your environment variables:"
        echo "   - macOS/Linux: Add to ~/.bashrc, ~/.zshrc, or ~/.profile"
        echo "   - Windows: System Properties > Advanced > Environment Variables"
        echo ""
        echo "4. You can also edit the centralized config file directly:"
        echo "   - Open $CONFIG_FILE"
        echo "   - Add: ANDROID_HOME=/path/to/your/android/sdk under [android] section"
        echo ""
        exit 1
    fi
fi

# Verify ANDROID_HOME exists
if [ ! -d "$ANDROID_HOME" ]; then
    echo "❌ ANDROID_HOME path does not exist: $ANDROID_HOME"
    echo "Please set ANDROID_HOME to a valid Android SDK path."
    exit 1
fi

echo "Using ANDROID_HOME: $ANDROID_HOME"

# Set default ANDROID_NDK_PATH if not set
if [ -z "$ANDROID_NDK_PATH" ]; then
    echo "🔍 ANDROID_NDK_PATH not set, trying to detect from ANDROID_HOME..."
    if [ -d "$ANDROID_HOME/ndk" ]; then
        # Get the first available NDK version
        ANDROID_NDK_PATH=$(ls -d "$ANDROID_HOME/ndk"/*/ 2>/dev/null | head -n 1)
        if [ -n "$ANDROID_NDK_PATH" ]; then
            # Remove trailing slash
            ANDROID_NDK_PATH=${ANDROID_NDK_PATH%/}
            echo "✅ Detected ANDROID_NDK_PATH: $ANDROID_NDK_PATH"
            # Update config file with detected value
            update_config_value android ANDROID_NDK_PATH "$ANDROID_NDK_PATH"
        else
            echo "❌ No NDK versions found in $ANDROID_HOME/ndk"
            echo "Available NDK versions: $(ls -la $ANDROID_HOME/ndk/ 2>/dev/null || echo 'None found')"
            echo "Please install an NDK version using Android Studio SDK Manager."
            echo "You can also edit the ANDROID_NDK_PATH in $CONFIG_FILE under the [android] section."
            exit 1
        fi
    else
        echo "❌ ANDROID_HOME/ndk directory not found"
        echo "Please install an NDK version using Android Studio SDK Manager."
        echo "You can also edit the ANDROID_NDK_PATH in $CONFIG_FILE under the [android] section."
        exit 1
    fi
fi

ANDROID_NDK="$ANDROID_NDK_PATH"
CMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake"

# Check if NDK path is valid
echo -n "Checking for NDK at $ANDROID_NDK... "
if [ ! -d "$ANDROID_NDK" ]; then
    echo "✗"
    echo "Error: NDK not found at $ANDROID_NDK!"
    echo "Please check your ANDROID_NDK_PATH in $CONFIG_FILE."
    exit 1
fi
echo "✓"

# Check if the NDK contains the required toolchain file
echo -n "Checking for Android toolchain file... "
if [ ! -f "$CMAKE_TOOLCHAIN_FILE" ]; then
    echo "✗"
    echo "Error: Android toolchain file not found at $CMAKE_TOOLCHAIN_FILE!"
    echo "Please check your NDK installation or try a different NDK version."
    exit 1
fi
echo "✓"

# Check if cmake is installed
echo -n "Checking for cmake... "
if ! command -v cmake &> /dev/null; then
    echo "✗"
    echo "Error: cmake not found!"
    echo "Please install cmake using your system package manager."
    echo "On macOS: brew install cmake"
    echo "On Ubuntu: sudo apt install cmake"
    echo "On Windows: choco install cmake"
    exit 1
fi
echo "✓"

# Set the number of CPU cores for parallel build
echo -n "Detecting CPU cores for parallel build... "
n_cpu=1
if uname -a | grep -q "Darwin"; then
    n_cpu=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 1)
elif uname -a | grep -q "Linux"; then
    n_cpu=$(nproc 2>/dev/null || echo 1)
fi

echo "✓"
echo "Using $n_cpu cores for build"

# Step 1: Build the wrapper library for multiple architectures if needed
echo "=== Building QuiverDB frameworks for Android ==="

# Architecture list comes from command line arguments or environment variables

# Check if all libraries already exist
echo -n "Checking if Android libraries already exist... "
ALL_LIBRARIES_EXIST=true
for arch in "${ARCHITECTURES[@]}"; do
    if [ ! -f "$ANDROID_DIR/jniLibs/$arch/libquiverdb_wrapper.a" ]; then
        ALL_LIBRARIES_EXIST=false
        break
    fi
done

# Variable to track if we actually built libraries
LIBRARIES_BUILT=false

if [ "$ALL_LIBRARIES_EXIST" = true ] && [ "$FORCE_BUILD" = false ]; then
    echo "✓"
    echo "All Android libraries already exist in the destination directories."
    echo "Skipping rebuild (use --force to rebuild)"
else
    echo "✗"
    if [ "$FORCE_BUILD" = true ]; then
        echo "Force rebuild requested."
    else
        echo "Some libraries are missing, will rebuild."
    fi
    
    # Create build directories for each architecture
    build_library_for_architecture() {
        local arch=$1
        local build_dir="$PROJECT_ROOT/build-android-$arch"
        
        echo -n "Configuring CMake for Android $arch... "
        cmake -B "$build_dir" \
            -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" \
            -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
            -DANDROID_ABI="$arch" \
            -DANDROID_STL="c++_shared" \
            -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
            -DQUIVERDB_BUILD_TESTS=OFF \
            -DQUIVERDB_BUILD_BENCHMARKS=OFF \
            -DQUIVERDB_BUILD_EXAMPLES=OFF \
            -DQUIVERDB_BUILD_PYTHON=OFF \
            -DQUIVERDB_BUILD_CUDA=OFF \
            -DQUIVERDB_BUILD_METAL=OFF \
            "$WRAPPER_DIR"
        
        if [ $? -ne 0 ]; then
            echo "✗"
            echo "Error: CMake configuration failed for $arch"
            return 1
        fi
        echo "✓"
        
        echo -n "Building library for $arch with $n_cpu cores... "
        cmake --build "$build_dir" --config "$CMAKE_BUILD_TYPE" -j "$n_cpu"
        
        if [ $? -ne 0 ]; then
            echo "✗"
            echo "Error: Library build failed for $arch"
            return 1
        fi
        echo "✓"
        
        echo "✓ Wrapper library built successfully for $arch!"
        echo "Library location: $build_dir/libquiverdb_wrapper.a"
        
        return 0
    }
    
    # Build for all architectures
    for arch in "${ARCHITECTURES[@]}"; do
        if ! build_library_for_architecture "$arch"; then
            exit 1
        fi
    done
    
    LIBRARIES_BUILT=true
fi
if [ "$LIBRARIES_BUILT" = true ]; then
    echo ""
    
    # Step 2: Update the llama_mobile_vd-android-SDK directory
     echo "=== Updating llama_mobile_vd-android-SDK directory ==="
    
    # Create jniLibs directories for multiple architectures like the parent project
    JNI_LIBS_DEST="$ANDROID_DIR/jniLibs"
    
    # Copy libraries for all architectures
    for arch in "${ARCHITECTURES[@]}"; do
        build_dir="$PROJECT_ROOT/build-android-$arch"
        lib_path="$build_dir/libquiverdb_wrapper.a"
        
        if [ -f "$lib_path" ]; then
            # Copy to jniLibs directory structure (matching parent project)
            jni_lib_dir="$JNI_LIBS_DEST/$arch"
            mkdir -p "$jni_lib_dir"
            cp "$lib_path" "$jni_lib_dir/libquiverdb_wrapper.a"
            echo "✓ Library for $arch copied to: $jni_lib_dir/libquiverdb_wrapper.a"
        else
            echo "Error: Library not found at: $lib_path"
            exit 1
        fi
    done
    
    # Copy C header files
    HEADER_DEST="$ANDROID_DIR/include"
    mkdir -p $HEADER_DEST
    
    # Copy the wrapper header
    cp "$WRAPPER_DIR/include/quiverdb_wrapper.h" "$HEADER_DEST/"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy header files"
        exit 1
    fi
    
    echo "✓ Header files copied to: $HEADER_DEST"
    echo ""
    
    # Step 2.1: Update Android SDKs
     echo "=== Updating Android SDKs ==="
    
    JAVA_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-android-java-SDK"
    
    # Create a function to update an Android SDK
    update_android_sdk() {
        local sdk_dir=$1
        local sdk_name=$2
        
        if [ -d "$sdk_dir" ]; then
            # Update all architectures
            for arch in "${ARCHITECTURES[@]}"; do
                local build_dir="$PROJECT_ROOT/build-android-$arch"
                local lib_path="$build_dir/libquiverdb_wrapper.a"
                
                # Create jniLibs directory structure for this architecture
                local jni_libs_dir="$sdk_dir/src/main/jniLibs/$arch"
                mkdir -p "$jni_libs_dir"
                
                # Remove existing library if it exists
                if [ -f "$jni_libs_dir/libquiverdb_wrapper.a" ]; then
                    rm -f "$jni_libs_dir/libquiverdb_wrapper.a"
                fi
                
                # Copy the built library for this architecture
                cp "$lib_path" "$jni_libs_dir/"
                
                if [ $? -ne 0 ]; then
                    echo "Error: Failed to update $sdk_name for architecture $arch"
                    return 1
                fi
                
                echo "✓ $sdk_name updated at: $jni_libs_dir/libquiverdb_wrapper.a"
            done
        else
            echo "Warning: $sdk_name directory not found at: $sdk_dir"
            echo "Please create the SDK directory manually or use the build-all.sh script to build all SDKs"
        fi
        
        return 0
    }
    
    # Update Java SDK (kept separate as requested)
    update_android_sdk "$JAVA_SDK_DIR" "Android Java SDK"
    
    echo ""
    
    # Step 3: Verify the directory structure
     echo "=== Final Directory Structure ==="
     echo "llama_mobile_vd-android-SDK/"
     echo "├── jniLibs/"
     for arch in "${ARCHITECTURES[@]}"; do
        echo "│   ├── $arch/"
        echo "│   │   └── libquiverdb_wrapper.a"
     done
     echo "├── include/"
     echo "│   └── quiverdb_wrapper.h"
     echo "└── src/"
     echo "    └── main/"
     echo "        ├── cpp/"
     echo "        │   ├── CMakeLists.txt"
     echo "        │   └── llama_mobile_vd_jni.cpp"
     echo "        ├── java/"
     echo "        │   └── com/llamamobile/vd/LlamaMobileVD.java"
     echo "        └── kotlin/"
     echo "            └── com/llamamobile/vd/"
     echo "                ├── JNIInterface.kt"
     echo "                └── LlamaMobileVD.kt"
    echo ""
    
    # Step 4: Cleanup temporary build directories
     echo "=== Cleaning up temporary build directories ==="
     echo "Removing temporary build directories..."
    
    # Remove temporary build directories for all architectures
    for arch in "${ARCHITECTURES[@]}"; do
        build_dir="$PROJECT_ROOT/build-android-$arch"
        if [ -d "$build_dir" ] && [[ "$build_dir" == "$PROJECT_ROOT/build-android-"* ]]; then
            rm -rf "$build_dir"
            echo "✓ Removed temporary build directory: $build_dir"
        fi
    done
fi

echo ""
echo "Android build completed successfully!"
echo "llama_mobile_vd-android-SDK directory is now ready to use!"
echo "Architectures built: ${ARCHITECTURES[*]}"
echo ""
echo "- Consolidated Android SDK (includes Java and Kotlin): $ANDROID_DIR/"
echo "- Android Java SDK updated in: $JAVA_SDK_DIR/src/main/jniLibs/"
echo "- All temporary build directories have been cleaned up!"
echo ""
