cmake_minimum_required(VERSION 3.20)
project(llama_mobile_vd VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Option to enable/disable tests
option(LLAMA_MOBILE_VD_BUILD_TESTS "Build tests for the wrapper API" OFF)

# Option to build as shared library (default: OFF for better platform compatibility)
option(BUILD_SHARED_LIBS "Build shared libraries instead of static libraries" OFF)

# Enable testing if tests are built
if(QUIVERDB_BUILD_TESTS)
    enable_testing()
endif()

# Add the QuiverDB include directory
include_directories(include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/quiverdb/src)

# Create the wrapper library (type depends on BUILD_SHARED_LIBS option)
add_library(llama_mobile_vd
    src/llama_mobile_vd_wrapper.cpp
)

# Set include directories for the library
target_include_directories(llama_mobile_vd PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/quiverdb/src
)

# Add optimization flags
if(NOT MSVC)
    target_compile_options(llama_mobile_vd PRIVATE -O3)
endif()

# Android-specific configuration for 16 KB page size alignment (required for Android 15+)
if(ANDROID)
    # Set 16 KB page size alignment for Android builds
    # This is required for Android 15 (API level 35) and higher
    target_link_options(llama_mobile_vd PRIVATE
        -Wl,-z,max-page-size=16384
    )
    
    # Optional: Suppress warnings about section mismatches
    target_link_options(llama_mobile_vd PRIVATE
        -Wl,--no-warn-mismatch
    )
endif()

# Disable CUDA support by not enabling the language
# This ensures we don't build with CUDA dependencies for mobile

# Install the library
install(TARGETS llama_mobile_vd DESTINATION lib)
install(DIRECTORY include/ DESTINATION include)

# Add tests if enabled
if(LLAMA_MOBILE_VD_BUILD_TESTS)
    # Add the test executable
    add_executable(llama_mobile_vd_wrapper_test tests/test_llama_mobile_vd_wrapper.cpp)
    
    # Link with the wrapper library
    target_link_libraries(llama_mobile_vd_wrapper_test PRIVATE llama_mobile_vd)
    
    # Include directories for the test
    target_include_directories(llama_mobile_vd_wrapper_test PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/quiverdb/src
    )
    
    # Add test to CTest
    add_test(NAME llama_mobile_vd_wrapper_test COMMAND llama_mobile_vd_wrapper_test)
    
    # Install the test if needed
    # install(TARGETS llama_mobile_vd_wrapper_test DESTINATION bin)
endif()
