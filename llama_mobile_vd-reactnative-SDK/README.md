# Llama Mobile Vector Database ReactNative SDK

This is the ReactNative SDK for Llama Mobile Vector Database, which provides a ReactNative interface to the underlying C++ vector database implementation.

## SDK Structure

```
llama_mobile_vd-ReactNative-SDK/
├── android/            # Android implementation
├── ios/                # iOS implementation
├── src/                # ReactNative JavaScript code
├── test/               # Test files
├── package.json        # Package configuration
└── README.md           # This file
```

## Installation

### For ReactNative Projects

1. **Install the SDK**

   ```bash
   npm install path/to/llama_mobile_vd-ReactNative-SDK
   ```

2. **Link the SDK**

   For ReactNative 0.60 and above, autolinking should work automatically. For older versions, you may need to link manually:

   ```bash
   react-native link llama_mobile_vd-react-native-sdk
   ```

3. **iOS Setup**

   In your iOS project directory, run:

   ```bash
   pod install
   ```

4. **Android Setup**

   The SDK should be automatically linked. If not, add the following to your `settings.gradle`:

   ```gradle
   include ':llama_mobile_vd'
   project(':llama_mobile_vd').projectDir = new File(rootProject.projectDir, '../node_modules/llama_mobile_vd-ReactNative-SDK/android')
   ```

   And add the dependency to your `app/build.gradle`:

   ```gradle
   dependencies {
     implementation project(':llama_mobile_vd')
   }
   ```

## Usage

### Example

```javascript
import LlamaMobileVD from 'llama_mobile_vd-react-native-sdk';

// Create a VectorStore
const storeId = await LlamaMobileVD.vectorStoreCreate(128, 0); // 0 = L2 distance

// Add a vector
const vector = Array(128).fill(0.5);
await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);

// Search for similar vectors
const queryVector = Array(128).fill(0.5);
const results = await LlamaMobileVD.vectorStoreSearch(storeId, queryVector, 5);
console.log('Search results:', results);

// Clean up
await LlamaMobileVD.vectorStoreDestroy(storeId);
```

### API Reference

#### VectorStore

- `vectorStoreCreate(dimension, metric)` - Create a new VectorStore
- `vectorStoreAddVector(storeId, id, vector)` - Add a vector to the store
- `vectorStoreSearch(storeId, queryVector, k)` - Search for similar vectors
- `vectorStoreGetVector(storeId, id)` - Get a vector by ID
- `vectorStoreRemoveVector(storeId, id)` - Remove a vector by ID
- `vectorStoreContains(storeId, id)` - Check if a vector exists
- `vectorStoreGetSize(storeId)` - Get the number of vectors in the store
- `vectorStoreGetDimension(storeId)` - Get the dimension of the vectors
- `vectorStoreGetMetric(storeId)` - Get the distance metric used
- `vectorStoreUpdateVector(storeId, id, vector)` - Update a vector
- `vectorStoreReserve(storeId, capacity)` - Reserve space for vectors
- `vectorStoreClear(storeId)` - Clear all vectors
- `vectorStoreDestroy(storeId)` - Destroy the store

#### HNSWIndex

- `hnswIndexCreate(dimension, metric, maxElements)` - Create a new HNSWIndex
- `hnswIndexCreateWithParams(dimension, metric, maxElements, M, efConstruction, seed)` - Create with custom parameters
- `hnswIndexAddVector(indexId, id, vector)` - Add a vector to the index
- `hnswIndexSearch(indexId, queryVector, k)` - Search for similar vectors
- `hnswIndexSetEfSearch(indexId, efSearch)` - Set search efficiency parameter
- `hnswIndexGetEfSearch(indexId)` - Get search efficiency parameter
- `hnswIndexGetSize(indexId)` - Get the number of vectors in the index
- `hnswIndexGetDimension(indexId)` - Get the dimension of the vectors
- `hnswIndexGetCapacity(indexId)` - Get the capacity of the index
- `hnswIndexContains(indexId, id)` - Check if a vector exists
- `hnswIndexGetVector(indexId, id)` - Get a vector by ID
- `hnswIndexSave(indexId, filename)` - Save the index to a file
- `hnswIndexLoad(filename)` - Load an index from a file
- `hnswIndexDestroy(indexId)` - Destroy the index

#### MMapVectorStore

- `mmapVectorStoreBuilderCreate(dimension, metric)` - Create a builder for MMapVectorStore
- `mmapVectorStoreBuilderAddVector(builderId, id, vector)` - Add a vector to the builder
- `mmapVectorStoreBuilderReserve(builderId, capacity)` - Reserve space for vectors
- `mmapVectorStoreBuilderSave(builderId, filename)` - Save the builder to a file
- `mmapVectorStoreBuilderGetSize(builderId)` - Get the number of vectors in the builder
- `mmapVectorStoreBuilderGetDimension(builderId)` - Get the dimension of the vectors
- `mmapVectorStoreBuilderDestroy(builderId)` - Destroy the builder
- `mmapVectorStoreOpen(filename)` - Open an MMapVectorStore from a file
- `mmapVectorStoreGetVector(storeId, id)` - Get a vector by ID
- `mmapVectorStoreContains(storeId, id)` - Check if a vector exists
- `mmapVectorStoreSearch(storeId, queryVector, k)` - Search for similar vectors
- `mmapVectorStoreGetSize(storeId)` - Get the number of vectors in the store
- `mmapVectorStoreGetDimension(storeId)` - Get the dimension of the vectors
- `mmapVectorStoreGetMetric(storeId)` - Get the distance metric used
- `mmapVectorStoreClose(storeId)` - Close the store

## Distance Metrics

- `0` - L2 distance (Euclidean)
- `1` - Cosine distance
- `2` - Inner product

## Running Tests

```bash
cd path/to/llama_mobile_vd-ReactNative-SDK
npm test
```

## Building the SDK

To build the SDK from source, run:

```bash
./scripts/build-ReactNative-SDK.sh
```
