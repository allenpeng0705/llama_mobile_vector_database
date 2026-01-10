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

- **iOS SDK** (`llama_mobile_vd-ios-SDK`): Native Swift SDK for iOS applications
- **Android SDK** (`llama_mobile_vd-android-SDK`): Native Kotlin SDK for Android applications
- **Android Java SDK** (`llama_mobile_vd-android-java-SDK`): Native Java SDK for Android applications
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
- Xcode for iOS builds
- Android Studio for Android builds
- Flutter SDK for Flutter builds
- React Native CLI for React Native builds
- Capacitor CLI for Capacitor plugin builds

### Building All SDKs

Use the provided build scripts to build all SDKs:

```bash
# Navigate to the scripts directory
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts

# Build all SDKs
bash build-all.sh
```

### Building Individual SDKs

#### iOS SDK
```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
bash build-ios.sh
```

#### Android SDK (Kotlin)
```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
bash build-android.sh
```

#### Android Java SDK
```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
bash build-android-java.sh
```

#### Flutter SDK
```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
bash build-flutter-SDK.sh
```

#### React Native SDK
```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
bash build-react-native-SDK.sh
```

#### Capacitor Plugin
```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
bash build-capacitor-plugin.sh
```

## Usage Examples

### iOS SDK (Swift)

```swift
import llama_mobile_vd

// Create a vector store
let options = VectorStoreOptions(dimension: 128, metric: .cosine)
let result = LlamaMobileVD.createVectorStore(options: options)
let storeId = result.id

// Add vectors
let vector: [Float32] = Array(repeating: 0.0, count: 128)
LlamaMobileVD.addVectorToStore(id: storeId, vector: vector, vectorId: "1")

// Search
let query: [Float32] = Array(repeating: 0.0, count: 128)
let searchResult = LlamaMobileVD.searchVectorStore(id: storeId, query: query, k: 5)
print("Search results: \(searchResult)")

// Release
LlamaMobileVD.releaseVectorStore(id: storeId)
```

### Android SDK (Kotlin)

```kotlin
import com.llamamobile.vd.LlamaMobileVD
import com.llamamobile.vd.VectorStoreOptions
import com.llamamobile.vd.DistanceMetric

// Create a vector store
val options = VectorStoreOptions(128, DistanceMetric.COSINE)
val result = LlamaMobileVD.createVectorStore(options)
val storeId = result.id

// Add vectors
val vector = FloatArray(128)
LlamaMobileVD.addVectorToStore(storeId, vector, "1")

// Search
val query = FloatArray(128)
val searchResult = LlamaMobileVD.searchVectorStore(storeId, query, 5)
println("Search results: $searchResult")

// Release
LlamaMobileVD.releaseVectorStore(storeId)
```

### Android Java SDK

```java
import com.llamamobile.vd.LlamaMobileVD;
import com.llamamobile.vd.VectorStoreOptions;
import com.llamamobile.vd.DistanceMetric;

// Create a vector store
VectorStoreOptions options = new VectorStoreOptions(128, DistanceMetric.COSINE);
CreateResult result = LlamaMobileVD.createVectorStore(options);
String storeId = result.getId();

// Add vectors
float[] vector = new float[128];
LlamaMobileVD.addVectorToStore(storeId, vector, "1");

// Search
float[] query = new float[128];
SearchResult searchResult = LlamaMobileVD.searchVectorStore(storeId, query, 5);
System.out.println("Search results: " + searchResult);

// Release
LlamaMobileVD.releaseVectorStore(storeId);
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

### VectorStore Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `createVectorStore` | Create a new vector store | `dimension: number`, `metric: DistanceMetric` | `{ id: string }` |
| `addVectorToStore` | Add a vector to the store | `id: string`, `vector: number[]`, `vectorId: string` | `{ success: boolean }` |
| `searchVectorStore` | Search for nearest neighbors | `id: string`, `query: number[]`, `k: number` | `{ results: { vectorId: string, distance: number }[] }` |
| `countVectorsInStore` | Get count of vectors | `id: string` | `{ count: number }` |
| `clearVectorStore` | Clear all vectors | `id: string` | `{ success: boolean }` |
| `releaseVectorStore` | Release resources | `id: string` | `{ success: boolean }` |

### HNSWIndex Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `createHNSWIndex` | Create a new HNSW index | `dimension: number`, `metric: DistanceMetric`, `m: number`, `efConstruction: number`, `efSearch: number` | `{ id: string }` |
| `addVectorToIndex` | Add a vector to the index | `id: string`, `vector: number[]`, `vectorId: string` | `{ success: boolean }` |
| `searchHNSWIndex` | Search for nearest neighbors | `id: string`, `query: number[]`, `k: number` | `{ results: { vectorId: string, distance: number }[] }` |
| `countVectorsInIndex` | Get count of vectors | `id: string` | `{ count: number }` |
| `clearHNSWIndex` | Clear all vectors | `id: string` | `{ success: boolean }` |
| `releaseHNSWIndex` | Release resources | `id: string` | `{ success: boolean }` |

### Distance Metrics

All SDKs support the following distance metrics:

- `L2`: Euclidean distance
- `COSINE`: Cosine similarity
- `DOT`: Dot product

## License

MIT License - see LICENSE for details.
