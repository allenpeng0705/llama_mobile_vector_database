# LlamaMobileVD iOS Native Library

A high-performance vector database native library for iOS applications, built on top of the LlamaMobileVD C++ core. This library provides embeddable vector database capabilities for iOS apps, running natively with ARM NEON acceleration.

## Features

- **Native C++ API**: High-performance core with ARM NEON acceleration
- **Multiple distance metrics**: Support for L2 (Euclidean), Cosine, and Dot Product distances
- **VectorStore**: Exact nearest neighbor search with thread-safe operations
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
- **MMapVectorStore**: Memory-mapped vector store for large datasets that may exceed RAM capacity
- **Multi-dimensional support**: Handles common embedding sizes (384, 768, 1024, 3072 dimensions)
- **Universal framework**: Supports both iOS devices and simulators
- **Zero-copy operations**: Efficient memory usage for mobile devices

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.0+
- C++17 compatible compiler

## Library Structure

```
llama_mobile_vd-ios/
├── include/
│   └── llama_mobile_vd_wrapper.h  # C/C++ header file
├── lib/
│   ├── ios-arm64/
│   │   └── libllama_mobile_vd.a   # ARM64 (AArch64) static library
│   └── ios-x86_64-simulator/
│       └── libllama_mobile_vd.a   # x86_64 simulator static library
└── xcframework/
    └── llama_mobile_vd.xcframework  # Universal framework (device + simulator)
```

## Installation

### Xcode

To use the native library in your iOS project:

1. Copy the `llama_mobile_vd-ios` directory to your project's directory

2. In Xcode, go to your project settings and select your target

3. Under "Build Phases", add the library to "Link Binary With Libraries":
   - For device builds: Add `lib/ios-arm64/libllama_mobile_vd.a`
   - For simulator builds: Add `lib/ios-x86_64-simulator/libllama_mobile_vd.a`
   - Or use the universal xcframework: Add `xcframework/llama_mobile_vd.xcframework`

4. Under "Build Settings", add the include directory to "Header Search Paths":
   ```
   $(PROJECT_DIR)/llama_mobile_vd-ios/include
   ```

### Swift Package Manager

You can also include the library in your Swift Package by adding it as a dependency in your Package.swift file:

```swift
let package = Package(
    name: "YourPackage",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "YourPackage",
            targets: ["YourPackage"]
        )
    ],
    targets: [
        .target(
            name: "YourPackage",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("llama_mobile_vd"),
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .unsafeFlags(["-L$(PROJECT_DIR)/llama_mobile_vd-ios/lib/ios-$(ARCH)", "-I$(PROJECT_DIR)/llama_mobile_vd-ios/include"])
            ]
        )
    ]
)
```

## API Reference

The library provides a C/C++ API for vector database operations. The main header file is `llama_mobile_vd_wrapper.h`.

### Distance Metrics

```c
typedef enum {
    LLAMA_MOBILE_VD_DISTANCE_METRIC_L2,     // Euclidean distance
    LLAMA_MOBILE_VD_DISTANCE_METRIC_COSINE,  // Cosine distance
    LLAMA_MOBILE_VD_DISTANCE_METRIC_DOT      // Dot product distance
} LLAMA_MOBILE_VD_DistanceMetric;
```

### VectorStore

Exact nearest neighbor search:

```c
// Create a new VectorStore
LLAMA_MOBILE_VD_VectorStore* vectorStore = llama_mobile_vd_vector_store_new(
    512,                            // dimension
    LLAMA_MOBILE_VD_DISTANCE_METRIC_L2  // distance metric
);

// Add a vector
float vector[512];
// Populate vector with data
llama_mobile_vd_vector_store_add_vector(vectorStore, 1, vector);

// Search for nearest neighbors
LLAMA_MOBILE_VD_SearchResult* results;
int resultCount;
llama_mobile_vd_vector_store_search(
    vectorStore, 
    queryVector, 
    5,          // k (number of results)
    &results, 
    &resultCount
);

// Process results
for (int i = 0; i < resultCount; i++) {
    printf("ID: %llu, Distance: %f\n", results[i].id, results[i].distance);
}

// Free results
llama_mobile_vd_free_search_results(results);

// Delete the VectorStore
llama_mobile_vd_vector_store_delete(vectorStore);
```

### HNSWIndex

High-performance approximate nearest neighbor search:

```c
// Create a new HNSWIndex
LLAMA_MOBILE_VD_HNSWIndex* hnswIndex = llama_mobile_vd_hnsw_index_new(
    768,                            // dimension
    LLAMA_MOBILE_VD_DISTANCE_METRIC_COSINE,  // distance metric
    10000,                          // max elements
    16,                             // m (number of connections)
    200,                            // efConstruction
    42                              // seed
);

// Add vectors
for (uint64_t i = 0; i < 1000; i++) {
    float vector[768];
    // Populate vector with data
    llama_mobile_vd_hnsw_index_add_vector(hnswIndex, i + 1, vector);
}

// Set search parameters
llama_mobile_vd_hnsw_index_set_ef_search(hnswIndex, 100);

// Search for nearest neighbors
LLAMA_MOBILE_VD_SearchResult* results;
int resultCount;
llama_mobile_vd_hnsw_index_search(
    hnswIndex, 
    queryVector, 
    10,         // k (number of results)
    &results, 
    &resultCount
);

// Free results
llama_mobile_vd_free_search_results(results);

// Delete the HNSWIndex
llama_mobile_vd_hnsw_index_delete(hnswIndex);
```

### MMapVectorStore

Memory-mapped vector store for large datasets:

```c
// Create a builder for MMapVectorStore
LLAMA_MOBILE_VD_MMapVectorStoreBuilder* builder = llama_mobile_vd_mmap_vector_store_builder_new(
    1024,                           // dimension
    LLAMA_MOBILE_VD_DISTANCE_METRIC_DOT  // distance metric
);

// Add vectors to the builder
for (uint64_t i = 0; i < 10000; i++) {
    float vector[1024];
    // Populate vector with data
    llama_mobile_vd_mmap_vector_store_builder_add_vector(builder, i + 1, vector);
}

// Save the builder to file
const char* filename = "path/to/my_mmap_store.bin";
llama_mobile_vd_mmap_vector_store_builder_save(builder, filename);

// Delete the builder
llama_mobile_vd_mmap_vector_store_builder_delete(builder);

// Open the MMapVectorStore from file
LLAMA_MOBILE_VD_MMapVectorStore* mmapStore = llama_mobile_vd_mmap_vector_store_open(filename);

// Search for nearest neighbors
LLAMA_MOBILE_VD_SearchResult* results;
int resultCount;
llama_mobile_vd_mmap_vector_store_search(
    mmapStore, 
    queryVector, 
    10,         // k (number of results)
    &results, 
    &resultCount
);

// Free results
llama_mobile_vd_free_search_results(results);

// Close the MMapVectorStore
llama_mobile_vd_mmap_vector_store_close(mmapStore);
```

## Performance Tips

### Which Index to Choose?

- **VectorStore**: Use for exact nearest neighbor search with small to medium datasets (up to 10,000 vectors)
- **HNSWIndex**: Use for high-performance approximate nearest neighbor search with large datasets (10,000+ vectors)
- **MMapVectorStore**: Use for extremely large datasets that may exceed RAM capacity (hundreds of thousands to millions of vectors)

### HNSWIndex Optimization

- Adjust `m` and `efConstruction` parameters when creating an `HNSWIndex`:
  - Higher `m` values create more connections per node (better search quality, higher memory usage)
  - Higher `efConstruction` values improve index quality (slower build time)
- Adjust `efSearch` parameter during search to balance speed and quality

### MMapVectorStore Specific Tips

- Provides zero-copy access to vector data on disk, ideal for large datasets
- Loading is instant, regardless of size, as it doesn't load all vectors into RAM
- Search performance is slower than HNSWIndex but faster than VectorStore for very large datasets
- Perfect for applications that need to handle large vector datasets efficiently on mobile devices with limited RAM

### General Tips

- For common embedding sizes (384, 768, 1024, 3072), the library is optimized for performance
- Use `reserve` methods when you know the expected number of vectors to reduce memory reallocations
- Prefer vector dimensions that are multiples of 16 for optimal SIMD performance
- Enable compiler optimizations (Release build) for maximum performance

## Building from Source

To build the iOS native library from source:

```bash
cd /path/to/llama_mobile_vector_database
./scripts/build-ios.sh
```

This will build the library for both device and simulator architectures and place the output in the `llama_mobile_vd-ios` directory.

### Custom Build Options

```bash
# Build only for simulator
./scripts/build-ios.sh --simulator-only

# Build only for device
./scripts/build-ios.sh --device-only

# Build in Debug mode
./scripts/build-ios.sh --type Debug

# Build with verbose output
./scripts/build-ios.sh --verbose
```

## License

See the LICENSE file for details.