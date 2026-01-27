# Llama Mobile Vector Database SDK API Documentation

This document provides a comprehensive overview of the Llama Mobile Vector Database SDK API for React Native.

## Table of Contents

1. [Installation](#installation)
2. [Initialization](#initialization)
3. [Version Information](#version-information)
4. [VectorStore API](#vectorstore-api)
5. [HNSWIndex API](#hnswindex-api)
6. [MMapVectorStore API](#mmapvectorstore-api)
7. [Error Handling](#error-handling)
8. [Example Usage](#example-usage)

## Installation

To install the SDK in your React Native project:

```bash
# Using npm
npm install --save path/to/llama_mobile_vd-ReactNative-SDK

# Using yarn
yarn add file:path/to/llama_mobile_vd-ReactNative-SDK
```

## Initialization

Import the SDK in your React Native code:

```javascript
import LlamaMobileVD from 'llama_mobile_vd-ReactNative-SDK';
```

## Version Information

The SDK provides methods to get version information:

### `getVersion()`
Returns the full version string of the SDK.

**Returns:** `Promise<string>` - Version string (e.g., "1.0.0")

### `getVersionMajor()`
Returns the major version number.

**Returns:** `Promise<number>` - Major version number

### `getVersionMinor()`
Returns the minor version number.

**Returns:** `Promise<number>` - Minor version number

### `getVersionPatch()`
Returns the patch version number.

**Returns:** `Promise<number>` - Patch version number

## VectorStore API

The `VectorStore` is a simple in-memory vector storage and search implementation.

### `vectorStoreCreate(dimension, metric)`
Creates a new VectorStore with the specified dimension and distance metric.

**Parameters:**
- `dimension` (number): The dimensionality of the vectors
- `metric` (number): The distance metric to use (0 for L2, 1 for Cosine)

**Returns:** `Promise<number>` - ID of the created VectorStore

### `vectorStoreAddVector(storeId, id, vector)`
Adds a vector to the VectorStore.

**Parameters:**
- `storeId` (number): ID of the VectorStore
- `id` (number): Unique ID for the vector
- `vector` (Array<number>): The vector to add

**Returns:** `Promise<boolean>` - Success status

### `vectorStoreSearch(storeId, queryVector, k)`
Searches for the k nearest neighbors to the query vector.

**Parameters:**
- `storeId` (number): ID of the VectorStore
- `queryVector` (Array<number>): The query vector
- `k` (number): Number of nearest neighbors to return

**Returns:** `Promise<Array<{id: number, distance: number}>>` - Array of search results

### `vectorStoreGetSize(storeId)`
Gets the number of vectors in the VectorStore.

**Parameters:**
- `storeId` (number): ID of the VectorStore

**Returns:** `Promise<number>` - Number of vectors

### `vectorStoreClear(storeId)`
Clears all vectors from the VectorStore.

**Parameters:**
- `storeId` (number): ID of the VectorStore

**Returns:** `Promise<boolean>` - Success status

### `vectorStoreDestroy(storeId)`
Destroys the VectorStore and frees resources.

**Parameters:**
- `storeId` (number): ID of the VectorStore

**Returns:** `Promise<boolean>` - Success status

## HNSWIndex API

The `HNSWIndex` is a high-performance approximate nearest neighbor search index based on the Hierarchical Navigable Small World graph algorithm.

### `hnswIndexCreateWithParams(dimension, metric, maxElements, M, efConstruction, seed)`
Creates a new HNSWIndex with the specified parameters.

**Parameters:**
- `dimension` (number): The dimensionality of the vectors
- `metric` (number): The distance metric to use (0 for L2, 1 for Cosine)
- `maxElements` (number): Maximum number of elements the index can hold
- `M` (number): Number of connections per node in the graph
- `efConstruction` (number): Search budget during index construction
- `seed` (number): Random seed for index construction

**Returns:** `Promise<number>` - ID of the created HNSWIndex

### `hnswIndexAddVector(indexId, id, vector)`
Adds a vector to the HNSWIndex.

**Parameters:**
- `indexId` (number): ID of the HNSWIndex
- `id` (number): Unique ID for the vector
- `vector` (Array<number>): The vector to add

**Returns:** `Promise<boolean>` - Success status

### `hnswIndexSearch(indexId, queryVector, k)`
Searches for the k nearest neighbors to the query vector.

**Parameters:**
- `indexId` (number): ID of the HNSWIndex
- `queryVector` (Array<number>): The query vector
- `k` (number): Number of nearest neighbors to return

**Returns:** `Promise<Array<{id: number, distance: number}>>` - Array of search results

### `hnswIndexSetEfSearch(indexId, efSearch)`
Sets the search budget for the HNSWIndex.

**Parameters:**
- `indexId` (number): ID of the HNSWIndex
- `efSearch` (number): Search budget (higher values improve accuracy but slow down search)

**Returns:** `Promise<boolean>` - Success status

### `hnswIndexGetSize(indexId)`
Gets the number of vectors in the HNSWIndex.

**Parameters:**
- `indexId` (number): ID of the HNSWIndex

**Returns:** `Promise<number>` - Number of vectors

### `hnswIndexDestroy(indexId)`
Destroys the HNSWIndex and frees resources.

**Parameters:**
- `indexId` (number): ID of the HNSWIndex

**Returns:** `Promise<boolean>` - Success status

## MMapVectorStore API

The `MMapVectorStore` is a memory-mapped vector storage implementation that allows for efficient loading and searching of large vector datasets.

### `mmapVectorStoreBuilderCreate(dimension, metric)`
Creates a new MMapVectorStoreBuilder for building memory-mapped vector stores.

**Parameters:**
- `dimension` (number): The dimensionality of the vectors
- `metric` (number): The distance metric to use (0 for L2, 1 for Cosine)

**Returns:** `Promise<number>` - ID of the created MMapVectorStoreBuilder

### `mmapVectorStoreBuilderAddVector(builderId, id, vector)`
Adds a vector to the MMapVectorStoreBuilder.

**Parameters:**
- `builderId` (number): ID of the MMapVectorStoreBuilder
- `id` (number): Unique ID for the vector
- `vector` (Array<number>): The vector to add

**Returns:** `Promise<boolean>` - Success status

### `mmapVectorStoreBuilderSave(builderId, filename)`
Saves the MMapVectorStoreBuilder to a file.

**Parameters:**
- `builderId` (number): ID of the MMapVectorStoreBuilder
- `filename` (string): Path to save the vector store to

**Returns:** `Promise<boolean>` - Success status

### `mmapVectorStoreBuilderDestroy(builderId)`
Destroys the MMapVectorStoreBuilder and frees resources.

**Parameters:**
- `builderId` (number): ID of the MMapVectorStoreBuilder

**Returns:** `Promise<boolean>` - Success status

### `mmapVectorStoreOpen(filename)`
Opens an existing memory-mapped vector store.

**Parameters:**
- `filename` (string): Path to the vector store file

**Returns:** `Promise<number>` - ID of the opened MMapVectorStore

### `mmapVectorStoreSearch(storeId, queryVector, k)`
Searches for the k nearest neighbors to the query vector in the MMapVectorStore.

**Parameters:**
- `storeId` (number): ID of the MMapVectorStore
- `queryVector` (Array<number>): The query vector
- `k` (number): Number of nearest neighbors to return

**Returns:** `Promise<Array<{id: number, distance: number}>>` - Array of search results

### `mmapVectorStoreGetSize(storeId)`
Gets the number of vectors in the MMapVectorStore.

**Parameters:**
- `storeId` (number): ID of the MMapVectorStore

**Returns:** `Promise<number>` - Number of vectors

### `mmapVectorStoreClose(storeId)`
Closes the MMapVectorStore and frees resources.

**Parameters:**
- `storeId` (number): ID of the MMapVectorStore

**Returns:** `Promise<boolean>` - Success status

## Error Handling

All SDK methods return promises that can be caught for error handling:

```javascript
try {
  const storeId = await LlamaMobileVD.vectorStoreCreate(128, 0);
  // Use storeId...
} catch (error) {
  console.error('Error creating VectorStore:', error);
}
```

## Example Usage

### Basic VectorStore Example

```javascript
import LlamaMobileVD from 'llama_mobile_vd-ReactNative-SDK';

async function vectorStoreExample() {
  // Create a VectorStore for 128-dimensional vectors using L2 distance
  const storeId = await LlamaMobileVD.vectorStoreCreate(128, 0);
  
  // Add some vectors
  for (let i = 0; i < 100; i++) {
    const vector = Array(128).fill(Math.random() * 2 - 1);
    await LlamaMobileVD.vectorStoreAddVector(storeId, i + 1, vector);
  }
  
  // Get the size of the store
  const size = await LlamaMobileVD.vectorStoreGetSize(storeId);
  console.log(`VectorStore size: ${size}`);
  
  // Search for similar vectors
  const queryVector = Array(128).fill(Math.random() * 2 - 1);
  const results = await LlamaMobileVD.vectorStoreSearch(storeId, queryVector, 5);
  console.log('Search results:', results);
  
  // Clean up
  await LlamaMobileVD.vectorStoreClear(storeId);
  await LlamaMobileVD.vectorStoreDestroy(storeId);
}
```

### HNSWIndex Example

```javascript
import LlamaMobileVD from 'llama_mobile_vd-ReactNative-SDK';

async function hnswIndexExample() {
  // Create an HNSWIndex with custom parameters
  const indexId = await LlamaMobileVD.hnswIndexCreateWithParams(
    128,  // dimension
    0,    // metric (L2)
    1000, // maxElements
    16,   // M
    200,  // efConstruction
    42    // seed
  );
  
  // Add some vectors
  for (let i = 0; i < 500; i++) {
    const vector = Array(128).fill(Math.random() * 2 - 1);
    await LlamaMobileVD.hnswIndexAddVector(indexId, i + 1, vector);
  }
  
  // Set search parameters
  await LlamaMobileVD.hnswIndexSetEfSearch(indexId, 100);
  
  // Search
  const queryVector = Array(128).fill(Math.random() * 2 - 1);
  const results = await LlamaMobileVD.hnswIndexSearch(indexId, queryVector, 5);
  console.log('HNSW search results:', results);
  
  // Clean up
  await LlamaMobileVD.hnswIndexDestroy(indexId);
}
```

### MMapVectorStore Example

```javascript
import LlamaMobileVD from 'llama_mobile_vd-ReactNative-SDK';
import { DocumentDirectoryPath } from 'react-native-fs';

async function mmapVectorStoreExample() {
  // Create a builder
  const builderId = await LlamaMobileVD.mmapVectorStoreBuilderCreate(128, 0);
  
  // Add some vectors
  for (let i = 0; i < 1000; i++) {
    const vector = Array(128).fill(Math.random() * 2 - 1);
    await LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, i + 1, vector);
  }
  
  // Save to file
  const filename = `${DocumentDirectoryPath}/vector_store.mmap`;
  await LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, filename);
  await LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId);
  
  // Open and search
  const storeId = await LlamaMobileVD.mmapVectorStoreOpen(filename);
  const queryVector = Array(128).fill(Math.random() * 2 - 1);
  const results = await LlamaMobileVD.mmapVectorStoreSearch(storeId, queryVector, 5);
  console.log('MMapVectorStore search results:', results);
  
  // Clean up
  await LlamaMobileVD.mmapVectorStoreClose(storeId);
}
```
