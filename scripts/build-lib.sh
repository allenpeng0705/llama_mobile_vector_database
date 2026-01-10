#!/bin/bash

# Desktop build script for QuiverDB wrapper corelib

# Set the working directory to the project root
SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$SCRIPT_DIR/.."
WRAPPER_DIR="$PROJECT_ROOT/lib/wrapper"

# Get number of cores for parallel build
NUM_CORES=$(sysctl -n hw.logicalcpu 2>/dev/null || nproc)

# Function to build library with specific type (static or shared)
build_library() {
    local LIB_TYPE=$1  # "static" or "shared"
    local SHARED_OPTION=$2  # "OFF" or "ON"
    local BUILD_DIR="$PROJECT_ROOT/build-lib-$LIB_TYPE"
    
    echo "\n=== Building $LIB_TYPE library ==="
    
    # Create build directory
    mkdir -p $BUILD_DIR
    
    # Configure CMake
    echo "Configuring CMake for $LIB_TYPE build..."
    cmake -B $BUILD_DIR \
        -GXcode \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=$SHARED_OPTION \
        -DQUIVERDB_BUILD_TESTS=ON \
        -DQUIVERDB_BUILD_BENCHMARKS=OFF \
        -DQUIVERDB_BUILD_EXAMPLES=OFF \
        -DQUIVERDB_BUILD_PYTHON=OFF \
        -DQUIVERDB_BUILD_CUDA=OFF \
        -DQUIVERDB_BUILD_METAL=OFF \
        "$WRAPPER_DIR"
    
    if [ $? -ne 0 ]; then
        echo "Error: CMake configuration failed for $LIB_TYPE build"
        exit 1
    fi
    
    # Build the library
    echo "Building $LIB_TYPE library with $NUM_CORES cores..."
    cmake --build $BUILD_DIR --config Release -j $NUM_CORES
    
    if [ $? -ne 0 ]; then
        echo "Error: $LIB_TYPE build failed"
        exit 1
    fi
    
    # Determine library file extension
    if [ "$SHARED_OPTION" = "ON" ]; then
        if [ "$(uname)" = "Darwin" ]; then
            LIB_EXT=".dylib"
        elif [ "$(uname)" = "Linux" ]; then
            LIB_EXT=".so"
        else
            LIB_EXT=".dll"
        fi
    else
        LIB_EXT=".a"
    fi
    
    echo "$LIB_TYPE library build completed successfully!"
    echo "Library location: $BUILD_DIR/Release/libquiverdb_wrapper$LIB_EXT"
    echo "Test executables location: $BUILD_DIR/Release/"
    
    # Return build directory for testing
    echo $BUILD_DIR
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
    cd $TEST_BUILD_DIR
    
    ctest -C Release
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ All tests passed with CTest!"
    else
        echo ""
        echo "✗ Some tests failed with CTest!"
        exit 1
    fi
}

# Function to run tests directly for detailed output
run_tests_direct() {
    echo ""
    echo "=== Running tests directly for detailed output ==="
    
    TEST_EXECUTABLE="$TEST_BUILD_DIR/Release/quiverdb_wrapper_test"
    
    if [ -f "$TEST_EXECUTABLE" ]; then
        "$TEST_EXECUTABLE"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✓ All tests passed with direct execution!"
        else
            echo ""
            echo "✗ Some tests failed with direct execution!"
            exit 1
        fi
    else
        echo "Error: Test executable not found at $TEST_EXECUTABLE"
        exit 1
    fi
}

# Run tests automatically after build
if [ "$1" != "--no-tests" ]; then
    run_tests_ctest
    run_tests_direct
    
    echo ""
    echo "=== All test runs completed successfully! ==="
    echo ""
    echo "Test summary:"
    echo "- Test build directory: $TEST_BUILD_DIR"
    echo "- Test executable: $TEST_BUILD_DIR/Release/quiverdb_wrapper_test"
    echo "- All test methods passed successfully"
    echo ""
    echo "Build summary:"
    echo "- Static library: $STATIC_BUILD_DIR/Release/libquiverdb_wrapper.a"
    echo "- Shared library: $SHARED_BUILD_DIR/Release/libquiverdb_wrapper.dylib"
fi