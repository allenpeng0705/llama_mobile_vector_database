<div align="center">

# llama_mobile_vd

**Cross-platform vector database SDKs for mobile and web applications**

</div>

---

## Overview

llama_mobile_vd is a collection of cross-platform vector database SDKs built on top of **QuiverDB** - a high-performance, header-only C++20 vector database with SIMD acceleration. It provides embeddable vector database capabilities for mobile and web applications, running natively on Linux, macOS, Windows, iOS, and Android with a consistent API across all SDKs.

### Why llama_mobile_vd?

| Feature | llama_mobile_vd | FAISS | hnswlib | Pinecone |
|---------|-----------------|-------|---------|----------|
| Header-only core | Yes | No | No | N/A |
| Mobile/Edge native | Yes | No | Partial | No |
| Dependencies | Zero | Many | Few | Cloud |
| Binary size | <100KB | 200MB+ | ~1MB | N/A |
| GPU (Metal) | Yes | No | No | N/A |
| Cross-platform SDKs | iOS, Android, Flutter, React Native, Capacitor | No | No | No |

**Perfect for**: Mobile AI apps, edge devices, offline-first applications, and cross-platform development.

## Available SDKs

llama_mobile_vd provides SDKs for all major mobile and web platforms:

- **iOS SDK** (`llama_mobile_vd-ios-SDK`): Native Swift SDK for iOS applications (consolidated)
- **Android SDK** (`llama_mobile_vd-android-SDK`): Native Kotlin SDK for Android applications (consolidated)
- **Android Java SDK** (`llama_mobile_vd-android-java-SDK`): Native Java SDK for Android applications (separate)
- **Flutter SDK** (`llama_mobile_vd-flutter-SDK`): Cross-platform Flutter/Dart SDK
- **React Native SDK** (`llama_mobile_vd-react-native-SDK`): Cross-platform React Native SDK with TypeScript support
- **Capacitor Plugin** (`llama_mobile_vd-capacitor-plugin`): Cross-platform Capacitor plugin for web/hybrid applications

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

### Distance Metrics
- **L2**: Euclidean distance
- **Cosine**: Cosine similarity
- **Dot**: Dot product

## Build Instructions

### Prerequisites

- CMake 3.20+ for building the core library
- Xcode (13.0+) for iOS builds (macOS only)
- Android Studio (2022.3+) for Android builds
- Flutter SDK (3.0+) for Flutter builds
- React Native CLI (0.70+) for React Native builds
- Capacitor CLI (4.0+) for Capacitor plugin builds

### Required Environment Variables

Some builds require specific environment variables to be set:

#### Android Builds
- `ANDROID_HOME`: Path to Android SDK installation
- `ANDROID_NDK_ROOT`: Path to Android NDK installation (preferably r25c or later)
- `JAVA_HOME`: Path to Java JDK installation (Java 11 recommended)

#### iOS Builds (macOS only)
- `XCODE_DEVELOPER_DIR`: Path to Xcode developer directory (optional, auto-detected)

### Optional Environment Variables

These variables can be set to customize the build process:

- `CMAKE_PATH`: Path to CMake executable
- `MAKE_PATH`: Path to make executable
- `NINJA_PATH`: Path to Ninja executable
- `FLUTTER_PATH`: Path to Flutter SDK
- `REACT_NATIVE_PATH`: Path to React Native CLI
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

#### Android Java SDK
```bash
cd scripts
bash build-android-java.sh
```

#### Flutter SDK
```bash
cd scripts
bash build-flutter-SDK.sh
```

#### React Native SDK
```bash
cd scripts
bash build-react-native-SDK.sh
```

#### Capacitor Plugin
```bash
cd scripts
bash build-capacitor-plugin.sh
```

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

The test suite includes specialized tests for common embedding sizes (384, 768, 1024, 3072) with all distance metrics (L2, COSINE, DOT). These tests verify that:

- VectorStore handles different dimension sizes correctly
- HNSWIndex works with various embedding dimensions
- All distance metrics function properly across dimensions
- Memory management is efficient for large vectors

## Usage Examples

### iOS SDK (Swift)

```swift
import LlamaMobileVD

// Create a vector store
let store = try VectorStore(dimension: 128, metric: .cosine)

// Add vectors
let vector: [Float] = Array(repeating: 0.0, count: 128)
try store.addVector(vector, id: 1)

// Search
let query: [Float] = Array(repeating: 0.0, count: 128)
let searchResults = try store.search(query, k: 5)
print("Search results: \(searchResults)")

// Clear store
try store.clear()
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

### React Native SDK

```typescript
import { LlamaMobileVD, DistanceMetric } from 'llama_mobile_vd-react-native-SDK';

// Create a vector store
const options = { dimension: 128, metric: DistanceMetric.COSINE };
const result = await LlamaMobileVD.createVectorStore(options);
const storeId = result.id;

// Add vectors
const vector = Array(128).fill(0.0);
await LlamaMobileVD.addVectorToStore(storeId, vector, "1");

// Search
const query = Array(128).fill(0.0);
const searchResult = await LlamaMobileVD.searchVectorStore(storeId, query, 5);
console.log('Search results:', searchResult);

// Release
await LlamaMobileVD.releaseVectorStore(storeId);
```

### Capacitor Plugin

```typescript
import { Plugins } from '@capacitor/core';
const { LlamaMobileVDPlugin } = Plugins;

// Create a vector store
const options = { dimension: 128, metric: 'cosine' };
const result = await LlamaMobileVDPlugin.createVectorStore(options);
const storeId = result.id;

// Add vectors
const vector = Array(128).fill(0.0);
await LlamaMobileVDPlugin.addVectorToStore({ id: storeId, vector, vectorId: "1" });

// Search
const query = Array(128).fill(0.0);
const searchResult = await LlamaMobileVDPlugin.searchVectorStore({ id: storeId, query, k: 5 });
console.log('Search results:', searchResult);

// Release
await LlamaMobileVDPlugin.releaseVectorStore({ id: storeId });
```

## Examples

The repository includes example applications for all SDKs in the `examples` directory:

- **iOSSDKExample**: Example iOS application using the iOS SDK
- **androidSDKExample**: Example Android application using the Android Kotlin SDK
- **androidJavaSDKExample**: Example Android application using the Android Java SDK
- **flutterSDKExample**: Example Flutter application using the Flutter SDK
- **rnSDKExample**: Example React Native application using the React Native SDK
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

#### React Native Example
```bash
cd examples/rnSDKExample/rnSDKExample
npm install
npx react-native run-ios
# or
npx react-native run-android
```

#### Capacitor Example
```bash
cd examples/capacitorPluginExample
npm install
npx cap run ios
# or
npx cap run android
```

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
