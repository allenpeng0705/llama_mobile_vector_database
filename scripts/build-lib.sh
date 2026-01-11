#!/bin/bash

# Desktop build script for QuiverDB wrapper corelib
# Enhanced for cross-platform compatibility and user configurability

# Set the working directory to the project root
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$SCRIPT_DIR/.."
WRAPPER_DIR="$PROJECT_ROOT/lib/wrapper"

# ==========================
# CENTRAL CONFIGURATION
# Read settings from centralized config.env file if it exists
# ==========================

# Paths
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    echo "Please run the scripts from the project root directory"
    exit 1
fi

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

# Default configuration
DEFAULT_GENERATOR="Xcode"  # Default to Xcode on macOS
DEFAULT_BUILD_TYPE="$(get_config_value core BUILD_TYPE "Release")"
DEFAULT_BUILD_DIR="$PROJECT_ROOT/$(get_config_value core BUILD_DIR "build-lib")"
DEFAULT_SKIP_TESTS=false
DEFAULT_VERBOSE="$(get_config_value core VERBOSE "false")"
DEFAULT_NUM_CORES="$(get_config_value core NUM_CORES "0")"  # 0 means auto-detect
DEFAULT_CLEAN=false  # Whether to clean old build directories

# Update config file with defaults
update_config_value core BUILD_TYPE "$DEFAULT_BUILD_TYPE"
update_config_value core BUILD_DIR "$(basename "$DEFAULT_BUILD_DIR")"
update_config_value core VERBOSE "$DEFAULT_VERBOSE"
update_config_value core NUM_CORES "$DEFAULT_NUM_CORES"

# Configuration variables (can be overridden by command line arguments)
GENERATOR="$DEFAULT_GENERATOR"
BUILD_TYPE="$DEFAULT_BUILD_TYPE"
BUILD_DIR="$DEFAULT_BUILD_DIR"
SKIP_TESTS="$DEFAULT_SKIP_TESTS"
VERBOSE="$DEFAULT_VERBOSE"
NUM_CORES="$DEFAULT_NUM_CORES"
CLEAN="$DEFAULT_CLEAN"

# Detect operating system
OS="$(uname -s)"
case "$OS" in
    Darwin*)    OS="macOS";;
    Linux*)     OS="Linux";;
    CYGWIN*)    OS="Windows";;
    MINGW*)     OS="Windows";;
    MSYS_NT*)   OS="Windows";;
    *)          OS="Unknown";;
esac

# Get number of cores for parallel build (cross-platform)
get_num_cores() {
    if [ "$NUM_CORES" -gt 0 ]; then
        echo "$NUM_CORES"
        return
    fi
    
    case "$OS" in
        "macOS")
            sysctl -n hw.logicalcpu 2>/dev/null || echo 4
            ;;
        "Linux")
            nproc 2>/dev/null || echo 4
            ;;
        "Windows")
            echo %NUMBER_OF_PROCESSORS% 2>/dev/null || echo 4
            ;;
        *)
            echo 4
            ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Function to display warning message
warning() {
    echo "Warning: $1" >&2
}

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build the QuiverDB wrapper core library"
    echo ""
    echo "Options:"
    echo "  -g, --generator <generator>  CMake generator to use (default: $DEFAULT_GENERATOR)"
    echo "  -t, --type <build_type>      Build type: Debug, Release, RelWithDebInfo (default: $DEFAULT_BUILD_TYPE)"
    echo "  -d, --dir <build_dir>        Build directory (default: $DEFAULT_BUILD_DIR)"
    echo "  -j, --jobs <num>             Number of parallel jobs (default: auto-detect)"
    echo "  -s, --skip-tests             Skip running tests after build"
    echo "  -c, --clean                  Clean existing build directories before building"
    echo "  -v, --verbose                Enable verbose output"
    echo "  -h, --help                   Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Build with default settings"
    echo "  $0 --generator Ninja --type Debug"
    echo "  $0 --dir build-debug -j 8 --skip-tests"
    echo "  $0 --clean -v               # Clean and build with verbose output"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -g|--generator)
            GENERATOR="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -d|--dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        -j|--jobs)
            NUM_CORES="$2"
            shift 2
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift 1
            ;;
        -c|--clean)
            CLEAN=true
            shift 1
            ;;
        -v|--verbose)
            VERBOSE=true
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

# Detect number of cores
NUM_CORES=$(get_num_cores)

# Check if CMake is installed
if ! command_exists cmake; then
    error_exit "CMake is not installed. Please install CMake first."
fi

# Display build configuration
echo "=== QuiverDB Core Library Build Configuration ==="
echo "Operating System: $OS"
echo "Generator: $GENERATOR"
echo "Build Type: $BUILD_TYPE"
echo "Build Directory: $BUILD_DIR"
echo "Parallel Jobs: $NUM_CORES"
echo "Run Tests: $([ "$SKIP_TESTS" = true ] && echo "No" || echo "Yes")"
echo "Verbose: $VERBOSE"
echo "=================================================="

# Function to build library with specific type (static or shared)
build_library() {
    local LIB_TYPE=$1  # "static" or "shared"
    local SHARED_OPTION=$2  # "OFF" or "ON"
    local LIB_BUILD_DIR="$BUILD_DIR-$LIB_TYPE"
    
    echo "\n=== Building $LIB_TYPE library ==="
    
    # Clean existing build directory if requested
    if [ "$CLEAN" = true ]; then
        if [ -d "$LIB_BUILD_DIR" ]; then
            echo "Cleaning existing build directory: $LIB_BUILD_DIR"
            rm -rf "$LIB_BUILD_DIR"
        fi
    fi
    
    # Create build directory
    echo "Creating build directory: $LIB_BUILD_DIR"
    mkdir -p "$LIB_BUILD_DIR"
    
    # Configure CMake
    echo "Configuring CMake for $LIB_TYPE build..."
    
    # Build CMake command
    CMAKE_CMD="cmake -B '$LIB_BUILD_DIR' -G '$GENERATOR' -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DBUILD_SHARED_LIBS=$SHARED_OPTION \
        -DQUIVERDB_BUILD_TESTS=ON \
        -DQUIVERDB_BUILD_BENCHMARKS=OFF \
        -DQUIVERDB_BUILD_EXAMPLES=OFF \
        -DQUIVERDB_BUILD_PYTHON=OFF \
        -DQUIVERDB_BUILD_CUDA=OFF \
        -DQUIVERDB_BUILD_METAL=OFF \
        '$WRAPPER_DIR'"
    
    if [ "$VERBOSE" = true ]; then
        echo "Executing: $CMAKE_CMD"
    fi
    
    # Execute CMake configuration
    eval $CMAKE_CMD
    
    if [ $? -ne 0 ]; then
        error_exit "CMake configuration failed for $LIB_TYPE build"
    fi
    
    # Build the library
    echo "Building $LIB_TYPE library with $NUM_CORES cores..."
    
    # Build the build command
    BUILD_CMD="cmake --build '$LIB_BUILD_DIR' --config $BUILD_TYPE -j $NUM_CORES"
    
    if [ "$VERBOSE" = true ]; then
        echo "Executing: $BUILD_CMD"
    fi
    
    # Execute the build
    eval $BUILD_CMD
    
    if [ $? -ne 0 ]; then
        error_exit "$LIB_TYPE build failed"
    fi
    
    # Determine library file extension based on OS and library type
    if [ "$SHARED_OPTION" = "ON" ]; then
        case "$OS" in
            "macOS")
                LIB_EXT=".dylib"
                ;;
            "Linux")
                LIB_EXT=".so"
                ;;
            "Windows")
                LIB_EXT=".dll"
                ;;
            *)
                LIB_EXT=".so"
                ;;
        esac
    else
        case "$OS" in
            "macOS"|"Linux")
                LIB_EXT=".a"
                ;;
            "Windows")
                LIB_EXT=".lib"
                ;;
            *)
                LIB_EXT=".a"
                ;;
        esac
    fi
    
    # Determine the path to the built library
    case "$GENERATOR" in
        "Xcode")
            LIB_PATH="$LIB_BUILD_DIR/$BUILD_TYPE/libquiverdb_wrapper$LIB_EXT"
            TEST_PATH="$LIB_BUILD_DIR/$BUILD_TYPE/quiverdb_wrapper_test"
            ;;
        "Visual Studio*")
            # Visual Studio puts binaries in architecture-specific subdirectories
            LIB_PATH="$LIB_BUILD_DIR/$BUILD_TYPE/libquiverdb_wrapper$LIB_EXT"
            TEST_PATH="$LIB_BUILD_DIR/$BUILD_TYPE/quiverdb_wrapper_test.exe"
            ;;
        *)
            # Most other generators use this structure
            LIB_PATH="$LIB_BUILD_DIR/libquiverdb_wrapper$LIB_EXT"
            TEST_PATH="$LIB_BUILD_DIR/quiverdb_wrapper_test"
            ;;
    esac
    
    echo ""
    echo "✓ $LIB_TYPE library build completed successfully!"
    echo "Library location: $LIB_PATH"
    echo "Test executables location: $TEST_PATH"
    
    # Return build directory for testing
    echo "$LIB_BUILD_DIR"
}

# Build both static and shared libraries
STATIC_BUILD_DIR=$(build_library "static" "OFF")
SHARED_BUILD_DIR=$(build_library "shared" "ON")

# Use static build for testing (more reliable for testing)
TEST_BUILD_DIR=$STATIC_BUILD_DIR

# Function to run tests using CTest
run_tests_ctest() {
    echo ""
    echo "=== Running tests using CTest ==="
    cd "$TEST_BUILD_DIR"
    
    CTEST_CMD="ctest -C $BUILD_TYPE"
    if [ "$VERBOSE" = true ]; then
        echo "Executing: $CTEST_CMD"
    fi
    
    eval $CTEST_CMD
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ All tests passed with CTest!"
    else
        error_exit "Some tests failed with CTest!"
    fi
}

# Function to run tests directly for detailed output
run_tests_direct() {
    echo ""
    echo "=== Running tests directly for detailed output ==="
    
    # Determine test executable path based on generator
    case "$GENERATOR" in
        "Xcode")
            TEST_EXECUTABLE="$TEST_BUILD_DIR/$BUILD_TYPE/quiverdb_wrapper_test"
            ;;
        "Visual Studio*")
            TEST_EXECUTABLE="$TEST_BUILD_DIR/$BUILD_TYPE/quiverdb_wrapper_test.exe"
            ;;
        *)
            TEST_EXECUTABLE="$TEST_BUILD_DIR/quiverdb_wrapper_test"
            ;;
    esac
    
    if [ -f "$TEST_EXECUTABLE" ]; then
        if [ "$VERBOSE" = true ]; then
            echo "Executing: $TEST_EXECUTABLE"
        fi
        "$TEST_EXECUTABLE"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✓ All tests passed with direct execution!"
        else
            error_exit "Some tests failed with direct execution!"
        fi
    else
        error_exit "Test executable not found at $TEST_EXECUTABLE"
    fi
}

# Run tests automatically after build
if [ "$SKIP_TESTS" != true ]; then
    # Check if tests were built
    case "$GENERATOR" in
        "Xcode")
            TEST_EXECUTABLE="$TEST_BUILD_DIR/$BUILD_TYPE/quiverdb_wrapper_test"
            ;;
        "Visual Studio*")
            TEST_EXECUTABLE="$TEST_BUILD_DIR/$BUILD_TYPE/quiverdb_wrapper_test.exe"
            ;;
        *)
            TEST_EXECUTABLE="$TEST_BUILD_DIR/quiverdb_wrapper_test"
            ;;
    esac
    
    if [ ! -f "$TEST_EXECUTABLE" ]; then
        warning "Test executable not found, skipping tests"
    else
        run_tests_ctest
        run_tests_direct
    fi
fi

# Determine library extensions based on OS and build type
STATIC_EXT=".a"
SHARED_EXT=".dylib"
case "$OS" in
    "macOS")
        STATIC_EXT=".a"
        SHARED_EXT=".dylib"
        ;;
    "Linux")
        STATIC_EXT=".a"
        SHARED_EXT=".so"
        ;;
    "Windows")
        STATIC_EXT=".lib"
        SHARED_EXT=".dll"
        ;;
esac

# Determine library paths based on generator
case "$GENERATOR" in
    "Xcode"|"Visual Studio*")
        STATIC_LIB_PATH="$STATIC_BUILD_DIR/$BUILD_TYPE/libquiverdb_wrapper$STATIC_EXT"
        SHARED_LIB_PATH="$SHARED_BUILD_DIR/$BUILD_TYPE/libquiverdb_wrapper$SHARED_EXT"
        ;;
    *)
        STATIC_LIB_PATH="$STATIC_BUILD_DIR/libquiverdb_wrapper$STATIC_EXT"
        SHARED_LIB_PATH="$SHARED_BUILD_DIR/libquiverdb_wrapper$SHARED_EXT"
        ;;
esac

# Print final build summary
echo ""
echo "=== Final Build Summary ==="
echo "Static Library: $STATIC_LIB_PATH"
echo "Shared Library: $SHARED_LIB_PATH"
echo "Build Type: $BUILD_TYPE"
echo "Generator: $GENERATOR"
echo "Build Directories:"
echo "  - Static: $STATIC_BUILD_DIR"
echo "  - Shared: $SHARED_BUILD_DIR"

if [ "$SKIP_TESTS" = true ]; then
    echo "Tests: Skipped"
else
    echo "Tests: Ran successfully"
fi
echo ""
echo "✓ Build completed successfully!"