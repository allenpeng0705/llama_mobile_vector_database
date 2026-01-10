cmake_minimum_required(VERSION 3.20)
project(quiverdb_wrapper VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Option to enable/disable tests
option(QUIVERDB_BUILD_TESTS "Build tests for the wrapper API" OFF)

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
add_library(quiverdb_wrapper
    src/quiverdb_wrapper.cpp
)

# Set include directories for the library
target_include_directories(quiverdb_wrapper PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/quiverdb/src
)

# Add optimization flags
if(NOT MSVC)
    target_compile_options(quiverdb_wrapper PRIVATE -O3)
endif()

# Disable CUDA support by not enabling the language
# This ensures we don't build with CUDA dependencies for mobile

# Install the library
install(TARGETS quiverdb_wrapper DESTINATION lib)
install(DIRECTORY include/ DESTINATION include)

# Add tests if enabled
if(QUIVERDB_BUILD_TESTS)
    # Add the test executable
    add_executable(quiverdb_wrapper_test tests/test_quiverdb_wrapper.cpp)
    
    # Link with the wrapper library
    target_link_libraries(quiverdb_wrapper_test PRIVATE quiverdb_wrapper)
    
    # Include directories for the test
    target_include_directories(quiverdb_wrapper_test PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/quiverdb/src
    )
    
    # Add test to CTest
    add_test(NAME quiverdb_wrapper_test COMMAND quiverdb_wrapper_test)
    
    # Install the test if needed
    # install(TARGETS quiverdb_wrapper_test DESTINATION bin)
endif()
