cmake_minimum_required(VERSION 3.18.1)

project("llama_mobile_vd_flutter_sdk")

# Add the native library
add_library(llama_mobile_vd SHARED IMPORTED)
set_target_properties(llama_mobile_vd PROPERTIES
    IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libllama_mobile_vd.a"
)

# Add the JNI wrapper
add_library(
    llama_mobile_vd_jni
    SHARED
    llama_mobile_vd_jni.cpp
)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
)

# Link libraries
find_library(log-lib log)
find_library(android-lib android)

# Link the JNI wrapper with the native library
target_link_libraries(
    llama_mobile_vd_jni
    llama_mobile_vd
    ${log-lib}
    ${android-lib}
    -lc++_shared
)
