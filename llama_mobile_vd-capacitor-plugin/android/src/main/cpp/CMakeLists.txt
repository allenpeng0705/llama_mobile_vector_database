cmake_minimum_required(VERSION 3.22.1)
project("llama_mobile_vd_capacitor")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(llama_mobile_vd SHARED
    llama_mobile_vd_jni.cpp
)

target_include_directories(llama_mobile_vd PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(llama_mobile_vd
    ${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libllama_mobile_vd.a
    log
)
