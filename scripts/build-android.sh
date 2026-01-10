#!/bin/bash -e

# Android build script for QuiverDB wrapper and Llama Mobile VD library

# Parse command line arguments
FORCE_BUILD=false
NDK_VERSION="29.0.14206865"  # Default NDK version
for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE_BUILD=true
            shift
            ;;
        --ndk-version=*)
            NDK_VERSION="${arg#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Set the working directory to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WRAPPER_DIR="$PROJECT_ROOT/lib/wrapper"
ANDROID_DIR="$PROJECT_ROOT/llama_mobile_vd-android-SDK"

# NDK and CMake configuration
ANDROID_PLATFORM=android-24
CMAKE_BUILD_TYPE=Release

# Set default ANDROID_HOME if not set
if [ -z "$ANDROID_HOME" ]; then
    echo "ANDROID_HOME not set, trying to detect from system..."
    
    # Platform-specific detection - check common paths only
    OS=$(uname -s)
    
    if [ "$OS" = "Darwin" ]; then
        # macOS
        COMMON_PATHS=("$HOME/Library/Android/sdk" "$HOME/android-sdk")
    elif [ "$OS" = "Linux" ]; then
        # Linux
        COMMON_PATHS=("$HOME/Android/Sdk" "$HOME/android-sdk" "/opt/android-sdk")
    elif [[ "$OS" = MINGW* ]]; then
        # Windows (Git Bash)
        COMMON_PATHS=("$USERPROFILE/AppData/Local/Android/Sdk" "$USERPROFILE/Android/Sdk")
    else
        echo "❌ Unsupported operating system: $OS"
        exit 1
    fi
    
    # Check common paths first (fast and reliable)
    for path in "${COMMON_PATHS[@]}"; do
        if [ -d "$path" ]; then
            ANDROID_HOME=$path
            echo "✅ Detected ANDROID_HOME: $ANDROID_HOME"
            break
        fi
    done
    
    # Final check: if still not found, prompt user
    if [ -z "$ANDROID_HOME" ] || [ ! -d "$ANDROID_HOME" ]; then
        echo "❌ Failed to auto-detect ANDROID_HOME"
        echo ""
        echo "Please set the ANDROID_HOME environment variable manually:"
        echo ""
        echo "On macOS/Linux:"
        echo "  export ANDROID_HOME=/path/to/your/android/sdk"
        echo "  ./scripts/build-android.sh"
        echo ""
        echo "On Windows (Git Bash):"
        echo "  export ANDROID_HOME=C:/path/to/your/android/sdk"
        echo "  ./scripts/build-android.sh"
        echo ""
        echo "Or set it permanently in your shell configuration:"
        echo "  (e.g., add to ~/.bashrc, ~/.zshrc, or ~/.profile)"
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
ANDROID_NDK="$ANDROID_HOME/ndk/$NDK_VERSION"
CMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake"

# Check if NDK is installed
echo -n "Checking for NDK $NDK_VERSION... "
if [ ! -d "$ANDROID_NDK" ]; then
    echo "✗"
    echo "Error: NDK $NDK_VERSION not found at $ANDROID_NDK!"
    echo "Available NDK versions: $(ls -la $ANDROID_HOME/ndk/ 2>/dev/null || echo 'None found')"
    echo "Please install NDK $NDK_VERSION or update the NDK_VERSION in this script."
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

# Define architectures to build for
ARCHITECTURES=("arm64-v8a" "x86_64")

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
