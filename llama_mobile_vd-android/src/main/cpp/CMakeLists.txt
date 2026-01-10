cmake_minimum_required(VERSION 3.20)

project(llamamobilevd)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../lib/wrapper/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../lib/llama_cpp/quiverdb/src
)

# Add the wrapper library
add_library(quiverdb_wrapper STATIC
    IMPORTED
)

set_target_properties(quiverdb_wrapper PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../../../lib/wrapper/build-android/libquiverdb_wrapper.a
)

# Source files for the JNI library
set(SOURCES
    llama_mobile_vd_jni.cpp
)

# Create the shared library
add_library(llamamobilevd SHARED
    ${SOURCES}
)

# Link with the wrapper library and Android libraries
target_link_libraries(llamamobilevd
    PRIVATE
        quiverdb_wrapper
        log
)

# Set library properties
set_target_properties(llamamobilevd PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../../jniLibs/${ANDROID_ABI}
)
