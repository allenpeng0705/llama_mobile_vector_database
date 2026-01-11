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

// Add vectors to the store with explicit vector IDs
const vector1 = Array(128).fill(0.5);
await LlamaMobileVD.addVectorToStore({ id: vectorStoreId, vector: vector1, vectorId: 1 });

const vector2 = Array(128).fill(0.7);
await LlamaMobileVD.addVectorToStore({ id: vectorStoreId, vector: vector2, vectorId: 2 });

// Update a vector
const updatedVector = Array(128).fill(0.8);
await LlamaMobileVD.updateVectorInStore({ id: vectorStoreId, vectorId: 2, vector: updatedVector });

// Remove a vector
await LlamaMobileVD.removeVectorFromStore({ id: vectorStoreId, vectorId: 1 });

// Check if a vector exists
const exists = await LlamaMobileVD.containsVectorInStore({ id: vectorStoreId, vectorId: 2 });
console.log('Vector exists:', exists);

// Get a specific vector
const retrievedVector = await LlamaMobileVD.getVectorFromStore({ id: vectorStoreId, vectorId: 2 });

// Reserve space for more vectors (improves performance)
await LlamaMobileVD.reserveVectorStore({ id: vectorStoreId, capacity: 100 });

// Get VectorStore information
const { dimension } = await LlamaMobileVD.getVectorStoreDimension({ id: vectorStoreId });
const { metric } = await LlamaMobileVD.getVectorStoreMetric({ id: vectorStoreId });
console.log(`VectorStore dimension: ${dimension}, metric: ${metric}`);

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

// Add vectors to the index with explicit vector IDs
for (let i = 0; i < 100; i++) {
  const vector = Array(128).fill(Math.random());
  await LlamaMobileVD.addVectorToHNSW({ id: hnswIndexId, vector: vector, vectorId: i + 1 });
}

// Set and get efSearch parameter
await LlamaMobileVD.setHNSWEfSearch({ id: hnswIndexId, efSearch: 100 });
const { efSearch } = await LlamaMobileVD.getHNSWEfSearch({ id: hnswIndexId });
console.log('Current efSearch:', efSearch);

// Check if a vector exists
const exists = await LlamaMobileVD.containsVectorInHNSW({ id: hnswIndexId, vectorId: 50 });

// Get a specific vector
const vector = await LlamaMobileVD.getVectorFromHNSW({ id: hnswIndexId, vectorId: 50 });

// Get HNSWIndex information
const { dimension } = await LlamaMobileVD.getHNSWDimension({ id: hnswIndexId });
const { capacity } = await LlamaMobileVD.getHNSWCapacity({ id: hnswIndexId });
console.log(`HNSWIndex dimension: ${dimension}, capacity: ${capacity}`);

// Search the index with custom efSearch
const queryVector = Array(128).fill(0.5);
const results = await LlamaMobileVD.searchHNSWIndex({
  id: hnswIndexId,
  queryVector: queryVector,
  k: 10,
  efSearch: 150 // Optional: override the default efSearch for this search
});

// Save the index to a file
const savePath = '/path/to/hnsw/index';
const saved = await LlamaMobileVD.saveHNSWIndex({ id: hnswIndexId, path: savePath });
console.log('Index saved:', saved);

// Load the index from a file
const { id: loadedIndexId } = await LlamaMobileVD.loadHNSWIndex({ path: savePath });
console.log('Loaded index ID:', loadedIndexId);

// Search the loaded index
const loadedResults = await LlamaMobileVD.searchHNSWIndex({
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
  vectorId: number;        // Unique ID for the vector
}
```

### VersionParams

Parameters for getting version information (all methods are parameter-less).

```typescript
interface VersionParams {
  // No parameters
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

#### VectorStore Methods

#### `createVectorStore(options: VectorStoreOptions): Promise<{ id: string }>`
Create a new VectorStore.

#### `addVectorToStore(params: AddVectorParams): Promise<void>`
Add a vector to a VectorStore.

#### `removeVectorFromStore(params: { id: string, vectorId: number }): Promise<boolean>`
Remove a vector from a VectorStore by ID.

#### `getVectorFromStore(params: { id: string, vectorId: number }): Promise<number[] | null>`
Get a vector from a VectorStore by ID.

#### `updateVectorInStore(params: { id: string, vectorId: number, vector: number[] }): Promise<boolean>`
Update a vector in a VectorStore by ID.

#### `containsVectorInStore(params: { id: string, vectorId: number }): Promise<boolean>`
Check if a VectorStore contains a vector with the given ID.

#### `reserveVectorStore(params: { id: string, capacity: number }): Promise<void>`
Reserve space for vectors in a VectorStore.

#### `getVectorStoreDimension(params: { id: string }): Promise<{ dimension: number }>`
Get the dimension of vectors in a VectorStore.

#### `getVectorStoreMetric(params: { id: string }): Promise<{ metric: string }>`
Get the distance metric used by a VectorStore.

#### `searchVectorStore(params: SearchParams): Promise<SearchResult[]>`
Search for vectors in a VectorStore.

#### `countVectorStore(params: { id: string }): Promise<{ count: number }>`
Count the number of vectors in a VectorStore.

#### `clearVectorStore(params: { id: string }): Promise<void>`
Clear all vectors from a VectorStore.

#### `releaseVectorStore(params: { id: string }): Promise<void>`
Release resources associated with a VectorStore.

#### HNSWIndex Methods

#### `createHNSWIndex(options: HNSWIndexOptions): Promise<{ id: string }>`
Create a new HNSWIndex.

#### `addVectorToHNSW(params: AddVectorParams): Promise<void>`
Add a vector to an HNSWIndex.

#### `searchHNSWIndex(params: SearchParams & { efSearch?: number }): Promise<SearchResult[]>`
Search for vectors in an HNSWIndex.

#### `setHNSWEfSearch(params: { id: string, efSearch: number }): Promise<void>`
Set the efSearch parameter for an HNSWIndex.

#### `getHNSWEfSearch(params: { id: string }): Promise<{ efSearch: number }>`
Get the current efSearch parameter for an HNSWIndex.

#### `containsVectorInHNSW(params: { id: string, vectorId: number }): Promise<boolean>`
Check if an HNSWIndex contains a vector with the given ID.

#### `getVectorFromHNSW(params: { id: string, vectorId: number }): Promise<number[] | null>`
Get a vector from an HNSWIndex by ID.

#### `getHNSWDimension(params: { id: string }): Promise<{ dimension: number }>`
Get the dimension of vectors in an HNSWIndex.

#### `getHNSWCapacity(params: { id: string }): Promise<{ capacity: number }>`
Get the capacity of an HNSWIndex.

#### `saveHNSWIndex(params: { id: string, path: string }): Promise<boolean>`
Save an HNSWIndex to a file.

#### `loadHNSWIndex(params: { path: string }): Promise<{ id: string }>`
Load an HNSWIndex from a file.

#### `countHNSWIndex(params: { id: string }): Promise<{ count: number }>`
Count the number of vectors in an HNSWIndex.

#### `clearHNSWIndex(params: { id: string }): Promise<void>`
Clear all vectors from an HNSWIndex.

#### `releaseHNSWIndex(params: { id: string }): Promise<void>`
Release resources associated with an HNSWIndex.

#### Version Methods

#### `getVersion(): Promise<{ version: string }>`
Get the version of the LlamaMobileVD SDK.

#### `getVersionMajor(): Promise<{ major: number }>`
Get the major version component.

#### `getVersionMinor(): Promise<{ minor: number }>`
Get the minor version component.

#### `getVersionPatch(): Promise<{ patch: number }>`
Get the patch version component.

## Build from Source

If you need to build the SDK from source, you can use the provided build script:

```bash
cd /path/to/llama_mobile_vector_database
bash scripts/build-rn-SDK.sh
```

This script will copy the pre-built native libraries (iOS framework and Android JNI libraries) to the React Native SDK directory.

## Testing

The SDK includes comprehensive tests for the JavaScript interface that cover all API functionality:

### Running Tests

```bash
cd /path/to/llama_mobile_vd-react-native-SDK
npm test
```

### Test Coverage

The test suite covers:
- VectorStore creation, addition, search, and deletion operations
- HNSWIndex creation, addition, search, and deletion operations
- All distance metrics (L2, Cosine, Dot)
- Mocked native module responses
- Error handling scenarios
- Edge cases with different vector IDs
- Search result validation

### Adding New Tests

Tests are located in the `__tests__` directory. Each test file follows the pattern `index.test.js` and uses Jest as the testing framework.

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
