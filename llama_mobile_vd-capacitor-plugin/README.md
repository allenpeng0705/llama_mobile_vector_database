# LlamaMobileVD Capacitor Plugin

High-performance vector storage and similarity search for Capacitor mobile applications. This plugin provides native iOS and Android implementations for efficient vector operations using the Llama Mobile Vector Database SDK.

## Features

- **Vector Storage**: Store and manage high-dimensional vectors efficiently
- **Similarity Search**: Fast nearest neighbor search with multiple distance metrics (L2, Cosine, Dot Product)
- **HNSW Index**: Approximate nearest neighbor search using Hierarchical Navigable Small World graphs
- **Memory-Mapped Storage**: Memory-mapped vector stores for large datasets
- **Cross-Platform**: Native implementations for both iOS and Android
- **Type-Safe**: Full TypeScript support with comprehensive type definitions

## Installation

### From NPM (Published Version)

```bash
npm install llama-mobile-vd-capacitor-plugin
npx cap sync
```

### Local Development (For Contributors)

To use the plugin locally during development:

1. **Clone the Repository**

```bash
git clone https://github.com/your-org/llama_mobile_vector_database.git
cd llama_mobile_vector_database
```

2. **Install Dependencies**

```bash
cd llama_mobile_vd-capacitor-plugin
npm install
```

3. **Link the Plugin to Your Test App**

```bash
# In your test app directory
npm link /path/to/llama_mobile_vector_database/llama_mobile_vd-capacitor-plugin
npx cap sync
```

4. **iOS Specific Setup**

```bash
# In your test app directory
npx cap open ios
# Build and run from Xcode
```

5. **Android Specific Setup**

```bash
# In your test app directory
npx cap open android
# Build and run from Android Studio
```

6. **Testing Changes**

After making changes to the plugin:

```bash
# In the plugin directory
npm run build

# In your test app directory
npx cap sync
# Re-run the app
```

## iOS Setup

The plugin includes the iOS framework automatically. No additional setup is required.

## Android Setup

The plugin includes the Android native libraries automatically. No additional setup is required.

## Usage

### Import the Plugin

```typescript
import { LlamaMobileVD } from 'llama-mobile-vd-capacitor-plugin';
```

### Get Version

```typescript
const { version } = await LlamaMobileVD.getVersion();
console.log('LlamaMobileVD version:', version);
```

### Create a Vector Store

```typescript
const { storeId } = await LlamaMobileVD.createVectorStore({
  dimension: 128,
  metric: 'cosine'
});
```

### Add Vectors

```typescript
// Add vectors without IDs (auto-generated)
await LlamaMobileVD.addVectors({
  storeId,
  vectors: [
    [1.0, 2.0, 3.0, 4.0],
    [5.0, 6.0, 7.0, 8.0]
  ]
});

// Add vectors with custom IDs
await LlamaMobileVD.addVectors({
  storeId,
  vectors: [
    [1.0, 2.0, 3.0, 4.0],
    [5.0, 6.0, 7.0, 8.0]
  ],
  ids: [100, 200]
});
```

### Search for Similar Vectors

```typescript
const { ids, distances } = await LlamaMobileVD.search({
  storeId,
  queryVector: [1.0, 2.0, 3.0, 4.0],
  k: 5
});

console.log('Similar vectors:', ids);
console.log('Distances:', distances);
```

### Get a Vector by ID

```typescript
const { vector } = await LlamaMobileVD.getVector({
  storeId,
  id: 100
});
```

### Remove Vectors

```typescript
await LlamaMobileVD.removeVectors({
  storeId,
  ids: [100, 200]
});
```

### Get Vector Count

```typescript
const { count } = await LlamaMobileVD.getVectorCount({
  storeId
});
```

### Clear All Vectors

```typescript
await LlamaMobileVD.clearVectors({
  storeId
});
```

### Destroy Vector Store

```typescript
await LlamaMobileVD.destroyVectorStore({
  storeId
});
```

## HNSW Index

For faster approximate nearest neighbor search with large datasets:

### Create HNSW Index

```typescript
const { indexId } = await LlamaMobileVD.createHNSWIndex({
  storeId,
  m: 16,              // Number of bi-directional links for each node
  efConstruction: 200    // Size of dynamic candidate list during construction
});
```

### Search with HNSW Index

```typescript
// Search with default efSearch
const { ids, distances } = await LlamaMobileVD.searchHNSW({
  indexId,
  queryVector: [1.0, 2.0, 3.0, 4.0],
  k: 5
});

// Search with custom efSearch for better accuracy
const { ids, distances } = await LlamaMobileVD.searchHNSW({
  indexId,
  queryVector: [1.0, 2.0, 3.0, 4.0],
  k: 5,
  efSearch: 100
});
```

### Add Vectors to HNSW Index

```typescript
await LlamaMobileVD.addVectorsToHNSW({
  indexId,
  vectors: [
    [1.0, 2.0, 3.0, 4.0],
    [5.0, 6.0, 7.0, 8.0]
  ],
  ids: [100, 200]
});
```

### Destroy HNSW Index

```typescript
await LlamaMobileVD.destroyHNSWIndex({
  indexId
});
```

## Memory-Mapped Vector Store

For large datasets that need to be persisted to disk:

### Create MMap Vector Store Builder

```typescript
const { builderId } = await LlamaMobileVD.createMMapVectorStoreBuilder({
  dimension: 128,
  metric: 'cosine'
});
```

### Add Vectors to Builder

```typescript
await LlamaMobileVD.addVectorsToMMapBuilder({
  builderId,
  vectors: [
    [1.0, 2.0, 3.0, 4.0],
    [5.0, 6.0, 7.0, 8.0]
  ],
  ids: [100, 200]
});
```

### Build MMap Vector Store

```typescript
await LlamaMobileVD.buildMMapVectorStore({
  builderId,
  path: '/path/to/vectorstore.mmap'
});
```

### Open MMap Vector Store

```typescript
const { storeId } = await LlamaMobileVD.openMMapVectorStore({
  path: '/path/to/vectorstore.mmap'
});
```

### Close MMap Vector Store

```typescript
await LlamaMobileVD.closeMMapVectorStore({
  storeId
});
```

### MMap Vector Store Complete Example

```typescript
import { LlamaMobileVD } from 'llama-mobile-vd-capacitor-plugin';

async function mmapVectorStoreExample() {
  // Create builder
  const { builderId } = await LlamaMobileVD.createMMapVectorStoreBuilder({
    dimension: 128,
    metric: 'cosine'
  });

  // Add vectors
  const vectors = [];
  for (let i = 0; i < 1000; i++) {
    vectors.push(Array.from({ length: 128 }, () => Math.random()));
  }

  await LlamaMobileVD.addVectorsToMMapBuilder({
    builderId,
    vectors
  });

  // Build and save
  const mmapPath = '/path/to/vectorstore.mmap';
  await LlamaMobileVD.buildMMapVectorStore({
    builderId,
    path: mmapPath
  });

  // Clean up builder
  await LlamaMobileVD.destroyMMapVectorStoreBuilder({
    builderId
  });

  // Later, open the saved vector store
  const { storeId } = await LlamaMobileVD.openMMapVectorStore({
    path: mmapPath
  });

  // Search
  const queryVector = Array.from({ length: 128 }, () => Math.random());
  const { ids, distances } = await LlamaMobileVD.search({
    storeId,
    queryVector,
    k: 5
  });

  console.log('MMap search results:', ids);

  // Clean up
  await LlamaMobileVD.closeMMapVectorStore({
    storeId
  });
}

mmapVectorStoreExample();
```

## Distance Metrics

The plugin supports three distance metrics:

- **`l2`**: Euclidean distance (L2 norm)
- **`cosine`**: Cosine similarity (recommended for normalized vectors)
- **`dot`**: Dot product (for normalized vectors, equivalent to cosine similarity)

## API Reference

### Methods

| Method | Description |
|--------|-------------|
| `getVersion()` | Get the plugin version |
| `createVectorStore(options)` | Create a new vector store |
| `destroyVectorStore(options)` | Destroy a vector store |
| `addVectors(options)` | Add vectors to a store |
| `getVector(options)` | Get a vector by ID |
| `search(options)` | Search for similar vectors |
| `removeVectors(options)` | Remove vectors by IDs |
| `getVectorCount(options)` | Get the number of vectors in a store |
| `clearVectors(options)` | Clear all vectors from a store |
| `createHNSWIndex(options)` | Create an HNSW index |
| `destroyHNSWIndex(options)` | Destroy an HNSW index |
| `searchHNSW(options)` | Search using HNSW index |
| `addVectorsToHNSW(options)` | Add vectors to HNSW index |
| `createMMapVectorStoreBuilder(options)` | Create MMap vector store builder |
| `destroyMMapVectorStoreBuilder(options)` | Destroy MMap builder |
| `addVectorsToMMapBuilder(options)` | Add vectors to MMap builder |
| `buildMMapVectorStore(options)` | Build MMap vector store |
| `openMMapVectorStore(options)` | Open MMap vector store |
| `closeMMapVectorStore(options)` | Close MMap vector store |

## Example: Complete Workflow

```typescript
import { LlamaMobileVD } from 'llama-mobile-vd-capacitor-plugin';

async function exampleUsage() {
  // Get version
  const { version } = await LlamaMobileVD.getVersion();
  console.log('Plugin version:', version);

  // Create vector store
  const { storeId } = await LlamaMobileVD.createVectorStore({
    dimension: 128,
    metric: 'cosine'
  });

  // Add some vectors
  const vectors = [];
  for (let i = 0; i < 100; i++) {
    const vector = Array.from({ length: 128 }, () => Math.random());
    vectors.push(vector);
  }

  await LlamaMobileVD.addVectors({
    storeId,
    vectors
  });

  // Search for similar vectors
  const queryVector = Array.from({ length: 128 }, () => Math.random());
  const { ids, distances } = await LlamaMobileVD.search({
    storeId,
    queryVector,
    k: 10
  });

  console.log('Top 10 similar vectors:', ids);
  console.log('Distances:', distances);

  // Get vector count
  const { count } = await LlamaMobileVD.getVectorCount({ storeId });
  console.log('Total vectors:', count);

  // Clean up
  await LlamaMobileVD.destroyVectorStore({ storeId });
}

exampleUsage();
```

## Performance Tips

1. **Choose the right metric**: Use `cosine` for normalized vectors, `l2` for general use
2. **Batch operations**: Add multiple vectors at once for better performance
3. **Use HNSW for large datasets**: HNSW provides faster search for datasets with >10k vectors
4. **Tune HNSW parameters**:
   - Higher `m` values improve recall but increase memory usage
   - Higher `efConstruction` values improve index quality but take longer to build
   - Higher `efSearch` values improve search accuracy but are slower
5. **Use MMap for large datasets**: Memory-mapped stores allow efficient access to large datasets

## Local Development Tips

### For Plugin Developers

1. **Use npm link**: Develop the plugin locally and link it to your test app
2. **Watch mode**: Use `npm run watch` in the plugin directory for automatic rebuilds
3. **Debugging**:
   - iOS: Use Xcode's debugger
   - Android: Use Android Studio's debugger
4. **Test thoroughly**: Test on both iOS and Android to ensure cross-platform compatibility
5. **Follow Capacitor conventions**: Keep the plugin structure consistent with Capacitor best practices

### For App Developers Using Local Plugin

1. **Path considerations**:
   - iOS: Use relative paths or documents directory
   - Android: Use app-specific storage paths
2. **Version management**: Keep track of plugin versions when using local development
3. **Sync frequently**: Run `npx cap sync` after making changes to the plugin
4. **Backup your work**: Local development can be unstable, so backup important data

## Troubleshooting

### Common Issues

1. **Plugin not found**:
   - Ensure the plugin is installed: `npm install`
   - Run `npx cap sync` to update native projects

2. **Search returns empty results**:
   - Ensure vectors have been added to the store
   - Verify the query vector has the correct dimension
   - Check that the store is properly initialized

3. **MMapVectorStore errors**:
   - Ensure the path is writable
   - Check that you have storage permissions
   - Verify the file path format for your platform

4. **Android-specific issues**:
   - Ensure minSdkVersion is at least 24
   - Check for native library compatibility
   - Verify storage permissions in manifest

5. **iOS-specific issues**:
   - Ensure deployment target is at least iOS 14.0
   - Check for framework signing issues
   - Verify file access permissions

### Debugging Tips

1. **Enable verbose logging**:
   ```typescript
   // Add this before using the plugin
   console.log('LlamaMobileVD debug mode enabled');
   ```

2. **Check plugin version**:
   ```typescript
   const { version } = await LlamaMobileVD.getVersion();
   console.log('Plugin version:', version);
   ```

3. **Validate input parameters**:
   - Check vector dimensions match store configuration
   - Verify metric is one of: 'l2', 'cosine', 'dot'
   - Ensure paths are valid for the target platform

## Platform Support

- **iOS**: 14.0+
- **Android**: API 24+ (Android 7.0+)

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please use the [GitHub Issues](https://github.com/your-org/llama_mobile_vector_database/issues) page.
