<div align="center">

```
  ____  _                   _     _  ____
 / ___|| |_ _ __ _   _  ___| |__ (_)|  _ \ ___
 \___ \| __| '__| | | |/ __| '_ \| || |_) / _ \
  ___) | |_| |  | |_| | (__| | | | ||  _ <  __/
 |____/ \__|_|   \__,_|\___|_| |_|_||_| \_\___|
  __  __                    _     ___ 
 |  \/  | __ _ _ __ ___    | |   |_ _|
 | |\/| |/ _` | '_ ` _ \   | |    | | 
 | |  | | (_| | | | | | |  | |___ | | 
 |_|  |_|\__,_|_| |_| |_|  |_____|___|

 [VECTOR DATABASE] • [MOBILE SDK] • [HIGH PERFORMANCE]
```

# llama_mobile_vd

**Cross-platform vector database SDKs built on QuiverDB**

*Embeddable vector database capabilities for mobile and web applications*

</div>

---

## Overview

llama_mobile_vd is a collection of **cross-platform vector database SDKs built on top of QuiverDB** - a high-performance, header-only C++20 vector database with SIMD acceleration. It provides embeddable vector database capabilities for mobile and web applications, running natively on Linux, macOS, Windows, iOS, and Android with a consistent API across all SDKs.

### About the QuiverDB Foundation

At its core, llama_mobile_vd leverages **QuiverDB** - an ultra-lightweight (header-only), high-performance C++20 vector database optimized for edge and mobile deployment. QuiverDB features:
- Header-only implementation with zero dependencies
- SIMD acceleration for vector operations
- GPU (Metal) support for iOS devices
- Advanced index structures (HNSW)
- Multi-threaded query execution

The llama_mobile_vd SDKs wrap QuiverDB's core functionality and provide native language interfaces for various mobile and web platforms.

### Why llama_mobile_vd?

| Feature | llama_mobile_vd | FAISS | hnswlib | Pinecone |
|---------|-----------------|-------|---------|----------|
| Header-only core | Yes | No | No | N/A |
| Mobile/Edge native | Yes | No | Partial | No |
| Dependencies | Zero | Many | Few | Cloud |
| Binary size | <100KB | 200MB+ | ~1MB | N/A |
| GPU (Metal) | Yes | No | No | N/A |
| Cross-platform SDKs | iOS, Android, Flutter, Capacitor | No | No | No |

**Perfect for**: Mobile AI apps, edge devices, offline-first applications, and cross-platform development.

## Available SDKs

llama_mobile_vd provides SDKs for all major mobile and web platforms:

- **iOS SDK** (`llama_mobile_vd-ios-SDK`): Native Swift SDK for iOS applications with Metal GPU support
- **Android SDK** (`llama_mobile_vd-android-SDK`): Native Kotlin and Java SDK for Android applications (consolidated)
- **Flutter SDK** (`llama_mobile_vd-flutter-SDK`): Cross-platform Flutter/Dart SDK with unified API
- **Capacitor Plugin** (`llama_mobile_vd-capacitor-plugin`): Cross-platform Capacitor plugin for web/hybrid applications with TypeScript support

**Note**: React Native SDK is not currently implemented. Support for other platforms may be added in future releases.

## Core Features

Built on QuiverDB's high-performance foundation, all SDKs provide consistent API with the following core features:

### Performance
- **SIMD-optimized**: ARM NEON, x86 AVX2 (~100ns for 768d vectors)
- **GPU acceleration**: Metal (Apple Silicon), CUDA (NVIDIA)
- **Thread-safe**: Concurrent reads with `std::shared_mutex`

### Index Types

#### VectorStore (Exact Search)
- **createVectorStore**: Create a new vector store with specified dimension and distance metric
- **addVectorToStore**: Add a vector to the vector store
- **searchVectorStore**: Perform exact nearest neighbor search
- **countVectorsInStore**: Get the number of vectors in the store
- **clearVectorStore**: Remove all vectors from the store
- **releaseVectorStore**: Release resources associated with the vector store

#### HNSWIndex (Approximate Search)
- **createHNSWIndex**: Create a new HNSW index with specified parameters
- **addVectorToIndex**: Add a vector to the HNSW index
- **searchHNSWIndex**: Perform approximate nearest neighbor search
- **countVectorsInIndex**: Get the number of vectors in the index
- **clearHNSWIndex**: Remove all vectors from the index
- **releaseHNSWIndex**: Release resources associated with the index

#### MMapVectorStore (Memory-Mapped)
- **createMMapVectorStoreBuilder**: Create a builder for memory-mapped vector store
- **addVectorToBuilder**: Add vectors to the builder
- **saveMMapVectorStore**: Save the built store to disk
- **openMMapVectorStore**: Open an existing memory-mapped vector store from disk
- **searchMMapVectorStore**: Perform exact nearest neighbor search on memory-mapped data
- **closeMMapVectorStore**: Close the memory-mapped vector store

### When to Use Each Index Type

| Index Type | Best For | Key Characteristics |
|------------|----------|---------------------|
| **VectorStore** | Small to medium datasets (up to 100k vectors), exact search requirements | In-memory storage, O(n) search time, thread-safe, low memory overhead |
| **HNSWIndex** | Large datasets (100k+ vectors), fast approximate search | Hierarchical navigable small world graph, O(log n) search time, configurable accuracy/performance tradeoff |
| **MMapVectorStore** | Very large datasets (1M+ vectors), datasets larger than RAM | Memory-mapped file access, zero-copy reading, instant loading, O(n) search time |

**Choosing the right index:**
- Use **VectorStore** for small datasets where exact results are critical and memory is not a constraint
- Use **HNSWIndex** for large datasets where search speed is more important than exact results
- Use **MMapVectorStore** for extremely large datasets that don't fit in RAM or need to be persistently stored on disk

### Distance Metrics

#### L2 (Euclidean Distance)
**Definition**: The straight-line distance between two points in a vector space.
**Calculation**: √(Σ(v1_i - v2_i)²) for each dimension i.
**Key Characteristics**:
- Measures the actual geometric distance between vectors
- Sensitive to vector magnitude (length)
- Values range from 0 (identical vectors) to infinity
- **Use Case**: Best when vector magnitude is meaningful (e.g., physical measurements)

#### Cosine Similarity
**Definition**: Measures the angle between two vectors, regardless of their magnitude.
**Calculation**: (v1 · v2) / (||v1|| × ||v2||), where · is dot product and ||v|| is vector magnitude.
**Key Characteristics**:
- Normalizes vectors to unit length before comparison
- Focuses on direction rather than distance
- Values range from -1 (opposite directions) to 1 (identical directions)
- **Use Case**: Ideal for text embeddings, where direction matters more than length

#### Dot Product
**Definition**: The sum of the products of corresponding elements in two vectors.
**Calculation**: Σ(v1_i × v2_i) for each dimension i.
**Key Characteristics**:
- Measures both magnitude and direction
- Values range from -infinity to infinity
- Largest when vectors are in the same direction and have large magnitudes
- **Use Case**: Effective when both direction and magnitude are important

#### Comparison Table

| Metric | Focus | Sensitivity to Magnitude | Typical Range | Best For |
|--------|-------|---------------------------|---------------|----------|
| L2 | Distance | Yes | 0 to ∞ | Physical measurements, uniform vector lengths |
| Cosine | Direction | No | -1 to 1 | Text embeddings, semantic similarity |
| Dot Product | Direction + Magnitude | Yes | -∞ to ∞ | Recommendation systems, relevance scoring |

#### Implementation Notes
- **L2** is computationally efficient and works well for most use cases
- **Cosine** is commonly used for text and image embeddings where magnitude variation isn't meaningful
- **Dot Product** is often preferred for normalized embeddings (where vectors already have unit length)

## Build Instructions

### Prerequisites

- CMake 3.20+ for building the core library
- Xcode (13.0+) for iOS builds (macOS only)
- Android Studio (2022.3+) for Android builds
- Flutter SDK (3.0+) for Flutter builds
- Capacitor CLI (4.0+) for Capacitor plugin builds

### Required Environment Variables

Some builds require specific environment variables to be set:

#### Android Builds
- `ANDROID_HOME`: Path to Android SDK installation
- `ANDROID_NDK_PATH`: Path to Android NDK installation (preferably r25c or later, auto-detected if not set)
- `JAVA_HOME`: Path to Java JDK installation (Java 11 recommended)

#### iOS Builds (macOS only)
- `XCODE_DEVELOPER_DIR`: Path to Xcode developer directory (optional, auto-detected)

### Centralized Configuration (config.env)

All build scripts now use a centralized `config.env` file located in the `scripts` directory. This file contains all the settings needed for building different SDKs and allows for easy configuration without needing to set environment variables directly.

**Key Features:**
- All build settings in one place
- Auto-detection of common paths (SDKs, tools)
- Platform-specific configurations
- Persistent settings across builds
- Clear section-based structure

**Usage:**
1. Run any build script, which will automatically detect and populate `config.env` with available paths
2. Or manually edit `scripts/config.env` to customize settings

### Optional Environment Variables

These variables can be set to override values in `config.env`:

- `CMAKE_PATH`: Path to CMake executable
- `MAKE_PATH`: Path to make executable
- `NINJA_PATH`: Path to Ninja executable
- `FLUTTER_PATH`: Path to Flutter SDK
- `CAPACITOR_PATH`: Path to Capacitor CLI

### Building All SDKs

Use the provided build scripts to build all SDKs:

```bash
# Navigate to the scripts directory
cd scripts

# Build all SDKs
bash build-all.sh
```

### Building Individual SDKs

#### iOS SDK
```bash
cd scripts
bash build-ios.sh
```

#### Android SDK (Kotlin/Java consolidated)
```bash
cd scripts
bash build-android.sh
```

#### Flutter SDK
```bash
cd scripts
bash build-flutter-SDK.sh
```

#### Capacitor Plugin
```bash
cd scripts
bash build-capacitor-plugin.sh
```

### Capacitor Plugin Development

The Capacitor plugin provides a cross-platform solution for web, iOS, and Android applications. It includes:

- **TypeScript definitions** for type-safe usage
- **Native implementations** for iOS and Android
- **Web fallback** for browser environments
- **Comprehensive API** matching all other SDKs

#### Key Features:
- Uses the same native libraries as the iOS and Android SDKs
- Provides consistent API across all platforms
- Supports all three index types: VectorStore, HNSWIndex, and MMapVectorStore
- Includes memory management optimizations for hybrid apps

## Running Tests

### Wrapper API Tests

The wrapper API tests verify the core functionality of both VectorStore and HNSWIndex across all supported dimension sizes and distance metrics. These tests are built automatically when compiling the wrapper library.

```bash
# Run wrapper tests directly from the build directory
cd build-lib
./Release/quiverdb_wrapper_test
```

### Core C++ Tests

The core QuiverDB library includes comprehensive tests for VectorStore and HNSWIndex. To run these tests:

```bash
# Navigate to the QuiverDB directory
cd lib/llama_cpp/quiverdb

# Create and configure build directory
mkdir -p build
cd build
cmake .. -DQUIVERDB_BUILD_TESTS=ON -DQUIVERDB_BUILD_BENCHMARKS=OFF -DQUIVERDB_BUILD_EXAMPLES=OFF -DQUIVERDB_BUILD_PYTHON=OFF

# Build and run tests
make
ctest
```

### Multi-Dimension Tests

The test suite includes comprehensive tests for vector dimensions ranging from small to very large sizes (8, 32, 64, 128, 256, 384, 512, 768, 1024, 2048, 3072, 3096) with all distance metrics (L2, COSINE, DOT). These tests verify that:

- VectorStore handles different dimension sizes correctly
- HNSWIndex works with various embedding dimensions
- MMapVectorStore supports large-dimensional vectors
- All distance metrics function properly across dimensions
- Memory management is efficient for large vectors
- Search functionality works correctly for very high-dimensional vectors (3096+ dimensions)

### Large Dataset Tests

The test suite includes specialized tests for large dataset scenarios:

- **Medium Dataset (1000 vectors)**: Tests for VectorStore, HNSWIndex, and MMapVectorStore with 1000 vectors
- **Large Dataset (10000 vectors)**: Performance tests for HNSWIndex with 10000 vectors
- **Memory-Mapped Datasets**: Tests for MMapVectorStore with large persistent datasets

These tests verify:
- Performance and accuracy with realistic dataset sizes
- Memory management efficiency
- Search functionality with large k values
- Persistence and retrieval of large datasets

### Platform-Specific Tests

Each SDK includes platform-specific tests:

**iOS SDK Tests**:
- Swift API tests for all three index types
- Large dimension tests (3096 dimensions)
- Large dataset tests (1000+ vectors)
- Memory-mapped store tests
- Distance metric verification
- Error handling and edge cases

**Android SDK Tests**:
- Kotlin/Java API tests
- Large dimension support
- Performance benchmarks
- Thread safety verification

**Cross-Platform SDK Tests**:
- Flutter, React Native, and Capacitor plugin tests
- Platform-specific integration tests
- Performance tests across devices

## Usage Examples

### iOS SDK (Swift)

```swift
import LlamaMobileVD

// Create a vector store
let store = try LlamaMobileVD.VectorStore(dimension: 128, metric: .cosine)

// Add vectors
let vector: [Float] = Array(repeating: 0.0, count: 128)
try store.addVector(id: 1, vector: vector)

// Search
let query: [Float] = Array(repeating: 0.0, count: 128)
let searchResults = try store.search(query: query, k: 5)
print("Search results: \(searchResults)")

// Get vector count
let count = try store.count()
print("Vector count: \(count)")

// Get a vector by ID
let retrievedVector = try store.getVector(id: 1)
print("Retrieved vector: \(retrievedVector)")

// Clear store
try store.clear()

// Create an HNSW index
let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: 128, metric: .cosine, maxElements: 1000)

// Add vectors to HNSW index
try hnswIndex.addVector(id: 1, vector: vector)

// Search HNSW index
let hnswResults = try hnswIndex.search(query: query, k: 5)
print("HNSW search results: \(hnswResults)")

// Create and use MMapVectorStore
let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: 128, metric: .cosine)
try builder.addVector(id: 1, vector: vector)
let tempFile = NSTemporaryDirectory().appending("test_store.bin")
try builder.save(to: tempFile)

let mmapStore = try LlamaMobileVD.MMapVectorStore.open(from: tempFile)
let mmapResults = try mmapStore.search(query: query, k: 5)
print("MMap search results: \(mmapResults)")

// Check library version
print("Library version: \(LlamaMobileVD.Version.full)")
print("Major version: \(LlamaMobileVD.Version.major)")
print("Minor version: \(LlamaMobileVD.Version.minor)")
print("Patch version: \(LlamaMobileVD.Version.patch)")
```

### Android SDK (Kotlin)

```kotlin
import com.llamamobile.vd.LlamaMobileVD
import com.llamamobile.vd.DistanceMetric

// Create a vector store
val store = VectorStore(128, DistanceMetric.COSINE)

// Add vectors
val vector = FloatArray(128)
store.addVector(vector, id = 1)

// Search
val query = FloatArray(128)
val searchResults = store.search(query, k = 5)
println("Search results: ${searchResults.joinToString()}")

// Clear store
store.clear()

// Close store when done
store.close()
```

### Android Java SDK

```java
import com.llamamobile.vd.VectorStore;
import com.llamamobile.vd.DistanceMetric;
import com.llamamobile.vd.SearchResult;

// Create a vector store
VectorStore store = new VectorStore(128, DistanceMetric.COSINE);

// Add vectors
float[] vector = new float[128];
store.addVector(vector, 1);

// Search
float[] query = new float[128];
SearchResult[] searchResults = store.search(query, 5);
System.out.println("Search results: ");
for (SearchResult result : searchResults) {
    System.out.println("  - ID: " + result.getId() + ", Distance: " + result.getDistance());
}

// Clear store
store.clear();

// Close store when done
store.close();
```

### Flutter SDK

```dart
import 'package:llama_mobile_vd/llama_mobile_vd.dart';

// Create a vector store
final options = VectorStoreOptions(dimension: 128, metric: DistanceMetric.cosine);
final result = await LlamaMobileVD.createVectorStore(options);
final storeId = result.id;

// Add vectors
final vector = List.filled(128, 0.0);
await LlamaMobileVD.addVectorToStore(storeId, vector, "1");

// Search
final query = List.filled(128, 0.0);
final searchResult = await LlamaMobileVD.searchVectorStore(storeId, query, 5);
print('Search results: $searchResult');

// Release
await LlamaMobileVD.releaseVectorStore(storeId);
```

### Capacitor Plugin

```typescript
import { LlamaMobileVD } from 'llama-mobile-vd-capacitor-plugin';

// Create a vector store
const { storeId } = await LlamaMobileVD.createVectorStore({
  dimension: 128,
  metric: 'cosine'
});

// Add vectors
await LlamaMobileVD.addVectors({
  storeId,
  vectors: [Array(128).fill(0.0)],
  ids: [1]
});

// Search
const queryVector = Array(128).fill(0.0);
const { ids, distances } = await LlamaMobileVD.search({
  storeId,
  queryVector,
  k: 5
});
console.log('Search results:', {
  ids,
  distances
});

// Get vector count
const { count } = await LlamaMobileVD.getVectorCount({ storeId });
console.log('Vector count:', count);

// Clean up
await LlamaMobileVD.destroyVectorStore({ storeId });
```

#### Capacitor Plugin MMap Example

```typescript
import { LlamaMobileVD } from 'llama-mobile-vd-capacitor-plugin';

// Create builder
const { builderId } = await LlamaMobileVD.createMMapVectorStoreBuilder({
  dimension: 128,
  metric: 'cosine'
});

// Add vectors
const vectors = [];
for (let i = 0; i < 100; i++) {
  vectors.push(Array(128).fill(Math.random()));
}

await LlamaMobileVD.addVectorsToMMapBuilder({
  builderId,
  vectors
});

// Build and save
const mmapPath = 'vectorstore.mmap';
await LlamaMobileVD.buildMMapVectorStore({
  builderId,
  path: mmapPath
});

// Clean up builder
await LlamaMobileVD.destroyMMapVectorStoreBuilder({
  builderId
});

// Later, open the saved vector store
const { storeId } = await LlamaMobileVD.openMMapVectorStore({
  path: mmapPath
});

// Search
const queryVector = Array(128).fill(Math.random());
const { ids, distances } = await LlamaMobileVD.search({
  storeId,
  queryVector,
  k: 5
});

console.log('MMap search results:', {
  ids,
  distances
});

// Clean up
await LlamaMobileVD.closeMMapVectorStore({ storeId });
```

## Examples

The repository includes example applications for all SDKs in the `examples` directory:

- **iOSSDKExample**: Example iOS application using the iOS SDK
- **androidSDKExample**: Example Android application using the Android Kotlin SDK
- **androidJavaSDKExample**: Example Android application using the Android Java interface from the consolidated SDK
- **flutterSDKExample**: Example Flutter application using the Flutter SDK
- **capacitorPluginExample**: Example web application using the Capacitor plugin

All examples demonstrate the full functionality of the SDKs with a consistent UI across all platforms.

### Running Examples

#### iOS Example
Open `examples/iOSSdkExample/iOSSDKExample.xcodeproj` in Xcode and run the project.

#### Android Examples
Open the respective example directories in Android Studio and run the projects.

#### Flutter Example
```bash
cd examples/flutterSDKExample
flutter pub get
flutter run
```

#### Capacitor Example
```bash
cd examples/capacitorPluginExample
npm install
npx cap run ios
# or
npx cap run android
```

### Capacitor Plugin Example

The `capacitorPluginExample` demonstrates the full capabilities of the Capacitor plugin, including:

- **VectorStore operations**: Create, add vectors, search, clear, and destroy
- **HNSWIndex operations**: Create, add vectors, search, and destroy
- **MMapVectorStore operations**: Create builder, add vectors, build, open, search, and close
- **Performance comparisons**: Side-by-side performance metrics
- **Cross-platform compatibility**: Works on web, iOS, and Android

#### Key Features:
- **Unified API**: Same code works across web, iOS, and Android
- **Real-time updates**: Live performance metrics
- **Error handling**: Comprehensive error messages
- **Responsive design**: Adapts to different screen sizes

### MMapVectorStore Example

The Capacitor plugin example includes a comprehensive MMapVectorStore demonstration that shows:

1. **Builder creation**: Setting up the MMapVectorStoreBuilder
2. **Vector addition**: Adding multiple vectors efficiently
3. **Building process**: Creating the memory-mapped file
4. **Opening the store**: Loading the persisted vector store
5. **Search functionality**: Performing similarity search
6. **Resource management**: Properly closing resources

This example highlights the power of memory-mapped storage for large datasets.

## API Reference

### VectorStore Class

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `constructor` | Create a new vector store | `dimension: number`, `metric: DistanceMetric` | `VectorStore` instance |
| `addVector` | Add a vector to the store | `vector: number[]`, `id: number` | `void` |
| `search` | Search for nearest neighbors | `query: number[]`, `k: number` | `SearchResult[]` |
| `getCount` | Get count of vectors | None | `number` |
| `clear` | Clear all vectors | None | `void` |
| `close` / `deinit` | Release resources | None | `void` |

### HNSWIndex Class

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `constructor` | Create a new HNSW index | `dimension: number`, `metric: DistanceMetric`, `m: number` (optional), `efConstruction: number` (optional) | `HNSWIndex` instance |
| `addVector` | Add a vector to the index | `vector: number[]`, `id: number` | `void` |
| `search` | Search for nearest neighbors | `query: number[]`, `k: number`, `efSearch: number` (optional) | `SearchResult[]` |
| `getCount` | Get count of vectors | None | `number` |
| `clear` | Clear all vectors | None | `void` |
| `close` / `deinit` | Release resources | None | `void` |

### Distance Metrics

All SDKs support the following distance metrics:

- `L2`: Euclidean distance
- `COSINE`: Cosine similarity
- `DOT`: Dot product

## License

MIT License - see LICENSE for details.
