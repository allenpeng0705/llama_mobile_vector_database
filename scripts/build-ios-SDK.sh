#!/bin/bash -e

# ============================================================================
# IOS SDK BUILD SCRIPT
# Takes pre-built iOS framework from llama_mobile-ios and creates iOS SDK
# Output: llama_mobile_vector_database/llama_mobile_vd-ios-SDK/LlamaMobileVDBundle/
# ============================================================================

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%H:%M:%S')"
    echo "[$timestamp] [$level] $message"
}

# Directory paths
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAMEWORK_DIR="$ROOT_DIR/llama_mobile_vd-ios"
SDK_DIR="$ROOT_DIR/llama_mobile_vd-ios-SDK"
BUNDLE_DIR="$SDK_DIR/LlamaMobileVDBundle"
FRAMEWORK_NAME="LlamaMobileVD"
XCFRAMEWORK_NAME="llama_mobile_vd.xcframework"
SDK_BACKUP_DIR="$ROOT_DIR/scripts/sdk_backup"

# Create backup directory if it doesn't exist
mkdir -p "$SDK_BACKUP_DIR"

# Function to backup SDK
backup_sdk() {
    local sdk_dir="$1"
    local sdk_name="$(basename "$sdk_dir")"
    local timestamp="$(date '+%Y%m%d_%H%M%S')"
    local backup_name="${sdk_name}_${timestamp}"
    local backup_path="$SDK_BACKUP_DIR/$backup_name"
    
    log_message "INFO" "Backing up $sdk_name to $backup_path"
    
    # Create backup as directory copy
    cp -r "$sdk_dir" "$backup_path"
    
    if [ $? -eq 0 ]; then
        log_message "INFO" "Backup completed successfully: $backup_path"
    else
        log_message "ERROR" "Failed to create backup"
    fi
}

# Main script execution

log_message "INFO" "Starting iOS SDK build process..."

# Backup SDK if it exists
if [ -d "$SDK_DIR" ]; then
    backup_sdk "$SDK_DIR"
fi

# Check if framework exists
if [ ! -d "$FRAMEWORK_DIR/llama_mobile_vd.xcframework" ]; then
    log_message "ERROR" "Framework not found at $FRAMEWORK_DIR/llama_mobile_vd.xcframework"
    log_message "INFO" "Please run build-ios-framework.sh first to build the iOS framework"
    exit 1
fi

log_message "INFO" "Found pre-built framework at $FRAMEWORK_DIR/llama_mobile_vd.xcframework"

# Create bundle directory if it doesn't exist
if [ ! -d "$BUNDLE_DIR" ]; then
    log_message "INFO" "Creating bundle directory at $BUNDLE_DIR"
    mkdir -p "$BUNDLE_DIR"
fi

# Clean only the xcframework directory
log_message "INFO" "Cleaning xcframework directory..."
rm -rf "$BUNDLE_DIR/$XCFRAMEWORK_NAME"

# Copy and rename the framework to bundle directory
log_message "INFO" "Copying framework to bundle directory..."
cp -R "$FRAMEWORK_DIR/llama_mobile_vd.xcframework" "$BUNDLE_DIR/$XCFRAMEWORK_NAME"

# Verify the Swift wrapper exists
if [ ! -d "$BUNDLE_DIR/Sources/$FRAMEWORK_NAME" ]; then
    log_message "INFO" "Creating Swift wrapper directory structure..."
    mkdir -p "$BUNDLE_DIR/Sources/$FRAMEWORK_NAME"
fi

# Ensure the framework name is correct in imports
if [ -f "$BUNDLE_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift" ]; then
    log_message "INFO" "Fixing framework import in Swift wrapper..."
    sed -i '' 's/import LlamaMobileVDBundle/import llama_mobile_vd/g' "$BUNDLE_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift"
    sed -i '' 's/import LlamaMobileVD/import llama_mobile_vd/g' "$BUNDLE_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift"
fi

# Check framework structure
if [ -f "$BUNDLE_DIR/$XCFRAMEWORK_NAME/ios-arm64/llama_mobile_vd.framework/Headers/llama_mobile_vd_wrapper.h" ] && \
   [ -f "$BUNDLE_DIR/$XCFRAMEWORK_NAME/ios-arm64_x86_64-simulator/llama_mobile_vd.framework/Headers/llama_mobile_vd_wrapper.h" ]; then
    log_message "SUCCESS" "Framework headers are accessible"
else
    log_message "ERROR" "Framework headers not found"
    exit 1
fi

# Check Swift wrapper
if grep -q "import llama_mobile_vd" "$BUNDLE_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift"; then
    log_message "SUCCESS" "Swift wrapper properly imports llama_mobile_vd module"
else
    log_message "ERROR" "Swift wrapper does not import llama_mobile_vd module"
    exit 1
fi

# Verify the framework has the correct dependency information
log_message "INFO" "Verifying framework dependencies..."

if grep -q "RequiredFrameworks" "$BUNDLE_DIR/$XCFRAMEWORK_NAME/Info.plist" && grep -q "Accelerate" "$BUNDLE_DIR/$XCFRAMEWORK_NAME/Info.plist" && grep -q "libc++" "$BUNDLE_DIR/$XCFRAMEWORK_NAME/Info.plist"; then
    log_message "SUCCESS" "Framework has correct dependency information (Accelerate, libc++)"
else
    log_message "WARNING" "Framework is missing dependency information. Ensure build-ios-framework.sh was run with dependency updates."
fi



log_message "SUCCESS" "iOS SDK bundle created successfully!"
log_message "INFO" ""
log_message "INFO" "Bundle Location: $BUNDLE_DIR"
log_message "INFO" "Framework: $BUNDLE_DIR/$XCFRAMEWORK_NAME"
log_message "INFO" "Swift Wrapper: $BUNDLE_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift"
log_message "INFO" "Examples: $BUNDLE_DIR/Examples/"
log_message "INFO" "Tests: $BUNDLE_DIR/Tests/"
log_message "INFO" ""
log_message "INFO" "To use the SDK in your iOS project:"
log_message "INFO" "1. Copy the entire LlamaMobileVDBundle folder to your project"
log_message "INFO" "2. In Xcode, drag and drop LlamaMobileVDBundle.xcframework into your project"
log_message "INFO" "3. In the 'Frameworks, Libraries, and Embedded Content' section of your target settings, add the framework"
log_message "INFO" "4. Add Sources/LlamaMobileVD/LlamaMobileVD.swift to your project"
log_message "INFO" "5. Import LlamaMobileVDBundle in your Swift files"
log_message "INFO" "6. Use the vector database API as demonstrated in README.md and Examples/"
log_message "INFO" ""
log_message "INFO" "For detailed documentation, see: $BUNDLE_DIR/README.md"
log_message "INFO" ""
