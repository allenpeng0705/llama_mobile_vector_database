#!/bin/bash

# iOS build script for QuiverDB wrapper and Llama Mobile VD framework

# Parse command line arguments
FORCE_BUILD=false
for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE_BUILD=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Set the working directory to the project root
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$SCRIPT_DIR/.."
WRAPPER_DIR="$PROJECT_ROOT/lib/wrapper"
IOS_DIR="$PROJECT_ROOT/llama_mobile_vd-ios"
FRAMEWORK_NAME="LlamaMobileVD"

# Check if framework already exists
echo -n "Checking if iOS framework already exists... "
FRAMEWORK_DEST="$IOS_DIR/ios/Frameworks/$FRAMEWORK_NAME.framework"
SDK_FRAMEWORKS_DIR="$PROJECT_ROOT/llama_mobile_vd-ios-SDK/Frameworks"

if [ -d "$FRAMEWORK_DEST" ] && [ -f "$FRAMEWORK_DEST/$FRAMEWORK_NAME" ] && [ -d "$SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework" ] && [ "$FORCE_BUILD" = false ]; then
    echo "✓"
    echo "iOS framework already exists in the destination directories."
    echo "Skipping rebuild (use --force to rebuild)"
    FRAMEWORK_ALREADY_EXISTS=true
else
    echo "✗"
    if [ "$FORCE_BUILD" = true ]; then
        echo "Force rebuild requested."
    else
        echo "Some components are missing, will rebuild."
    fi
    FRAMEWORK_ALREADY_EXISTS=false
    
    # Step 1: Build the wrapper library
    echo "=== Building QuiverDB wrapper for iOS ==="
    
    # Create build directory in project root for wrapper
    WRAPPER_BUILD_DIR="$PROJECT_ROOT/build-ios"
    mkdir -p $WRAPPER_BUILD_DIR
    
    # Get absolute path to the iOS toolchain file
    IOS_TOOLCHAIN_FILE="$(cd "$PROJECT_ROOT" && pwd)/lib/llama_cpp/quiverdb/cmake/toolchains/ios.toolchain.cmake"
    
    # Configure CMake with iOS toolchain for frameworks
    cmake -B $WRAPPER_BUILD_DIR \
        -DCMAKE_TOOLCHAIN_FILE="$IOS_TOOLCHAIN_FILE" \
        -GXcode \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="13.0" \
        -DCMAKE_OSX_ARCHITECTURES="arm64" \
        -DCMAKE_OSX_SYSROOT="iphoneos" \
        -DQUIVERDB_BUILD_TESTS=OFF \
        -DQUIVERDB_BUILD_BENCHMARKS=OFF \
        -DQUIVERDB_BUILD_EXAMPLES=OFF \
        -DQUIVERDB_BUILD_PYTHON=OFF \
        -DQUIVERDB_BUILD_CUDA=OFF \
        -DQUIVERDB_BUILD_METAL=OFF \
        "$PROJECT_ROOT/lib/wrapper"
    
    if [ $? -ne 0 ]; then
        echo "Error: Wrapper library CMake configuration failed"
        exit 1
    fi
    
    # Build the wrapper library
    cmake --build $WRAPPER_BUILD_DIR --config Release -- -sdk iphoneos
    
    if [ $? -ne 0 ]; then
        echo "Error: Wrapper library build failed"
        exit 1
    fi
    
    echo "✓ Wrapper library built successfully!"
    echo "Library location: $WRAPPER_BUILD_DIR/Release-iphoneos/libquiverdb_wrapper.a"
    echo ""
    
    # Step 2: Build the iOS frameworks
    echo "=== Building iOS frameworks for Llama Mobile VD ==="
    
    # Create build directory in project root (temp directory)
    FRAMEWORK_BUILD_DIR="$PROJECT_ROOT/build-ios-framework"
    mkdir -p $FRAMEWORK_BUILD_DIR
    
    # Get absolute path to iOS directory
    IOS_DIR_ABS="$(cd "$IOS_DIR" && pwd)"
    
    # Configure CMake for iOS frameworks using absolute path
    cmake -B $FRAMEWORK_BUILD_DIR \
        -GXcode \
        -DCMAKE_SYSTEM_NAME="iOS" \
        -DCMAKE_OSX_ARCHITECTURES="arm64" \
        -DCMAKE_OSX_SYSROOT="iphoneos" \
        -DCMAKE_INSTALL_PREFIX="$FRAMEWORK_BUILD_DIR/install" \
        -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
        -DCMAKE_IOS_INSTALL_COMBINED=YES \
        "$IOS_DIR_ABS"
    
    if [ $? -ne 0 ]; then
        echo "Error: Framework CMake configuration failed"
        exit 1
    fi
    
    # Build the frameworks
    NUM_CORES=$(sysctl -n hw.logicalcpu)
    cmake --build $FRAMEWORK_BUILD_DIR --config Release -j $NUM_CORES
    
    if [ $? -ne 0 ]; then
        echo "Error: Framework build failed"
        exit 1
    fi
fi

if [ "$FRAMEWORK_ALREADY_EXISTS" = false ]; then
    
    # Step 3: Update the llama_mobile_vd-ios directory
     echo "=== Updating llama_mobile_vd-ios directory ==="
    
    # Set up the framework directory structure
    FRAMEWORK_DEST="$IOS_DIR/ios/Frameworks/$FRAMEWORK_NAME.framework"
    mkdir -p "$IOS_DIR/ios/Frameworks"
    
    # Copy the built frameworks
    if [ -d "$FRAMEWORK_BUILD_DIR/Release-iphoneos/$FRAMEWORK_NAME.framework" ]; then
        cp -R "$FRAMEWORK_BUILD_DIR/Release-iphoneos/$FRAMEWORK_NAME.framework" "$FRAMEWORK_DEST"
        echo "✓ frameworks copied to: $FRAMEWORK_DEST"
    else
        echo "Error: frameworks not found at: $FRAMEWORK_BUILD_DIR/Release-iphoneos/$FRAMEWORK_NAME.framework"
        exit 1
    fi
    
    # Copy the wrapper library to the framework's Resources directory
    echo "Copying wrapper library to framework..."
    mkdir -p "$FRAMEWORK_DEST/Resources"
    cp "$WRAPPER_BUILD_DIR/Release-iphoneos/libquiverdb_wrapper.a" "$FRAMEWORK_DEST/Resources/"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy wrapper library"
        exit 1
    fi
    
    echo "✓ Wrapper library copied to framework"
    
    # Step 3.1: Update the iOS Swift SDK
    echo "=== Updating iOS Swift SDK ==="
    
    IOS_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-ios-SDK"
    SDK_FRAMEWORKS_DIR="$IOS_SDK_DIR/Frameworks"
    
    # Check if iOS SDK directory exists
    if [ -d "$IOS_SDK_DIR" ]; then
        # Create Frameworks directory if it doesn't exist
        mkdir -p "$SDK_FRAMEWORKS_DIR"
        
        # Remove existing framework if it exists
        if [ -d "$SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework" ]; then
            rm -rf "$SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework"
        fi
        
        # Copy the built framework to the SDK
        cp -R "$FRAMEWORK_BUILD_DIR/Release-iphoneos/$FRAMEWORK_NAME.framework" "$SDK_FRAMEWORKS_DIR/"
        
        if [ $? -ne 0 ]; then
            echo "Error: Failed to update iOS Swift SDK"
            exit 1
        fi
        
        echo "✓ iOS Swift SDK updated at: $SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework"
    else
        echo "Warning: iOS Swift SDK directory not found at: $IOS_SDK_DIR"
        echo "Please create the SDK directory or run the build-ios-SDK.sh script to create it"
    fi
    
    # Step 4: Verify the directory structure
    echo ""
    echo "=== Final Directory Structure ==="
    echo "llama_mobile_vd-ios/"
    echo "├── ios/"
    echo "│   └── Frameworks/"
    echo "│       └── $FRAMEWORK_NAME.framework/"
    echo "│           ├── Headers/"
    echo "│           ├── Resources/"
    echo "│           │   └── libquiverdb_wrapper.a"
    echo "│           └── Info.plist"
    echo ""
    
    # Step 5: Cleanup temporary build directories
    echo ""
    echo "=== Cleaning up temporary build directories ==="
    echo "Removing temporary build directories..."
    
    # Remove temporary wrapper build directory if it exists and is in the project root
    if [ -d "$WRAPPER_BUILD_DIR" ] && [[ "$WRAPPER_BUILD_DIR" == "$PROJECT_ROOT/build-ios"* ]]; then
        rm -rf "$WRAPPER_BUILD_DIR"
        echo "✓ Removed temporary wrapper build directory: $WRAPPER_BUILD_DIR"
    fi
    
    # Remove temporary framework build directory if it exists and is in the project root
    if [ -d "$FRAMEWORK_BUILD_DIR" ] && [[ "$FRAMEWORK_BUILD_DIR" == "$PROJECT_ROOT/build-ios-framework"* ]]; then
        rm -rf "$FRAMEWORK_BUILD_DIR"
        echo "✓ Removed temporary framework build directory: $FRAMEWORK_BUILD_DIR"
    fi
fi

echo ""
echo "iOS build completed successfully!"
echo ""
echo "Summary:"
echo "- Wrapper library: $WRAPPER_BUILD_DIR/Release-iphoneos/libquiverdb_wrapper.a (cleaned up)"
echo "- iOS framework: $FRAMEWORK_DEST"
echo "- llama_mobile_vd-ios directory is now ready to use!"
echo "- iOS Swift SDK updated at: $SDK_FRAMEWORKS_DIR/$FRAMEWORK_NAME.framework"
echo "- All temporary build directories have been cleaned up!"
