#!/bin/bash -e

# ============================================================================
# IOS NATIVE FRAMEWORK BUILD SCRIPT for Llama Mobile VD
# Builds low-level iOS framework with proper xcframework structure
# Output: llama_mobile_vector_database/llama_mobile-ios/llama_mobile_vd.xcframework
# ============================================================================

# Load centralized configuration from config.env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

if [ -f "$CONFIG_FILE" ]; then
    # Extract all relevant variables from config.env, excluding comments
    export $(grep -E '^(IOS_BUILD_TYPE|IOS_SIMULATOR_ARCHES|IOS_DEVICE_ARCHES|IOS_DEPLOYMENT_TARGET)=' "$CONFIG_FILE" | sed 's/\s*#.*$//' | xargs)
fi

# Variables with defaults
BUILD_TYPE=${IOS_BUILD_TYPE:-"Release"}          # Release or Debug build
SIMULATOR_ARCHES=${IOS_SIMULATOR_ARCHES:-"arm64 x86_64"} # Simulator architectures
DEVICE_ARCHES=${IOS_DEVICE_ARCHES:-"arm64"}          # Device architectures
DEPLOYMENT_TARGET=${IOS_DEPLOYMENT_TARGET:-"14.0"}  # Minimum iOS version

# Build behavior flags
VERBOSE=false

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_message() {
    local level="INFO"
    local color="${BLUE}"
    local message="$1"
    
    if [[ "$message" =~ ^\[(ERROR|WARN|INFO|SUCCESS)\] ]]; then
        level="${BASH_REMATCH[1]}"
        message="${message:$((${#level} + 2))}"
        
        case "$level" in
            ERROR) color="${RED}" ;; 
            WARN) color="${YELLOW}" ;; 
            INFO) color="${BLUE}" ;; 
            SUCCESS) color="${GREEN}" ;; 
        esac
    fi
    
    echo -e "${color}[$(date '+%H:%M:%S')] [${level}] $message${NC}"
}

script_progress() {
    log_message "[INFO] $1"
}

verbose_output() {
    if [[ "$VERBOSE" == true ]]; then
        log_message "[INFO] $1"
    fi
}

handle_error() {
    local exit_code=$1
    local message="$2"
    log_message "[ERROR] $message"
    log_message "[ERROR] Build failed with exit code: $exit_code"
    exit $exit_code
}

# Show help message
show_help() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Builds low-level llama_mobile_vd iOS framework."
    echo ""
    echo "Options:"
    echo "  -h, --help         Show this help message and exit"
    echo "  --build-type=TYPE  Build type: Release or Debug (default: $BUILD_TYPE)"
    echo "  --verbose          Show verbose output"
    echo ""
    echo "Required Dependencies:"
    echo "  - Xcode with Command Line Tools"
    echo "  - CMake (version 3.16 or higher)"
    echo ""
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;; 
        --build-type=*) BUILD_TYPE="${1#*=}" ;; 
        --verbose) VERBOSE=true ;; 
        *) log_message "[ERROR] Unknown parameter: $1" ; show_help ;; 
    esac
    shift

done

# ============================================================================
# DEPENDENCY CHECKING
# ============================================================================

# Check for required dependencies
script_progress "Checking for required dependencies..."

# Check CMake
if ! command -v cmake &> /dev/null; then
  handle_error 1 "cmake could not be found. Please install it using: brew install cmake"
fi
log_message "[SUCCESS] Found CMake"

# Check Xcode command line tools
if ! command -v xcodebuild &> /dev/null; then
  handle_error 1 "Xcode command line tools could not be found. Please install Xcode and run: xcode-select --install"
fi
log_message "[SUCCESS] Found Xcode command line tools"

# Check xcrun
if ! command -v xcrun &> /dev/null; then
  handle_error 1 "xcrun could not be found. Please ensure Xcode is installed properly."
fi
log_message "[SUCCESS] Found xcrun"

# Check lipo
if ! command -v lipo &> /dev/null; then
  handle_error 1 "lipo could not be found. Please ensure Xcode is installed properly."
fi
log_message "[SUCCESS] Found lipo"

log_message "[SUCCESS] All required dependencies found"

# ============================================================================
# MAIN BUILD PROCESS
# ============================================================================

# Set directories
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/llama_mobile_vd-ios"
FRAMEWORK_NAME="llama_mobile_vd"
XCFRAMEWORK_PATH="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
WRAPPER_DIR="$ROOT_DIR/lib/wrapper"
CORE_LLAMA_DIR="$ROOT_DIR/lib/llama_cpp/quiverdb"

log_message "[INFO] === Building llama_mobile_vd iOS Native Framework ==="
log_message "[INFO] Build type: $BUILD_TYPE"
log_message "[INFO] Deployment target: $DEPLOYMENT_TARGET"
log_message "[INFO] Simulator arches: $SIMULATOR_ARCHES"
log_message "[INFO] Device arches: $DEVICE_ARCHES"
log_message "[INFO] Output: $XCFRAMEWORK_PATH"

# Clean output directory - preserving README.md
script_progress "Cleaning output directory..."

# Save README.md if it exists
if [ -f "$OUTPUT_DIR/README.md" ]; then
    # Save the README.md file temporarily
    mv "$OUTPUT_DIR/README.md" "$ROOT_DIR/temp_ios_README.md"
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Restore README.md if it was saved
if [ -f "$ROOT_DIR/temp_ios_README.md" ]; then
    mv "$ROOT_DIR/temp_ios_README.md" "$OUTPUT_DIR/README.md"
fi

log_message "[SUCCESS] Output directory cleaned"

# Build function for a specific target
build_target() {
    local SYSTEM_NAME="$1"
    local ARCHES="$2"
    local SYSROOT="$3"
    local OUTPUT_SUBDIR="$4"
    local BUILD_DIR="$5"
    
    script_progress "Building for $OUTPUT_SUBDIR..."
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Configure CMake for iOS with Xcode project
    cmake "$WRAPPER_DIR" \
        -GXcode \
        -DCMAKE_SYSTEM_NAME="$SYSTEM_NAME" \
        -DCMAKE_OSX_ARCHITECTURES="$ARCHES" \
        -DCMAKE_OSX_SYSROOT="$SYSROOT" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
        -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
        -DCMAKE_XCODE_ATTRIBUTE_SDKROOT="$SYSROOT" \
        -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
        -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH="NO"
    
    if [[ $? -ne 0 ]]; then
        handle_error 1 "CMake configuration failed for $OUTPUT_SUBDIR!"
    fi
    
    # Build the static library target
    cmake --build . --config "$BUILD_TYPE" --target llama_mobile_vd -j $(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)
    
    if [[ $? -ne 0 ]]; then
        handle_error 1 "Build failed for $OUTPUT_SUBDIR!"
    fi
    
    # Find the built static library
    local LIB_PATH="$BUILD_DIR/build/llama_mobile_vd.build/$BUILD_TYPE-$SYSROOT/libllama_mobile_vd.a"
    if [[ ! -f "$LIB_PATH" ]]; then
        LIB_PATH=$(find "$BUILD_DIR" -name "libllama_mobile_vd.a" | head -1)
        if [[ -z "$LIB_PATH" ]]; then
            handle_error 1 "Could not find the built static library!"
        fi
    fi
    
    # Create framework structure
    local DEST_PATH="$XCFRAMEWORK_PATH/$OUTPUT_SUBDIR/$FRAMEWORK_NAME.framework"
    mkdir -p "$DEST_PATH/Headers"
    mkdir -p "$DEST_PATH/Modules"
    
    # Copy the static library and rename it to match framework expectations
    cp "$LIB_PATH" "$DEST_PATH/$FRAMEWORK_NAME"
    
    # Copy headers
    cp "$WRAPPER_DIR/include/llama_mobile_vd_wrapper.h" "$DEST_PATH/Headers/"
    cp -r "$CORE_LLAMA_DIR/src/" "$DEST_PATH/Headers/quiverdb/" --include="*.h" --include="*.hpp" 2>/dev/null || true
    
    # Copy Metal files if they exist
    local METAL_FILES=()
    
    # Look for Metal files in multiple locations
    if [[ -d "$CORE_LLAMA_DIR/src" ]]; then
        METAL_FILES+=($(find "$CORE_LLAMA_DIR/src" -name "*.metal" 2>/dev/null))
    fi
    
    if [[ -d "$WRAPPER_DIR" ]]; then
        METAL_FILES+=($(find "$WRAPPER_DIR" -name "*.metal" 2>/dev/null))
    fi
    
    if [[ -d "$ROOT_DIR/lib/llama_cpp" ]]; then
        METAL_FILES+=($(find "$ROOT_DIR/lib/llama_cpp" -name "*.metal" 2>/dev/null))
    fi
    
    # Copy all found Metal files to the framework
    for METAL_FILE in "${METAL_FILES[@]}"; do
        if [[ -f "$METAL_FILE" ]]; then
            cp "$METAL_FILE" "$DEST_PATH/"
            log_message "[INFO] Copied Metal file: $(basename "$METAL_FILE")"
        fi
    done
    
    # Compile each Metal file into metallib if present
    for METAL_FILE in "${METAL_FILES[@]}"; do
        if [[ -f "$METAL_FILE" ]]; then
            METAL_FILE_NAME=$(basename "$METAL_FILE")
            if [[ -f "$DEST_PATH/$METAL_FILE_NAME" && -x "$(which xcrun)" ]]; then
                # Get the correct SDK path based on target
                local METAL_SDK="iphoneos"
                if [[ "$OUTPUT_SUBDIR" == *"simulator"* ]]; then
                    METAL_SDK="iphonesimulator"
                fi
                
                # Copy necessary headers for Metal compilation
                cp -r "$DEST_PATH/Headers/quiverdb/" "$DEST_PATH/" 2>/dev/null || true
                cp -r "$CORE_LLAMA_DIR/src/" "$DEST_PATH/" --include="*.h" --include="*.hpp" 2>/dev/null || true
                cp "$ROOT_DIR/lib/llama_cpp/ggml-common.h" "$DEST_PATH/" 2>/dev/null || true
                cp "$ROOT_DIR/lib/llama_cpp/ggml-metal-impl.h" "$DEST_PATH/" 2>/dev/null || true
                
                # Try to compile Metal from source first
                cd "$DEST_PATH"
                local METAL_COMPILED=false
                
                xcrun -sdk $METAL_SDK metal -I. -std=metal3.0 -mios-version-min=$DEPLOYMENT_TARGET "$METAL_FILE_NAME" -o "ggml-llama.metallib" 2>/dev/null && {
                    log_message "[SUCCESS] Compiled ggml-metal.metal from source for $OUTPUT_SUBDIR"
                    METAL_COMPILED=true
                } || {
                    log_message "[WARN] Metal compilation from source failed, falling back to pre-compiled libraries"
                    
                    # Copy pre-compiled Metal library files from reference repository
                    local REF_METALLIB_DIR="/Users/shileipeng/Documents/mygithub/llama_mobile/lib/llama_cpp"
                    
                    # Copy both device and simulator metallib files
                    cp "$REF_METALLIB_DIR/ggml-llama.metallib" "$DEST_PATH/" 2>/dev/null || true
                    cp "$REF_METALLIB_DIR/ggml-llama-sim.metallib" "$DEST_PATH/" 2>/dev/null || true
                }
                
                # Clean up copied headers
                rm -rf "$DEST_PATH/quiverdb" "$DEST_PATH/src" "$DEST_PATH/ggml-common.h" "$DEST_PATH/ggml-metal-impl.h" 2>/dev/null || true
                
                # Verify metallib files are available
                if [[ -f "$DEST_PATH/ggml-llama.metallib" ]] || [[ -f "$DEST_PATH/ggml-llama-sim.metallib" ]]; then
                    if [[ $METAL_COMPILED == true ]]; then
                        log_message "[SUCCESS] Using Metal library compiled from source for $OUTPUT_SUBDIR"
                    else
                        log_message "[SUCCESS] Using pre-compiled Metal library for $OUTPUT_SUBDIR"
                    fi
                else
                    log_message "[ERROR] No Metal library available for $OUTPUT_SUBDIR"
                fi
            fi
        fi
    done
    
    # Create Modules directory and module.modulemap
    cat > "$DEST_PATH/Modules/module.modulemap" << EOF
framework module $FRAMEWORK_NAME {
    umbrella header "llama_mobile_vd_wrapper.h"
    
    export *
    module * { export * }
    
    link "$FRAMEWORK_NAME"
}
EOF
    
    # Create Info.plist for the framework
    cat > "$DEST_PATH/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.llamamobile.vd</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>$DEPLOYMENT_TARGET</string>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
</dict>
</plist>
EOF
    
    # Clean up
    cd "$ROOT_DIR"
    rm -rf "$BUILD_DIR"
    
    log_message "[SUCCESS] Built $OUTPUT_SUBDIR framework"
}

# Build simulator variants
for ARCH in $SIMULATOR_ARCHES; do
    build_target "iOS" "$ARCH" "iphonesimulator" "ios-${ARCH}-simulator" "$ROOT_DIR/build-ios-simulator-${ARCH}"
done

# Build device variants
for ARCH in $DEVICE_ARCHES; do
    build_target "iOS" "$ARCH" "iphoneos" "ios-${ARCH}" "$ROOT_DIR/build-ios-device-${ARCH}"
done

# Combine simulator architectures if needed
if [[ $(echo $SIMULATOR_ARCHES | wc -w) -gt 1 ]]; then
    script_progress "Combining simulator architectures..."
    
    # Create combined simulator directory
    COMBINED_SIM_DIR="$XCFRAMEWORK_PATH/ios-$(echo $SIMULATOR_ARCHES | tr ' ' '_')-simulator"
    mkdir -p "$COMBINED_SIM_DIR"
    
    # Copy first simulator framework as base
    FIRST_SIM_ARCH=$(echo $SIMULATOR_ARCHES | awk '{print $1}')
    cp -R "$XCFRAMEWORK_PATH/ios-${FIRST_SIM_ARCH}-simulator/$FRAMEWORK_NAME.framework" "$COMBINED_SIM_DIR/"
    
    # Combine binary files
    SIM_BINARIES=()
    for ARCH in $SIMULATOR_ARCHES; do
        SIM_BINARIES+=("$XCFRAMEWORK_PATH/ios-${ARCH}-simulator/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME")
    done
    
    lipo -create "${SIM_BINARIES[@]}" -output "$COMBINED_SIM_DIR/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
    
    # Clean up individual simulator directories
    for ARCH in $SIMULATOR_ARCHES; do
        rm -rf "$XCFRAMEWORK_PATH/ios-${ARCH}-simulator"
    done
    
    log_message "[SUCCESS] Combined simulator architectures"
fi

# Create XCFramework using xcodebuild
script_progress "Creating final XCFramework..."

# Get all framework paths
FRAMEWORK_PATHS=()
for DIR in "$XCFRAMEWORK_PATH"/*; do
    if [[ -d "$DIR" ]]; then
        FRAMEWORK_PATHS+=(-framework "$DIR/$FRAMEWORK_NAME.framework")
    fi
done

# Use xcodebuild to create proper XCFramework
TEMP_XCFRAMEWORK="$OUTPUT_DIR/$FRAMEWORK_NAME-temp.xcframework"
xcodebuild -create-xcframework "${FRAMEWORK_PATHS[@]}" -output "$TEMP_XCFRAMEWORK"

# Replace with new XCFramework
rm -rf "$XCFRAMEWORK_PATH"
mv "$TEMP_XCFRAMEWORK" "$XCFRAMEWORK_PATH"

# Fix Info.plist encoding
log_message "[INFO] Fixing Info.plist encoding..."
find "$XCFRAMEWORK_PATH" -name "*.plist" -exec plutil -convert xml1 {} \;

# Add RequiredFrameworks and RequiredLibraries to XCFramework Info.plist
log_message "[INFO] Adding required dependencies to XCFramework Info.plist..."
XCFRAMEWORK_INFO_PLIST="$XCFRAMEWORK_PATH/Info.plist"

# Get the number of AvailableLibraries entries
LIBRARY_COUNT=$(/usr/libexec/PlistBuddy -c "Print :AvailableLibraries:" "$XCFRAMEWORK_INFO_PLIST" 2>/dev/null | grep -c "Dict")

if [[ $LIBRARY_COUNT -gt 0 ]]; then
    for ((INDEX=0; INDEX<LIBRARY_COUNT; INDEX++)); do
        # Add RequiredFrameworks
        /usr/libexec/PlistBuddy -c "Add :AvailableLibraries:$INDEX:RequiredFrameworks array" "$XCFRAMEWORK_INFO_PLIST" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :AvailableLibraries:$INDEX:RequiredFrameworks:0 string 'Accelerate'" "$XCFRAMEWORK_INFO_PLIST" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :AvailableLibraries:$INDEX:RequiredFrameworks:1 string 'Metal'" "$XCFRAMEWORK_INFO_PLIST" 2>/dev/null || true
        
        # Add RequiredLibraries
        /usr/libexec/PlistBuddy -c "Add :AvailableLibraries:$INDEX:RequiredLibraries array" "$XCFRAMEWORK_INFO_PLIST" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :AvailableLibraries:$INDEX:RequiredLibraries:0 string 'libc++'" "$XCFRAMEWORK_INFO_PLIST" 2>/dev/null || true
    done
    log_message "[INFO] Added dependencies to $LIBRARY_COUNT library variants"
else
    log_message "[WARN] No AvailableLibraries found in XCFramework Info.plist"
fi

log_message "[INFO] Added Accelerate framework and libc++ as required dependencies"

# Clean up any temporary build directories
rm -rf "$ROOT_DIR/build-ios-*"

# Verify the build
script_progress "Verifying framework..."

# Check XCFramework structure
if [[ -d "$XCFRAMEWORK_PATH" ]]; then
    log_message "[SUCCESS] XCFramework structure created at $XCFRAMEWORK_PATH"
    log_message "[INFO] Contains: $(ls -la "$XCFRAMEWORK_PATH" | grep ^d | awk '{print $9}')"
    
    # Check each framework variant
    for VARIANT in "$XCFRAMEWORK_PATH"/*; do
        if [[ -d "$VARIANT" ]]; then
            FRAMEWORK="$VARIANT/$FRAMEWORK_NAME.framework"
            if [[ -f "$FRAMEWORK/$FRAMEWORK_NAME" ]]; then
                ARCHES=$(lipo -info "$FRAMEWORK/$FRAMEWORK_NAME" | grep -o "architecture.*" | cut -d ' ' -f 2-)
                log_message "[INFO] $(basename "$VARIANT"): $ARCHES"
                
                # Check framework contents
                log_message "[INFO]   - Framework contents: $(ls -la "$FRAMEWORK" | awk '{print $9}')"
            fi
        fi
    done
    
    log_message "[SUCCESS] ✅ iOS Core XCFramework built successfully!"
    log_message "[SUCCESS] XCFramework path: $XCFRAMEWORK_PATH"
else
    handle_error 1 "XCFramework not found at expected location!"
fi