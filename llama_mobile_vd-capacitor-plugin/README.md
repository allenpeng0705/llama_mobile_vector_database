# LlamaMobileVD Capacitor Plugin

A high-performance vector database for mobile applications, built on top of LlamaMobileVD and designed for use with Capacitor.

## Features

- **VectorStore**: High-performance vector storage and search
- **HNSWIndex**: Efficient approximate nearest neighbor search using the HNSW algorithm
- **Multiple Distance Metrics**: Support for L2, Cosine, and Dot product distances
- **Cross-Platform**: Works on both iOS and Android
- **Easy to Use**: Simple API with TypeScript definitions

## Installation

```bash
# Install the plugin from local directory
npm install /path/to/llama_mobile_vd-capacitor-plugin

# Sync the plugin with your Capacitor project
npx cap sync
```

## Usage

### Import the Plugin

```typescript
import { LlamaMobileVD, DistanceMetric } from 'capacitor-plugin-llamamobilevd';
```

### VectorStore Example

```typescript
// Create a vector store
const { id } = await LlamaMobileVD.createVectorStore({
  dimension: 128,
  metric: DistanceMetric.COSINE
});

// Add vectors to the store
await LlamaMobileVD.addVectorToStore({
  id: storeId,
  vector: [0.1, 0.2, 0.3, ...], // 128-dimensional vector
  vectorId: 1
});

await LlamaMobileVD.addVectorToStore({
  id: storeId,
  vector: [0.4, 0.5, 0.6, ...], // 128-dimensional vector
  vectorId: 2
});

// Search for nearest neighbors
const { results } = await LlamaMobileVD.searchVectorStore({
  id: storeId,
  queryVector: [0.2, 0.3, 0.4, ...], // 128-dimensional query vector
  k: 3 // Return top 3 results
});

console.log('Search results:', results);
// Output: [{ id: 1, distance: 0.123 }, { id: 2, distance: 0.456 }]

// Get the number of vectors in the store
const { count } = await LlamaMobileVD.getVectorStoreCount({ id: storeId });
console.log('Vector count:', count);

// Clear all vectors from the store
await LlamaMobileVD.clearVectorStore({ id: storeId });

// Release the store when done
await LlamaMobileVD.releaseVectorStore({ id: storeId });
```

### HNSWIndex Example

```typescript
// Create an HNSW index
const { id } = await LlamaMobileVD.createHNSWIndex({
  dimension: 128,
  metric: DistanceMetric.L2,
  m: 16, // Maximum number of connections per node
  efConstruction: 200 // Size of the dynamic list for candidate selection during construction
});

// Add vectors to the index
await LlamaMobileVD.addVectorToIndex({
  id: indexId,
  vector: [0.1, 0.2, 0.3, ...], // 128-dimensional vector
  vectorId: 1
});

await LlamaMobileVD.addVectorToIndex({
  id: indexId,
  vector: [0.4, 0.5, 0.6, ...], // 128-dimensional vector
  vectorId: 2
});

// Search for nearest neighbors
const { results } = await LlamaMobileVD.searchHNSWIndex({
  id: indexId,
  queryVector: [0.2, 0.3, 0.4, ...], // 128-dimensional query vector
  k: 3, // Return top 3 results
  efSearch: 50 // Size of the dynamic list for candidate selection during search
});

console.log('Search results:', results);
// Output: [{ id: 1, distance: 0.123 }, { id: 2, distance: 0.456 }]

// Get the number of vectors in the index
const { count } = await LlamaMobileVD.getHNSWIndexCount({ id: indexId });
console.log('Vector count:', count);

// Clear all vectors from the index
await LlamaMobileVD.clearHNSWIndex({ id: indexId });

// Release the index when done
await LlamaMobileVD.releaseHNSWIndex({ id: indexId });
```

## API Documentation

### DistanceMetric

Enum for distance metrics:

- `DistanceMetric.L2`: Euclidean distance
- `DistanceMetric.COSINE`: Cosine similarity
- `DistanceMetric.DOT`: Dot product

### VectorStore Methods

#### `createVectorStore(options: VectorStoreOptions)`

Create a new vector store.

**Parameters:**
- `options`: 
  - `dimension`: The dimension of the vectors
  - `metric`: The distance metric to use

**Returns:** Promise with the created store ID

#### `addVectorToStore(params: AddVectorParams)`

Add a vector to a vector store.

**Parameters:**
- `params`: 
  - `id`: The ID of the store
  - `vector`: The vector to add
  - `vectorId`: The ID to associate with the vector

**Returns:** Promise that resolves when the vector is added

#### `searchVectorStore(params: VectorStoreSearchParams)`

Search for nearest neighbors in a vector store.

**Parameters:**
- `params`: 
  - `id`: The ID of the store
  - `queryVector`: The query vector
  - `k`: The number of nearest neighbors to return

**Returns:** Promise with search results

#### `getVectorStoreCount(params: CountParams)`

Get the number of vectors in a vector store.

**Parameters:**
- `params`: 
  - `id`: The ID of the store

**Returns:** Promise with the count of vectors

#### `clearVectorStore(params: ClearParams)`

Clear all vectors from a vector store.

**Parameters:**
- `params`: 
  - `id`: The ID of the store

**Returns:** Promise that resolves when the store is cleared

#### `releaseVectorStore(params: ReleaseParams)`

Release a vector store and free resources.

**Parameters:**
- `params`: 
  - `id`: The ID of the store

**Returns:** Promise that resolves when the store is released

### HNSWIndex Methods

#### `createHNSWIndex(options: HNSWIndexOptions)`

Create a new HNSW index.

**Parameters:**
- `options`: 
  - `dimension`: The dimension of the vectors
  - `metric`: The distance metric to use
  - `m` (optional): Maximum number of connections per node (default: 16)
  - `efConstruction` (optional): Size of the dynamic list for candidate selection during construction (default: 200)

**Returns:** Promise with the created index ID

#### `addVectorToIndex(params: AddVectorParams)`

Add a vector to an HNSW index.

**Parameters:**
- `params`: 
  - `id`: The ID of the index
  - `vector`: The vector to add
  - `vectorId`: The ID to associate with the vector

**Returns:** Promise that resolves when the vector is added

#### `searchHNSWIndex(params: HNSWIndexSearchParams)`

Search for nearest neighbors in an HNSW index.

**Parameters:**
- `params`: 
  - `id`: The ID of the index
  - `queryVector`: The query vector
  - `k`: The number of nearest neighbors to return
  - `efSearch` (optional): Size of the dynamic list for candidate selection during search (default: 50)

**Returns:** Promise with search results

#### `getHNSWIndexCount(params: CountParams)`

Get the number of vectors in an HNSW index.

**Parameters:**
- `params`: 
  - `id`: The ID of the index

**Returns:** Promise with the count of vectors

#### `clearHNSWIndex(params: ClearParams)`

Clear all vectors from an HNSW index.

**Parameters:**
- `params`: 
  - `id`: The ID of the index

**Returns:** Promise that resolves when the index is cleared

#### `releaseHNSWIndex(params: ReleaseParams)`

Release an HNSW index and free resources.

**Parameters:**
- `params`: 
  - `id`: The ID of the index

**Returns:** Promise that resolves when the index is released

## Building the Plugin

To build the plugin from source, use the provided build script:

```bash
# Navigate to the project root
cd /path/to/llama_mobile_vd

# Run the build script
bash scripts/build-capacitor-plugin.sh
```

The script will:
1. Build the iOS framework using `build-ios.sh`
2. Build the Android libraries using `build-android.sh`
3. Copy the necessary files to the Capacitor plugin directory
4. Verify the build results

### Force Rebuild

To force a rebuild of all dependencies:

```bash
bash scripts/build-capacitor-plugin.sh --force
```

## Troubleshooting

### iOS Issues

- **Framework not found**: Make sure the framework is properly copied to the plugin directory
- **Swift version mismatch**: Ensure your Xcode project is using the correct Swift version

### Android Issues

- **JNI library not found**: Check that the JNI libraries are properly copied to the `jniLibs` directory
- **Permission issues**: Ensure your app has the necessary permissions

## License

Apache-2.0

## Contributing

Contributions are welcome! Please see the CONTRIBUTING.md file for more information.
