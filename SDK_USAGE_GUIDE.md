# Llama Mobile Vector Database SDK Usage Guide

This guide provides comprehensive instructions on how to use the Llama Mobile Vector Database SDK in your React Native projects.

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [VectorStore Operations](#vectorstore-operations)
- [HNSWIndex Operations](#hnswindex-operations)
- [MMapVectorStore Operations](#mmapvectorstore-operations)
- [Running the Example App](#running-the-example-app)
- [Testing the SDK](#testing-the-sdk)
- [Troubleshooting](#troubleshooting)

## Installation

### Step 1: Add the SDK to Your Project

```bash
# Using npm
npm install path/to/llama_mobile_vd-reactnative-SDK

# Using yarn
yarn add file:path/to/llama_mobile_vd-reactnative-SDK
```

### Step 2: Link the SDK

For React Native 0.60 and above, autolinking should work automatically. For older versions, you may need to link manually:

```bash
react-native link llama_mobile_vd-reactnative-sdk
```

### Step 3: Platform-Specific Setup

#### iOS

```bash
cd ios && pod install && cd ..
```

#### Android

No additional setup is required for Android.

## Basic Usage

### Import the SDK

```javascript
import LlamaMobileVD from 'llama_mobile_vd-react-native-sdk';
```

### Get Version Information

```javascript
const version = await LlamaMobileVD.getVersion();
const major = await LlamaMobileVD.getVersionMajor();
const minor = await LlamaMobileVD.getVersionMinor();
const patch = await LlamaMobileVD.getVersionPatch();

console.log(`SDK Version: ${version}`);
```

## VectorStore Operations

### Create a VectorStore

```javascript
const dimension = 16;
const metric = 0; // 0 = L2, 1 = Cosine, 2 = Inner Product

const storeId = await LlamaMobileVD.vectorStoreCreate(dimension, metric);
console.log(`VectorStore created with ID: ${storeId}`);
```

### Add Vectors

```javascript
for (let i = 0; i < 10; i++) {
  const vector = Array(dimension).fill(Math.random() * 2 - 1);
  await LlamaMobileVD.vectorStoreAddVector(storeId, i + 1, vector);
}
console.log('Added 10 vectors');
```

### Search Vectors

```javascript
const queryVector = Array(dimension).fill(Math.random() * 2 - 1);
const k = 5;

const results = await LlamaMobileVD.vectorStoreSearch(storeId, queryVector, k);
console.log('Search results:', results);
```

### Get Vector

```javascript
const vectorId = 1;
const vector = await LlamaMobileVD.vectorStoreGetVector(storeId, vectorId);
console.log(`Vector with ID ${vectorId}:`, vector);
```

### Remove Vector

```javascript
const vectorId = 1;
await LlamaMobileVD.vectorStoreRemoveVector(storeId, vectorId);
console.log(`Removed vector with ID ${vectorId}`);
```

### Clear VectorStore

```javascript
await LlamaMobileVD.vectorStoreClear(storeId);
console.log('VectorStore cleared');
```

### Destroy VectorStore

```javascript
await LlamaMobileVD.vectorStoreDestroy(storeId);
console.log('VectorStore destroyed');
```

## HNSWIndex Operations

### Create HNSWIndex

```javascript
const dimension = 16;
const metric = 0; // 0 = L2, 1 = Cosine, 2 = Inner Product
const maxElements = 1000;
const M = 16;
const efConstruction = 200;
const seed = 42;

const indexId = await LlamaMobileVD.hnswIndexCreateWithParams(
  dimension, metric, maxElements, M, efConstruction, seed
);
console.log(`HNSWIndex created with ID: ${indexId}`);
```

### Add Vectors

```javascript
for (let i = 0; i < 10; i++) {
  const vector = Array(dimension).fill(Math.random() * 2 - 1);
  await LlamaMobileVD.hnswIndexAddVector(indexId, i + 1, vector);
}
console.log('Added 10 vectors');
```

### Search Vectors

```javascript
const queryVector = Array(dimension).fill(Math.random() * 2 - 1);
const k = 5;
const efSearch = 50;

await LlamaMobileVD.hnswIndexSetEfSearch(indexId, efSearch);
const results = await LlamaMobileVD.hnswIndexSearch(indexId, queryVector, k);
console.log('Search results:', results);
```

### Save and Load HNSWIndex

```javascript
const filename = '/tmp/test_hnsw_index';

// Save
await LlamaMobileVD.hnswIndexSave(indexId, filename);
console.log('HNSWIndex saved to', filename);

// Load
const loadedIndexId = await LlamaMobileVD.hnswIndexLoad(filename);
console.log('HNSWIndex loaded with ID:', loadedIndexId);
```

### Destroy HNSWIndex

```javascript
await LlamaMobileVD.hnswIndexDestroy(indexId);
console.log('HNSWIndex destroyed');
```

## MMapVectorStore Operations

### Create MMapVectorStore

```javascript
const dimension = 16;
const metric = 0; // 0 = L2, 1 = Cosine, 2 = Inner Product
const filename = '/tmp/test_mmap_vector_store';

// Create builder
const builderId = await LlamaMobileVD.mmapVectorStoreBuilderCreate(dimension, metric);

// Add vectors
for (let i = 0; i < 10; i++) {
  const vector = Array(dimension).fill(Math.random() * 2 - 1);
  await LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, i + 1, vector);
}

// Save to file
await LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, filename);

// Destroy builder
await LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId);

console.log('MMapVectorStore created at', filename);
```

### Open MMapVectorStore

```javascript
const storeId = await LlamaMobileVD.mmapVectorStoreOpen(filename);
console.log(`MMapVectorStore opened with ID: ${storeId}`);
```

### Search MMapVectorStore

```javascript
const queryVector = Array(dimension).fill(Math.random() * 2 - 1);
const k = 5;

const results = await LlamaMobileVD.mmapVectorStoreSearch(storeId, queryVector, k);
console.log('Search results:', results);
```

### Close MMapVectorStore

```javascript
await LlamaMobileVD.mmapVectorStoreClose(storeId);
console.log('MMapVectorStore closed');
```

## Running the Example App

### Step 1: Navigate to the Example Directory

```bash
cd examples/reactnativeSDKExample
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Run the App

#### iOS

```bash
npm run ios
```

#### Android

```bash
npm run android
```

### Example App Features

The example app provides a comprehensive UI for testing all SDK functionality:

- **Configuration Section**: Adjust vector dimension, distance metric, and HNSW parameters
- **VectorStore Section**: Create, add vectors, search, clear, and release
- **HNSWIndex Section**: Create, add vectors, search, and release
- **MMapVectorStore Section**: Create, open, search, and close

## Testing the SDK

### Run SDK Tests

```bash
cd llama_mobile_vd-reactnative-SDK
npm test
```

This will execute all 106 tests covering:
- Version methods
- VectorStore operations
- HNSWIndex operations
- MMapVectorStore operations
- MMapVectorStoreBuilder operations

## Troubleshooting

### Common Issues

#### 1. Module Resolution Errors

**Symptom**: `Error: Unable to resolve module`

**Solution**:
- Ensure the SDK is installed correctly: `npm install`
- Check the import statement: `import LlamaMobileVD from 'llama_mobile_vd-react-native-sdk';`
- Verify the package name in `package.json` matches the import path

#### 2. iOS Build Errors

**Symptom**: Build failures when running on iOS

**Solution**:
- Clear CocoaPods cache: `cd ios && pod cache clean --all && rm -rf Pods Podfile.lock && pod install && cd ..`
- Ensure the SDK's podspec is correctly configured
- Check for signing issues in Xcode

#### 3. Android Build Errors

**Symptom**: Build failures when running on Android

**Solution**:
- Clean the Android build: `cd android && ./gradlew clean && cd ..`
- Ensure Android Studio is installed and properly configured
- Check the Android SDK version

#### 4. Runtime Errors

**Symptom**: Errors when calling SDK methods

**Solution**:
- Check that the native modules are properly linked
- Verify that the SDK is compatible with your React Native version
- Ensure you're calling methods with the correct parameters

### Debugging Tips

1. **Enable Debugging**: Use React Native's debugging tools to inspect the app
2. **Check Logs**: Look at the console output for error messages
3. **Test in Isolation**: Create a simple test script to isolate and reproduce issues
4. **Check Documentation**: Refer to this guide and the SDK's README for usage examples

## Support

If you encounter any issues that you can't resolve, please:

1. Check the troubleshooting section above
2. Review the SDK documentation
3. Look at the example app for usage patterns
4. Run the SDK tests to verify basic functionality

With this guide, you should be able to successfully integrate and use the Llama Mobile Vector Database SDK in your React Native projects.
