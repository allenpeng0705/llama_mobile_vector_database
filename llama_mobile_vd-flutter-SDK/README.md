# LlamaMobileVD Flutter SDK

A high-performance vector database for Flutter applications, providing efficient storage and similarity search capabilities for vectors on mobile devices.

## Features

- **VectorStore**: A simple and efficient vector storage and search implementation
- **HNSWIndex**: A high-performance approximate nearest neighbor (ANN) search index using the Hierarchical Navigable Small World (HNSW) algorithm
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

// Add vectors to the store
final vector1 = List<double>.generate(128, (i) => i.toDouble());
final vector2 = List<double>.generate(128, (i) => (i * 2).toDouble());

await vectorStore.addVector(vector1, id: 1);
await vectorStore.addVector(vector2, id: 2);

// Get the number of vectors in the store
final count = await vectorStore.count;
print('Number of vectors: $count');

// Search for nearest neighbors
final queryVector = List<double>.generate(128, (i) => i.toDouble());
final results = await vectorStore.search(queryVector, k: 1);

// Print the search results
for (final result in results) {
  print('Vector ID: ${result.id}, Distance: ${result.distance}');
}

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

// Add vectors to the index
final vector1 = List<double>.generate(128, (i) => i.toDouble());
final vector2 = List<double>.generate(128, (i) => (i * 2).toDouble());

await index.addVector(vector1, id: 1);
await index.addVector(vector2, id: 2);

// Get the number of vectors in the index
final count = await index.count;
print('Number of vectors: $count');

// Search for nearest neighbors with efSearch parameter
final queryVector = List<double>.generate(128, (i) => i.toDouble());
final results = await index.search(
  queryVector, 
  k: 1, 
  efSearch: 50, // Size of the dynamic list for search (higher = more accurate but slower)
);

// Print the search results
for (final result in results) {
  print('Vector ID: ${result.id}, Distance: ${result.distance}');
}

// Clear all vectors
await index.clear();

// Destroy the index when no longer needed
await index.dispose();
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

### HNSWIndex

A high-performance approximate nearest neighbor search index using the HNSW algorithm.

#### Methods

- `static Future<HNSWIndex> create({required int dimension, required DistanceMetric metric, int m = 16, int efConstruction = 200})`: Creates a new HNSW index
- `Future<void> addVector(List<double> vector, int id)`: Adds a vector to the index
- `Future<List<SearchResult>> search(List<double> queryVector, int k, {int efSearch = 50})`: Searches for the nearest neighbors of a query vector
- `Future<int> get count`: Gets the number of vectors in the index
- `Future<void> clear()`: Clears all vectors from the index
- `Future<void> dispose()`: Destroys the index and frees resources

#### Parameters

- `dimension`: The dimension of the vectors
- `metric`: The distance metric to use
- `m`: The maximum number of connections per node (default: 16)
- `efConstruction`: The size of the dynamic list for candidate selection during construction (default: 200)
- `efSearch`: The size of the dynamic list for candidate selection during search (default: 50)

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

## License

[Your License Here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
