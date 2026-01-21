# llama_mobile_vd-android

Android native library for llama_mobile_vd vector database.

## Project Structure

```
llama_mobile_vd-android/
├── CMakeLists.txt         # CMake build script
├── include/               # Header files
│   └── llama_mobile_vd_wrapper.h  # Main wrapper header
├── libs/                  # Library files
│   ├── arm64-v8a/         # ARM64 library
│   │   └── libllama_mobile_vd.a
│   └── x86_64/            # x86_64 library
│       └── libllama_mobile_vd.a
└── README.md              # This file
```

## Building the Library

### Prerequisites
- Android NDK r25c or later
- CMake 3.21 or later
- Ninja build system (recommended)

### Build Commands

#### Using CMake directly
```bash
# Create build directory
mkdir -p build
cd build

# Configure for ARM64
cmake .. \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=21 \
    -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
    -DCMAKE_ANDROID_NDK=/path/to/ndk \
    -DCMAKE_ANDROID_STL_TYPE=c++_shared \
    -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build .

# Configure for x86_64
cmake .. \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=21 \
    -DCMAKE_ANDROID_ARCH_ABI=x86_64 \
    -DCMAKE_ANDROID_NDK=/path/to/ndk \
    -DCMAKE_ANDROID_STL_TYPE=c++_shared \
    -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build .
```

#### Using the build script
```bash
# From the project root
cd scripts
./build-android-lib.sh
```

## Using the Library

### In an Android Studio Project

1. **Copy the library files**:
   - Copy `include/` directory to your project's `src/main/cpp/include/`
   - Copy the appropriate library file (`libllama_mobile_vd.a`) to `src/main/jniLibs/[arch]/`

2. **Configure CMakeLists.txt**:
   ```cmake
   # Add to your CMakeLists.txt
   include_directories(${CMAKE_SOURCE_DIR}/src/main/cpp/include)
   
   add_library(llama_mobile_vd STATIC IMPORTED)
   set_target_properties(llama_mobile_vd PROPERTIES
       IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libllama_mobile_vd.a
   )
   
   # Link against your native library
   target_link_libraries(your-native-lib llama_mobile_vd)
   ```

3. **Use in C++ code**:
   ```cpp
   #include "llama_mobile_vd_wrapper.h"
   
   // Example usage
   int dimension = 128;
   int metric = LLAMA_MOBILE_VD_METRIC_COSINE;
   
   quiverdb_vector_store_t* store = quiverdb_vector_store_create(dimension, metric);
   if (store) {
       // Use the store...
       quiverdb_vector_store_destroy(store);
   }
   ```

## Library Details

### Architecture Support
- **arm64-v8a**: For 64-bit ARM devices (most modern Android devices)
- **x86_64**: For x86_64 emulators and devices

### Features
- VectorStore (in-memory vector storage)
- HNSWIndex (hierarchical navigable small world index)
- MMapVectorStore (memory-mapped vector storage)
- Support for L2, Cosine, and Dot product distance metrics
- SIMD-optimized vector operations

### Dependencies
- No external dependencies - self-contained implementation

## Version Information

To check the library version:

```cpp
const char* version = llama_mobile_vd_version();
int major = llama_mobile_vd_version_major();
int minor = llama_mobile_vd_version_minor();
int patch = llama_mobile_vd_version_patch();
```

## License

MIT License - see LICENSE file for details.
