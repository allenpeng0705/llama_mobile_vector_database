cmake_minimum_required(VERSION 3.18.1)

project("llama_mobile_vd")

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Include header files
include_directories(include)

# Add the static library
add_library(llama_mobile_vd STATIC IMPORTED)
set_target_properties(llama_mobile_vd PROPERTIES
    IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libllama_mobile_vd.a
)

# Create the JNI library
add_library(llama_mobile_vd_jni SHARED
    llama_mobile_vd_jni.cpp
)

target_link_libraries(llama_mobile_vd_jni
    llama_mobile_vd
    log
    -lc++_shared
)

