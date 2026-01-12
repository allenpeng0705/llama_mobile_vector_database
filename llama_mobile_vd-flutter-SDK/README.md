# LlamaMobileVD Flutter SDK

A high-performance vector database for Flutter applications, providing efficient storage and similarity search capabilities for vectors on mobile devices.

## Features

- **VectorStore**: A simple and efficient vector storage and search implementation
- **HNSWIndex**: A high-performance approximate nearest neighbor (ANN) search index using the Hierarchical Navigable Small World (HNSW) algorithm
- **MMapVectorStore**: A memory-mapped vector store optimized for large datasets and fast access
- **Multiple Distance Metrics**: Support for L2 (Euclidean), Cosine similarity, and Dot product distances
- **Cross-Platform**: Works on both iOS and Android with identical API
- **Efficient**: Optimized for mobile devices with minimal memory footprint

## Installation

To use this plugin, add `llama_mobile_vd` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  llama_mobile_vd:
    path: /path/to/llama_mobile_vd-flutter-SDK
```

Then run:

```bash
flutter pub get
```

## iOS Setup

The iOS framework is already included in the plugin. The plugin supports iOS 13.0 and above.

## Android Setup

The Android library is already included in the plugin. The plugin supports Android API level 24 (Android 7.0) and above.

## Usage

### Initializing the SDK

First, import the LlamaMobileVD package:

```dart
import 'package:llama_mobile_vd/llama_mobile_vd.dart';
```

### Using VectorStore

The VectorStore provides a simple interface for storing and searching vectors:

```dart
// Create a VectorStore with dimension 128 and L2 distance metric
final vectorStore = await VectorStore.create(
  dimension: 128,
  metric: DistanceMetric.l2,
);

// Reserve space for vectors (optional but improves performance)
await vectorStore.reserve(100);

// Add vectors to the store
final vector1 = List<double>.generate(128, (i) => i.toDouble());
final vector2 = List<double>.generate(128, (i) => (i * 2).toDouble());

await vectorStore.addVector(vector1, id: 1);
await vectorStore.addVector(vector2, id: 2);

// Get the number of vectors in the store
final count = await vectorStore.count;
print('Number of vectors: $count');

// Check if a vector exists
final exists = await vectorStore.contains(1);
print('Vector 1 exists: $exists');

// Get a vector by ID
final retrievedVector = await vectorStore.get(1);
print('Retrieved vector length: ${retrievedVector?.length}');

// Update a vector
final updatedVector = List<double>.generate(128, (i) => (i * 3).toDouble());
await vectorStore.update(1, updatedVector);

// Check the updated vector
final checkUpdatedVector = await vectorStore.get(1);
print('Updated vector first element: ${checkUpdatedVector?.first}');

// Search for nearest neighbors
final queryVector = List<double>.generate(128, (i) => i.toDouble());
final results = await vectorStore.search(queryVector, k: 2);

// Print the search results
for (final result in results) {
  print('Vector ID: ${result.id}, Distance: ${result.distance}');
}

// Remove a vector
final removed = await vectorStore.remove(2);
print('Vector 2 removed: $removed');

// Get vector store information
final dimension = await vectorStore.dimension();
final metric = await vectorStore.metric();
print('Vector store dimension: $dimension, metric: $metric');

// Clear all vectors
await vectorStore.clear();

// Destroy the vector store when no longer needed
await vectorStore.dispose();
```

### Using HNSWIndex

The HNSWIndex provides faster approximate nearest neighbor search:

```dart
// Create an HNSWIndex with dimension 128 and Cosine distance metric
final index = await HNSWIndex.create(
  dimension: 128,
  metric: DistanceMetric.cosine,
  m: 16,              // Maximum number of connections per node
  efConstruction: 200, // Size of the dynamic list for construction
);

// Set efSearch parameter
await index.setEfSearch(100);

// Add vectors to the index
final vector1 = List<double>.generate(128, (i) => i.toDouble());
final vector2 = List<double>.generate(128, (i) => (i * 2).toDouble());

await index.addVector(vector1, id: 1);
await index.addVector(vector2, id: 2);

// Get the number of vectors in the index
final count = await index.count;
print('Number of vectors: $count');

// Get index information
final dimension = await index.dimension();
final capacity = await index.capacity();
final efSearch = await index.getEfSearch();
print('Index dimension: $dimension, capacity: $capacity, efSearch: $efSearch');

// Check if a vector exists
final exists = await index.contains(1);
print('Vector 1 exists: $exists');

// Get a vector by ID
final retrievedVector = await index.getVector(1);
print('Retrieved vector length: ${retrievedVector?.length}');

// Search for nearest neighbors
final queryVector = List<double>.generate(128, (i) => i.toDouble());
final results = await index.search(
  queryVector, 
  k: 2, 
  efSearch: efSearch, // Use the configured efSearch parameter
);

// Print the search results
for (final result in results) {
  print('Vector ID: ${result.id}, Distance: ${result.distance}');
}

// Save the index to a file (platform-specific path handling needed)
final savePath = '/path/to/index.hnsw'; // Replace with actual path
final saved = await index.save(savePath);
print('Index saved: $saved');

// Destroy the original index
await index.dispose();

// Load the index from file
final loadedIndex = await HNSWIndex.load(savePath);

// Verify the loaded index
final loadedCount = await loadedIndex.count;
print('Loaded index vector count: $loadedCount');

// Search in the loaded index
final loadedResults = await loadedIndex.search(
  queryVector, 
  k: 2, 
  efSearch: 50,
);

// Print the search results from loaded index
for (final result in loadedResults) {
  print('Loaded index - Vector ID: ${result.id}, Distance: ${result.distance}');
}

// Clear all vectors
await loadedIndex.clear();

// Destroy the loaded index when no longer needed
await loadedIndex.dispose();
```

### Using MMapVectorStore

The MMapVectorStore provides efficient access to large vector datasets using memory-mapped files:

```dart
// Open an existing MMapVectorStore
final mmapStore = await MMapVectorStore.open(path: '/path/to/vectorstore.mmap');

// Get basic information about the store
final count = await mmapStore.count;
print('Number of vectors: $count');

final dimension = await mmapStore.dimension;
print('Vector dimension: $dimension');

final metric = await mmapStore.metric;
print('Distance metric: $metric');

// Search for nearest neighbors
final queryVector = List<double>.generate(dimension, (i) => i.toDouble());
final results = await mmapStore.search(queryVector, k: 5);

// Print the search results
for (final result in results) {
  print('Vector ID: ${result.id}, Distance: ${result.distance}');
}

// Close the MMapVectorStore when no longer needed
await mmapStore.dispose();
```

## API Reference

### DistanceMetric

An enum representing the distance metrics supported by LlamaMobileVD:

- `DistanceMetric.l2`: Euclidean distance
- `DistanceMetric.cosine`: Cosine similarity
- `DistanceMetric.dot`: Dot product

### SearchResult

A class representing a result from a vector search operation:

```dart
class SearchResult {
  final int id;           // The ID of the vector
  final double distance;  // The distance between the query vector and the result vector
}
```

### VectorStore

A vector store for efficiently storing and searching vectors.

#### Methods

- `static Future<VectorStore> create({required int dimension, required DistanceMetric metric})`: Creates a new vector store
- `Future<void> addVector(List<double> vector, int id)`: Adds a vector to the store
- `Future<List<SearchResult>> search(List<double> queryVector, int k)`: Searches for the nearest neighbors of a query vector
- `Future<int> get count`: Gets the number of vectors in the store
- `Future<void> clear()`: Clears all vectors from the store
- `Future<void> dispose()`: Destroys the vector store and frees resources
- `Future<bool> remove(int id)`: Removes a vector by ID (returns true if successful)
- `Future<List<double>?> get(int id)`: Gets a vector by ID (returns null if not found)
- `Future<bool> update(int id, List<double> vector)`: Updates an existing vector (returns true if successful)
- `Future<int> dimension()`: Gets the dimension of vectors in the store
- `Future<DistanceMetric> metric()`: Gets the distance metric used by the store
- `Future<bool> contains(int id)`: Checks if a vector exists by ID
- `Future<void> reserve(int capacity)`: Reserves space for a specified number of vectors

### HNSWIndex

A high-performance approximate nearest neighbor search index using the HNSW algorithm.

#### Methods

- `static Future<HNSWIndex> create({required int dimension, required DistanceMetric metric, int m = 16, int efConstruction = 200})`: Creates a new HNSW index
- `Future<void> addVector(List<double> vector, int id)`: Adds a vector to the index
- `Future<List<SearchResult>> search(List<double> queryVector, int k, {int efSearch = 50})`: Searches for the nearest neighbors of a query vector
- `Future<int> get count`: Gets the number of vectors in the index
- `Future<void> clear()`: Clears all vectors from the index
- `Future<void> dispose()`: Destroys the index and frees resources
- `Future<void> setEfSearch(int efSearch)`: Sets the efSearch parameter for search operations
- `Future<int> getEfSearch()`: Gets the current efSearch parameter
- `Future<int> dimension()`: Gets the dimension of vectors in the index
- `Future<int> capacity()`: Gets the capacity of the index
- `Future<bool> contains(int id)`: Checks if a vector exists by ID
- `Future<List<double>?> getVector(int id)`: Gets a vector by ID (returns null if not found)
- `Future<bool> save(String path)`: Saves the index to a file (returns true if successful)
- `static Future<HNSWIndex> load(String path)`: Loads an index from a file

#### Parameters

- `dimension`: The dimension of the vectors
- `metric`: The distance metric to use
- `m`: The maximum number of connections per node (default: 16)
- `efConstruction`: The size of the dynamic list for candidate selection during construction (default: 200)
- `efSearch`: The size of the dynamic list for candidate selection during search (default: 50)

### MMapVectorStore

A memory-mapped vector store optimized for large datasets and fast access. This store reads vector data directly from disk using memory mapping, providing efficient access to large datasets without loading everything into memory.

#### Methods

- `static Future<MMapVectorStore> open({required String path})`: Opens an existing MMapVectorStore from a file
- `Future<List<SearchResult>> search(List<double> queryVector, int k)`: Searches for the nearest neighbors of a query vector
- `Future<int> get count`: Gets the number of vectors in the store
- `Future<int> get dimension`: Gets the dimension of vectors in the store
- `Future<DistanceMetric> get metric`: Gets the distance metric used by the store
- `Future<void> dispose()`: Closes the MMapVectorStore and frees resources

#### Parameters

- `path`: The path to the MMapVectorStore file
- `k`: The number of nearest neighbors to retrieve

### Version Information

The LlamaMobileVD SDK provides methods to get version information:

- `Future<String> getLlamaMobileVDVersion()`: Gets the full version string (e.g., "1.0.0")
- `Future<int> getLlamaMobileVDVersionMajor()`: Gets the major version number
- `Future<int> getLlamaMobileVDVersionMinor()`: Gets the minor version number
- `Future<int> getLlamaMobileVDVersionPatch()`: Gets the patch version number

#### Example

```dart
// Get the full version string
final version = await getLlamaMobileVDVersion();
print('Version: $version');

// Get individual version components
final major = await getLlamaMobileVDVersionMajor();
final minor = await getLlamaMobileVDVersionMinor();
final patch = await getLlamaMobileVDVersionPatch();
print('Version components: $major.$minor.$patch');
```

## Performance Tips

- **Vector Dimensions**: Smaller vector dimensions will result in faster search and lower memory usage
- **HNSW Parameters**: 
  - Increase `m` for higher accuracy but increased memory usage
  - Increase `efConstruction` for higher accuracy during index construction
  - Increase `efSearch` for higher accuracy during search (but slower performance)
- **Batch Operations**: When adding many vectors, consider batching operations for better performance
- **Resource Management**: Always call `dispose()` when you're done with a VectorStore or HNSWIndex to free up resources

## Error Handling

All methods that can fail throw exceptions. It's recommended to wrap calls in try-catch blocks:

```dart
try {
  final vectorStore = await VectorStore.create(
    dimension: 128,
    metric: DistanceMetric.l2,
  );
  // Use the vector store
} catch (e) {
  print('Error: $e');
}
```

## Platform Specific Notes

### iOS

- Requires iOS 13.0 or later
- The framework is built for arm64 architecture (both device and simulator)

### Android

- Requires Android API level 24 (Android 7.0) or later
- Supports arm64-v8a and x86_64 architectures

## Running Tests

The Flutter SDK includes a comprehensive test suite that covers all API functionality:

### Using VS Code

1. Open VS Code and select `File > Open Folder`
2. Navigate to the `llama_mobile_vd-flutter-SDK` directory
3. Install the Flutter extension if not already installed
4. Open the test file at `test/llama_mobile_vd_test.dart`
5. Click the "Run" button above the test functions or select `Run > Start Debugging`

### Using Terminal

To run the tests from the command line:

```bash
cd /path/to/llama_mobile_vector_database/llama_mobile_vd-flutter-SDK
flutter test
```

### Test Coverage

The test suite covers:
- VectorStore creation, addition, search, and deletion operations
- HNSWIndex creation, addition, search, and deletion operations
- MMapVectorStore opening, search, and metadata operations
- All distance metrics (L2, Cosine, Dot)
- Various vector dimensions (including large 3072-dimensional vectors)
- Mocked platform channel communication
- Error handling scenarios

## License

[Your License Here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
