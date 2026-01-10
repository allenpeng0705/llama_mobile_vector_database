cmake_minimum_required(VERSION 3.20)
project(LlamaMobileVDiOS VERSION 0.1.0 LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/../lib/wrapper/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../lib/llama_cpp/quiverdb/src
)

# Source files for the iOS framework
set(SOURCES
    src/LlamaMobileVD.mm
    src/LlamaMobileVD.h
)

# Create the framework
add_library(LlamaMobileVD SHARED ${SOURCES})

# Link with the wrappers library - use the library built in the project root build directory
target_link_libraries(LlamaMobileVD PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../build-ios/Release-iphoneos/libquiverdb_wrapper.a
)

# Set framework properties
set_target_properties(LlamaMobileVD PROPERTIES
    FRAMEWORK TRUE
    PUBLIC_HEADER "src/LlamaMobileVD.h"
    MACOSX_FRAMEWORK_IDENTIFIER "com.llamamobile.vd"
    MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "13.0"
    XCODE_ATTRIBUTE_ENABLE_BITCODE "YES"
    XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE "bitcode"
)

# Install the framework
install(TARGETS LlamaMobileVD
    FRAMEWORK DESTINATION ios/Frameworks
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)
