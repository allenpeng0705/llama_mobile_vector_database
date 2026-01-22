# Llama Mobile Vector Database Flutter SDK

Flutter SDK for Llama Mobile Vector Database, providing cross-platform access to vector database operations on iOS and Android.

## SDK Structure

The Flutter SDK follows the standard Flutter plugin structure:

```
llama_mobile_vd-flutter-SDK/
├── android/             # Android plugin implementation
│   ├── src/main/java/com/llamamobile/vd/  # Kotlin wrapper
│   └── src/main/cpp/    # JNI wrapper for native lib
├── ios/                 # iOS plugin implementation
│   └── Classes/         # Swift wrapper
├── lib/                 # Flutter Dart API
├── test/                # Tests
├── scripts/             # Build scripts
├── pubspec.yaml         # Flutter package configuration
└── README.md            # This file
```

## Installation

### Prerequisites

- Flutter SDK (version 3.0.0 or later)
- iOS SDK (version 13.0 or later)
- Android SDK (version 21 or later)

### Adding the SDK to Your Flutter Project

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/llama_mobile_vector_database.git
   ```

2. Add the SDK to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     llama_mobile_vd_flutter_sdk:
       path: path/to/llama_mobile_vd-flutter-SDK
   ```

3. Run `flutter pub get` to install the dependencies.

## Usage

### Initialization

Import the SDK in your Dart code:

```dart
import 'package:llama_mobile_vd_flutter_sdk/llama_mobile_vd_flutter_sdk.dart';
```

### VectorStore

```dart
// Create a VectorStore
final vectorStore = await VectorStore.create(128, DistanceMetric.cosine);

// Add vectors
await vectorStore.addVector(1, List.generate(128, (i) => i.toDouble()));
await vectorStore.addVector(2, List.generate(128, (i) => (i * 2).toDouble()));

// Search vectors
final results = await vectorStore.search(List.generate(128, (i) => i.toDouble()), 3);
print('Search results: $results');

// Get vector
final vector = await vectorStore.getVector(1);
print('Vector 1: $vector');

// Update vector
await vectorStore.updateVector(1, List.generate(128, (i) => (i * 3).toDouble()));

// Remove vector
await vectorStore.removeVector(2);

// Get size
final size = await vectorStore.getSize();
print('VectorStore size: $size');

// Clear all vectors
await vectorStore.clear();

// Destroy the VectorStore
await vectorStore.destroy();
```

### HNSWIndex

```dart
// Create an HNSWIndex
final hnswIndex = await HNSWIndex.create(128, DistanceMetric.cosine, 1000);

// Add vectors
await hnswIndex.addVector(1, List.generate(128, (i) => i.toDouble()));
await hnswIndex.addVector(2, List.generate(128, (i) => (i * 2).toDouble()));

// Set search parameters
await hnswIndex.setEfSearch(64);

// Search vectors
final results = await hnswIndex.search(List.generate(128, (i) => i.toDouble()), 3);
print('Search results: $results');

// Save index
await hnswIndex.save('index.bin');

// Load index
final loadedIndex = await HNSWIndex.load('index.bin');

// Destroy the HNSWIndex
await hnswIndex.destroy();
await loadedIndex.destroy();
```

### MMapVectorStore

```dart
// Create an MMapVectorStoreBuilder
final builder = await MMapVectorStoreBuilder.create(128, DistanceMetric.cosine);

// Add vectors
await builder.addVector(1, List.generate(128, (i) => i.toDouble()));
await builder.addVector(2, List.generate(128, (i) => (i * 2).toDouble()));

// Save to file
await builder.save('mmap_store.dat');
await builder.destroy();

// Open MMapVectorStore
final mmapStore = await MMapVectorStore.open('mmap_store.dat');

// Search vectors
final results = await mmapStore.search(List.generate(128, (i) => i.toDouble()), 3);
print('Search results: $results');

// Get vector
final vector = await mmapStore.getVector(1);
print('Vector 1: $vector');

// Close MMapVectorStore
await mmapStore.close();
```

## API Reference

### Enums

#### DistanceMetric

- `l2`: Euclidean distance
- `cosine`: Cosine similarity
- `dot`: Dot product

### Classes

#### VectorStore

- `static Future<VectorStore> create(int dimension, DistanceMetric metric)`: Creates a new VectorStore
- `Future<void> addVector(int id, List<double> vector)`: Adds a vector to the store
- `Future<List<SearchResult>> search(List<double> queryVector, int k)`: Searches for nearest neighbors
- `Future<List<double>?> getVector(int id)`: Gets a vector by ID
- `Future<bool> removeVector(int id)`: Removes a vector by ID
- `Future<bool> contains(int id)`: Checks if a vector exists by ID
- `Future<int> getSize()`: Gets the number of vectors in the store
- `Future<int> getDimension()`: Gets the dimension of vectors in the store
- `Future<DistanceMetric> getMetric()`: Gets the distance metric used
- `Future<bool> updateVector(int id, List<double> vector)`: Updates a vector by ID
- `Future<bool> reserve(int capacity)`: Reserves capacity for vectors
- `Future<void> clear()`: Clears all vectors from the store
- `Future<void> destroy()`: Destroys the VectorStore

#### HNSWIndex

- `static Future<HNSWIndex> create(int dimension, DistanceMetric metric, int maxElements)`: Creates a new HNSWIndex
- `static Future<HNSWIndex> createWithParams(int dimension, DistanceMetric metric, int maxElements, int M, int efConstruction, int seed)`: Creates a new HNSWIndex with custom parameters
- `Future<bool> addVector(int id, List<double> vector)`: Adds a vector to the index
- `Future<List<SearchResult>> search(List<double> queryVector, int k)`: Searches for nearest neighbors
- `Future<bool> setEfSearch(int efSearch)`: Sets the search parameter
- `Future<int> getEfSearch()`: Gets the search parameter
- `Future<int> getSize()`: Gets the number of vectors in the index
- `Future<int> getDimension()`: Gets the dimension of vectors in the index
- `Future<int> getCapacity()`: Gets the capacity of the index
- `Future<bool> contains(int id)`: Checks if a vector exists by ID
- `Future<List<double>?> getVector(int id)`: Gets a vector by ID
- `Future<bool> save(String filename)`: Saves the index to a file
- `static Future<HNSWIndex> load(String filename)`: Loads an index from a file
- `Future<void> destroy()`: Destroys the HNSWIndex

#### MMapVectorStoreBuilder

- `static Future<MMapVectorStoreBuilder> create(int dimension, DistanceMetric metric)`: Creates a new MMapVectorStoreBuilder
- `Future<bool> addVector(int id, List<double> vector)`: Adds a vector to the builder
- `Future<bool> reserve(int capacity)`: Reserves capacity for vectors
- `Future<bool> save(String filename)`: Saves the builder to a file
- `Future<int> getSize()`: Gets the number of vectors in the builder
- `Future<int> getDimension()`: Gets the dimension of vectors in the builder
- `Future<void> destroy()`: Destroys the MMapVectorStoreBuilder

#### MMapVectorStore

- `static Future<MMapVectorStore> open(String filename)`: Opens an MMapVectorStore from a file
- `Future<List<double>?> getVector(int id)`: Gets a vector by ID
- `Future<bool> contains(int id)`: Checks if a vector exists by ID
- `Future<List<SearchResult>> search(List<double> queryVector, int k)`: Searches for nearest neighbors
- `Future<int> getSize()`: Gets the number of vectors in the store
- `Future<int> getDimension()`: Gets the dimension of vectors in the store
- `Future<DistanceMetric> getMetric()`: Gets the distance metric used
- `Future<void> close()`: Closes the MMapVectorStore

#### SearchResult

- `final int id`: The ID of the vector
- `final double distance`: The distance to the query vector

## Building the SDK

To build the Flutter SDK, run the build script:

```bash
./scripts/build-flutter-SDK.sh
```

This will:
1. Clean previous builds
2. Run `flutter pub get`
3. Build the iOS framework
4. Build the Android library
5. Run the tests

## Testing

### Running Tests

To run the tests and ensure they all pass, follow these steps:

#### Prerequisites
- Flutter SDK (run `flutter --version` to verify)
- Connected physical device or running emulator (iOS or Android)
- Properly linked native dependencies

#### Running Tests on a Device

```bash
# For iOS device
flutter test --platform ios

# For Android device
flutter test --platform android
```

If multiple devices are connected, specify the device ID:

```bash
flutter test --platform ios --device-id <device-id>
```

### Test Coverage

The test suite covers:

- **VectorStore**: All methods with datasets of 100, 1000, and 10000 vectors
- **HNSWIndex**: All methods with datasets of 1000 and 10000 vectors  
- **MMapVectorStore**: All methods with 1000 vectors
- **Dimensions**: 64D, 128D, 256D, 1024D, and 3096D vectors
- **Distance Metrics**: L2, Cosine, and Dot product

### Expected Behavior

- **Device Tests**: Should pass on physical devices or emulators
- **VM Tests**: Will fail with `MissingPluginException` (expected, as native plugins aren't available on VM)
- **Test Duration**: Some tests with large datasets may take several minutes
- **Memory Usage**: Large dataset tests require devices with sufficient memory

### Troubleshooting

1. **Plugin Registration Issues**:
   - Ensure plugins are properly registered in `MainActivity.kt` (Android) and `AppDelegate.swift` (iOS)

2. **Native Library Issues**:
   - Verify native C libraries are properly built and linked
   - Check iOS framework is included in Xcode project

3. **Memory Constraints**:
   - If tests fail with out-of-memory errors, try reducing dataset size for your specific device

4. **Build Errors**:
   - Run `flutter clean` followed by `flutter pub get` to resolve dependency issues

### Verification

After running tests, you should see output similar to:

```
✓ VectorStore (64D, l2) add and get vector
✓ VectorStore (64D, l2) search vectors with 100 vectors
✓ VectorStore (64D, l2) search vectors with 1000 vectors
...
All tests passed!
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
