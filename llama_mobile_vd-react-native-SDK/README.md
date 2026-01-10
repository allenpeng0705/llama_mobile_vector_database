# LlamaMobileVD React Native SDK

A high-performance vector database for React Native applications using LlamaMobileVD. This SDK provides exact vector search (VectorStore) and approximate nearest neighbor search (HNSWIndex) with support for L2, Cosine, and Dot distance metrics.

## Features

- **VectorStore**: High-performance exact vector search
- **HNSWIndex**: Efficient approximate nearest neighbor search using Hierarchical Navigable Small World graphs
- **Distance Metrics**: Support for L2 (Euclidean), Cosine similarity, and Dot product distance metrics
- **Cross-Platform**: Works on both iOS and Android
- **TypeScript Support**: Full TypeScript definitions for type safety
- **Easy to Integrate**: Simple API with comprehensive documentation

## Installation

### 1. Install the package

```bash
npm install /path/to/llama_mobile_vd-react-native-SDK
# or
yarn add /path/to/llama_mobile_vd-react-native-SDK
```

### 2. Link native modules

For React Native 0.60+, autolinking should work automatically. For older versions, you may need to link manually.

#### iOS

```bash
cd ios && pod install && cd ..
```

#### Android

No additional steps are needed for Android if using React Native 0.60+ with autolinking.

## Usage

### VectorStore (Exact Search)

```javascript
import LlamaMobileVD, { DistanceMetric } from 'llama-mobile-vd';

// Create a VectorStore
const vectorStoreOptions = {
  dimension: 128,
  metric: DistanceMetric.L2 // or DistanceMetric.COSINE or DistanceMetric.DOT
};

const { id: vectorStoreId } = await LlamaMobileVD.createVectorStore(vectorStoreOptions);

// Add vectors to the store
const vector1 = Array(128).fill(0.5);
await LlamaMobileVD.addVectorToStore({ id: vectorStoreId, vector: vector1 });

const vector2 = Array(128).fill(0.7);
await LlamaMobileVD.addVectorToStore({ id: vectorStoreId, vector: vector2, label: 'vector-2' });

// Search for vectors
const queryVector = Array(128).fill(0.6);
const results = await LlamaMobileVD.searchVectorStore({
  id: vectorStoreId,
  queryVector: queryVector,
  k: 2
});

console.log('Search results:', results);
// Output: [{ index: 1, distance: 0.2 }, { index: 0, distance: 0.1 }]

// Count vectors in the store
const { count } = await LlamaMobileVD.countVectorStore({ id: vectorStoreId });
console.log('Vector count:', count);

// Clear all vectors from the store
await LlamaMobileVD.clearVectorStore({ id: vectorStoreId });

// Release resources when done
await LlamaMobileVD.releaseVectorStore({ id: vectorStoreId });
```

### HNSWIndex (Approximate Search)

```javascript
import LlamaMobileVD, { DistanceMetric } from 'llama-mobile-vd';

// Create an HNSWIndex
const hnswOptions = {
  dimension: 128,
  metric: DistanceMetric.COSINE,
  m: 16,              // Maximum number of connections per node
  efConstruction: 200 // Size of the dynamic list used during construction
};

const { id: hnswIndexId } = await LlamaMobileVD.createHNSWIndex(hnswOptions);

// Add vectors to the index
for (let i = 0; i < 100; i++) {
  const vector = Array(128).fill(Math.random());
  await LlamaMobileVD.addVectorToHNSW({ id: hnswIndexId, vector: vector });
}

// Search the index
const queryVector = Array(128).fill(0.5);
const results = await LlamaMobileVD.searchHNSWIndex({
  id: hnswIndexId,
  queryVector: queryVector,
  k: 10
});

console.log('HNSW search results:', results);

// Count vectors in the index
const { count } = await LlamaMobileVD.countHNSWIndex({ id: hnswIndexId });
console.log('HNSW vector count:', count);

// Clear all vectors from the index
await LlamaMobileVD.clearHNSWIndex({ id: hnswIndexId });

// Release resources when done
await LlamaMobileVD.releaseHNSWIndex({ id: hnswIndexId });
```

## API Reference

### DistanceMetric

An enum representing the distance metrics supported by the vector database.

- `L2`: Euclidean distance
- `COSINE`: Cosine similarity (converted to distance)
- `DOT`: Dot product (converted to distance)

### VectorStoreOptions

Options for creating a VectorStore.

```typescript
interface VectorStoreOptions {
  dimension: number;     // The dimension of the vectors
  metric: DistanceMetric; // The distance metric to use
}
```

### HNSWIndexOptions

Options for creating an HNSWIndex.

```typescript
interface HNSWIndexOptions {
  dimension: number;      // The dimension of the vectors
  metric: DistanceMetric;  // The distance metric to use
  m: number;              // Maximum number of connections per node
  efConstruction: number; // Size of the dynamic list used during construction
}
```

### AddVectorParams

Parameters for adding a vector to a VectorStore or HNSWIndex.

```typescript
interface AddVectorParams {
  id: string;              // ID of the store or index
  vector: number[];        // The vector to add
  label?: string;          // Optional label for the vector
}
```

### SearchParams

Parameters for searching a VectorStore or HNSWIndex.

```typescript
interface SearchParams {
  id: string;              // ID of the store or index
  queryVector: number[];   // The query vector
  k: number;               // Number of nearest neighbors to return
}
```

### SearchResult

Result of a search operation.

```typescript
interface SearchResult {
  index: number;           // Index of the matched vector
  distance: number;        // Distance to the query vector
}
```

### Methods

#### `createVectorStore(options: VectorStoreOptions): Promise<{ id: string }>`
Create a new VectorStore.

#### `createHNSWIndex(options: HNSWIndexOptions): Promise<{ id: string }>`
Create a new HNSWIndex.

#### `addVectorToStore(params: AddVectorParams): Promise<void>`
Add a vector to a VectorStore.

#### `addVectorToHNSW(params: AddVectorParams): Promise<void>`
Add a vector to an HNSWIndex.

#### `searchVectorStore(params: SearchParams): Promise<SearchResult[]>`
Search for vectors in a VectorStore.

#### `searchHNSWIndex(params: SearchParams): Promise<SearchResult[]>`
Search for vectors in an HNSWIndex.

#### `countVectorStore(params: { id: string }): Promise<{ count: number }>`
Count the number of vectors in a VectorStore.

#### `countHNSWIndex(params: { id: string }): Promise<{ count: number }>`
Count the number of vectors in an HNSWIndex.

#### `clearVectorStore(params: { id: string }): Promise<void>`
Clear all vectors from a VectorStore.

#### `clearHNSWIndex(params: { id: string }): Promise<void>`
Clear all vectors from an HNSWIndex.

#### `releaseVectorStore(params: { id: string }): Promise<void>`
Release resources associated with a VectorStore.

#### `releaseHNSWIndex(params: { id: string }): Promise<void>`
Release resources associated with an HNSWIndex.

## Build from Source

If you need to build the SDK from source, you can use the provided build script:

```bash
cd /path/to/llama_mobile/llama_mobile_vd
bash scripts/build-rn-SDK.sh
```

This script will copy the pre-built native libraries (iOS framework and Android JNI libraries) to the React Native SDK directory.

## Testing

The SDK includes tests for the JavaScript interface. You can run them with:

```bash
cd /path/to/llama_mobile_vd-react-native-SDK
npm test
```

## Troubleshooting

### iOS Issues

- Make sure you have run `pod install` in the iOS directory
- Check that the LlamaMobileVD.framework is properly linked in your Xcode project
- Ensure you have the necessary permissions and frameworks in your Info.plist if required

### Android Issues

- Make sure the JNI libraries are properly copied to the android/src/main/jniLibs directory
- Check that the Java source files are properly included in your project
- Ensure you have the correct NDK version specified in your project configuration

## License

Apache-2.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please open an issue on the GitHub repository.
