# LlamaMobileVD Android Kotlin SDK

A high-performance vector database SDK for Android applications, built on top of the LlamaMobileVD native library. This SDK provides embeddable vector database capabilities for Android apps, running natively with SIMD acceleration.

## Features

- **Native Kotlin API**: Clean, intuitive Kotlin interface for vector storage and search
- **High performance**: Built on a C++ core with ARM NEON acceleration
- **Multiple distance metrics**: Support for L2 (Euclidean), Cosine, and Dot Product distances
- **VectorStore**: Exact nearest neighbor search with thread-safe operations
- **HNSWIndex**: Approximate nearest neighbor search with high performance for large datasets
- **MMapVectorStore**: Memory-mapped vector store for large datasets that may exceed RAM capacity
- **MMapVectorStoreBuilder**: Efficiently build memory-mapped vector stores from scratch
- **Auto-managed resources**: Automatic memory management through JNI
- **Multi-dimensional support**: Handles common embedding sizes (384, 768, 1024, 3072 dimensions)
- **Version information**: Access to library version details

## Requirements

- Android 6.0+ (API level 23+)
- Android Studio 2022.2.1+ (Electric Eel+)
- Kotlin 1.8+ or Java 8+
- Gradle 7.4+

## Installation

### Gradle

1. In Android Studio, open your project
2. Add the following to your app's `build.gradle` file:

```groovy
// Add the Kotlin SDK as a module dependency
implementation project(':llama_mobile_vd-android-SDK')
```

3. Import the LlamaMobileVD package in your Kotlin files:

```kotlin
import com.llamamobile.vd.LlamaMobileVD
```

## Usage

### VectorStore Example

```kotlin
// Create a vector store with 512-dimensional vectors and cosine distance metric
val dimension = 512
val storeId = LlamaMobileVD.createVectorStore(dimension, LlamaMobileVD.DistanceMetric.COSINE)

// Add vectors to the store
val vector1 = FloatArray(dimension) { 0.5f }
LlamaMobileVD.nativeVectorStoreAddVector(storeId, 1, vector1)

val vector2 = FloatArray(dimension) { 0.8f }
LlamaMobileVD.nativeVectorStoreAddVector(storeId, 2, vector2)

// Search for nearest neighbors
val queryVector = FloatArray(dimension) { 0.6f }
val results = LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, 2)

// Process the results
for (result in results) {
    println("Vector ID: ${result.id}, Distance: ${result.distance}")
}

// Get vector by ID
val retrievedVector = LlamaMobileVD.nativeVectorStoreGetVector(storeId, 1)
println("Retrieved vector: ${retrievedVector?.take(5)}...")

// Check if vector exists
val exists = LlamaMobileVD.nativeVectorStoreContains(storeId, 1)
println("Vector 1 exists: $exists")

// Remove vector
val removed = LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, 1)
println("Vector 1 removed: $removed")

// Get store information
val size = LlamaMobileVD.nativeVectorStoreGetSize(storeId)
val storeDimension = LlamaMobileVD.nativeVectorStoreGetDimension(storeId)
val metric = LlamaMobileVD.nativeVectorStoreGetMetric(storeId)
println("Store size: $size, Dimension: $storeDimension, Metric: $metric")

// Update vector
val updatedVector = FloatArray(dimension) { 0.9f }
val updated = LlamaMobileVD.nativeVectorStoreUpdateVector(storeId, 2, updatedVector)
println("Vector 2 updated: $updated")

// Reserve capacity
val reserved = LlamaMobileVD.nativeVectorStoreReserve(storeId, 100)
println("Capacity reserved: $reserved")

// Clear all vectors
LlamaMobileVD.nativeVectorStoreClear(storeId)
println("Store cleared, size: ${LlamaMobileVD.nativeVectorStoreGetSize(storeId)}")

// Clean up
LlamaMobileVD.nativeVectorStoreDestroy(storeId)
```

### HNSWIndex Example

```kotlin
// Create an HNSW index with 512-dimensional vectors and cosine distance metric
val dimension = 512
val maxElements = 10000
val indexId = LlamaMobileVD.createHNSWIndex(dimension, LlamaMobileVD.DistanceMetric.COSINE, maxElements)

// Set search parameters
val efSearch = 64
LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch)

// Add vectors to the index
for (i in 0 until 1000) {
    val vector = FloatArray(dimension) { kotlin.random.Random.nextFloat() * 2 - 1 }
    LlamaMobileVD.nativeHNSWIndexAddVector(indexId, i.toLong(), vector)
}

// Search for nearest neighbors
val queryVector = FloatArray(dimension) { kotlin.random.Random.nextFloat() * 2 - 1 }
val results = LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, 10)

// Process the results
for (result in results) {
    println("Vector ID: ${result.id}, Distance: ${result.distance}")
}

// Get index information
val size = LlamaMobileVD.nativeHNSWIndexGetSize(indexId)
val indexDimension = LlamaMobileVD.nativeHNSWIndexGetDimension(indexId)
val capacity = LlamaMobileVD.nativeHNSWIndexGetCapacity(indexId)
val currentEfSearch = LlamaMobileVD.nativeHNSWIndexGetEfSearch(indexId)
println("Index size: $size, Dimension: $indexDimension, Capacity: $capacity, efSearch: $currentEfSearch")

// Save index to file
val file = File(context.filesDir, "my_hnsw_index.bin")
val saved = LlamaMobileVD.nativeHNSWIndexSave(indexId, file.absolutePath)
println("Index saved: $saved")

// Load index from file
val loadedIndexId = LlamaMobileVD.nativeHNSWIndexLoad(file.absolutePath)
println("Index loaded, size: ${LlamaMobileVD.nativeHNSWIndexGetSize(loadedIndexId)}")

// Clean up
LlamaMobileVD.nativeHNSWIndexDestroy(indexId)
LlamaMobileVD.nativeHNSWIndexDestroy(loadedIndexId)
```

### MMapVectorStore Example

```kotlin
// Create a file path for the MMapVectorStore
val file = File(context.filesDir, "my_mmap_store.bin")
val filePath = file.absolutePath
val dimension = 512

// Create MMapVectorStore using builder pattern
val builderId = LlamaMobileVD.createMMapVectorStoreBuilder(dimension, LlamaMobileVD.DistanceMetric.COSINE)

// Reserve capacity
LlamaMobileVD.nativeMMapVectorStoreBuilderReserve(builderId, 1000)

// Add vectors to the builder
for (i in 0 until 100) {
    val vector = FloatArray(dimension) { kotlin.random.Random.nextFloat() * 2 - 1 }
    LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, i.toLong(), vector)
}

// Save builder to create MMapVectorStore
val saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, filePath)
println("Builder saved: $saved")

// Destroy builder
LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId)

// Open the MMapVectorStore
val storeId = LlamaMobileVD.openMMapVectorStore(filePath)

// Search for nearest neighbors
val queryVector = FloatArray(dimension) { kotlin.random.Random.nextFloat() * 2 - 1 }
val results = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, 5)

// Process search results
for (result in results) {
    println("Vector ID: ${result.id}, Distance: ${result.distance}")
}

// Get store information
val size = LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId)
val storeDimension = LlamaMobileVD.nativeMMapVectorStoreGetDimension(storeId)
val metric = LlamaMobileVD.nativeMMapVectorStoreGetMetric(storeId)
println("Store size: $size, Dimension: $storeDimension, Metric: $metric")

// Check if vector exists
val exists = LlamaMobileVD.nativeMMapVectorStoreContains(storeId, 42)
println("Vector 42 exists: $exists")

// Get vector by ID
val retrievedVector = LlamaMobileVD.nativeMMapVectorStoreGetVector(storeId, 42)
if (retrievedVector != null) {
    println("Retrieved vector: ${retrievedVector.take(5)}...")
}

// Close the store
LlamaMobileVD.nativeMMapVectorStoreClose(storeId)
```

### Version Information Example

```kotlin
// Get version information
val version = LlamaMobileVD.version
val versionMajor = LlamaMobileVD.versionMajor
val versionMinor = LlamaMobileVD.versionMinor
val versionPatch = LlamaMobileVD.versionPatch

println("Version: $version")
println("Version Major: $versionMajor")
println("Version Minor: $versionMinor")
println("Version Patch: $versionPatch")
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `L2`: Euclidean distance
- `COSINE`: Cosine distance
- `DOT`: Dot product distance

### SearchResult

Data class representing a result from a vector search:

```kotlin
data class SearchResult(val id: Long, val distance: Float)
```

### LlamaMobileVDException

Exception class for error handling:

```kotlin
class LlamaMobileVDException(message: String, cause: Throwable? = null) : RuntimeException(message, cause)
```

### Native Methods

#### VectorStore Operations

```kotlin
// Create a new vector store
fun nativeVectorStoreCreate(dimension: Int, metric: Int): Long

// Add a vector to the store
fun nativeVectorStoreAddVector(storeId: Long, id: Long, vector: FloatArray)

// Search for nearest neighbors
fun nativeVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Array<SearchResult>

// Get a vector by ID
fun nativeVectorStoreGetVector(storeId: Long, id: Long): FloatArray?

// Remove a vector by ID
fun nativeVectorStoreRemoveVector(storeId: Long, id: Long): Boolean

// Check if a vector exists by ID
fun nativeVectorStoreContains(storeId: Long, id: Long): Boolean

// Get the number of vectors in the store
fun nativeVectorStoreGetSize(storeId: Long): Long

// Get the dimension of vectors in the store
fun nativeVectorStoreGetDimension(storeId: Long): Int

// Get the distance metric used by the store
fun nativeVectorStoreGetMetric(storeId: Long): Int

// Update a vector by ID
fun nativeVectorStoreUpdateVector(storeId: Long, id: Long, vector: FloatArray): Boolean

// Reserve capacity for vectors
fun nativeVectorStoreReserve(storeId: Long, capacity: Long): Boolean

// Clear all vectors from the store
fun nativeVectorStoreClear(storeId: Long)

// Destroy the vector store and free resources
fun nativeVectorStoreDestroy(storeId: Long)
```

#### HNSWIndex Operations

```kotlin
// Create a new HNSW index
fun nativeHNSWIndexCreate(dimension: Int, metric: Int, maxElements: Long): Long

// Create a new HNSW index with custom parameters
fun nativeHNSWIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Long, M: Int, efConstruction: Int, seed: Int): Long

// Add a vector to the index
fun nativeHNSWIndexAddVector(indexId: Long, id: Long, vector: FloatArray): Boolean

// Search for nearest neighbors
fun nativeHNSWIndexSearch(indexId: Long, queryVector: FloatArray, k: Int): Array<SearchResult>

// Set the efSearch parameter for search quality
fun nativeHNSWIndexSetEfSearch(indexId: Long, efSearch: Int): Boolean

// Get the current efSearch parameter
fun nativeHNSWIndexGetEfSearch(indexId: Long): Int

// Get the number of vectors in the index
fun nativeHNSWIndexGetSize(indexId: Long): Long

// Get the dimension of vectors in the index
fun nativeHNSWIndexGetDimension(indexId: Long): Int

// Get the capacity of the index
fun nativeHNSWIndexGetCapacity(indexId: Long): Long

// Check if a vector exists by ID
fun nativeHNSWIndexContains(indexId: Long, id: Long): Boolean

// Get a vector by ID
fun nativeHNSWIndexGetVector(indexId: Long, id: Long): FloatArray?

// Save the index to a file
fun nativeHNSWIndexSave(indexId: Long, filename: String): Boolean

// Load an index from a file
fun nativeHNSWIndexLoad(filename: String): Long

// Destroy the index and free resources
fun nativeHNSWIndexDestroy(indexId: Long)
```

#### MMapVectorStoreBuilder Operations

```kotlin
// Create a new MMapVectorStore builder
fun nativeMMapVectorStoreBuilderCreate(dimension: Int, metric: Int): Long

// Add a vector to the builder
fun nativeMMapVectorStoreBuilderAddVector(builderId: Long, id: Long, vector: FloatArray): Boolean

// Reserve capacity for vectors
fun nativeMMapVectorStoreBuilderReserve(builderId: Long, capacity: Long): Boolean

// Save the builder to create an MMapVectorStore
fun nativeMMapVectorStoreBuilderSave(builderId: Long, filename: String): Boolean

// Get the number of vectors in the builder
fun nativeMMapVectorStoreBuilderGetSize(builderId: Long): Long

// Get the dimension of vectors in the builder
fun nativeMMapVectorStoreBuilderGetDimension(builderId: Long): Int

// Destroy the builder and free resources
fun nativeMMapVectorStoreBuilderDestroy(builderId: Long)
```

#### MMapVectorStore Operations

```kotlin
// Open an existing memory-mapped vector store
fun nativeMMapVectorStoreOpen(filename: String): Long

// Get a vector by ID
fun nativeMMapVectorStoreGetVector(storeId: Long, id: Long): FloatArray?

// Check if a vector exists by ID
fun nativeMMapVectorStoreContains(storeId: Long, id: Long): Boolean

// Search for nearest neighbors
fun nativeMMapVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Array<SearchResult>

// Get the number of vectors in the store
fun nativeMMapVectorStoreGetSize(storeId: Long): Long

// Get the dimension of vectors in the store
fun nativeMMapVectorStoreGetDimension(storeId: Long): Int

// Get the distance metric used by the store
fun nativeMMapVectorStoreGetMetric(storeId: Long): Int

// Close the memory-mapped store and free resources
fun nativeMMapVectorStoreClose(storeId: Long)
```

#### Version Information Methods

```kotlin
// Get the library version string
fun nativeGetVersion(): String

// Get the major version number
fun nativeGetVersionMajor(): Int

// Get the minor version number
fun nativeGetVersionMinor(): Int

// Get the patch version number
fun nativeGetVersionPatch(): Int
```

#### Convenience Methods

```kotlin
// Create a vector store with a DistanceMetric enum
fun createVectorStore(dimension: Int, metric: DistanceMetric): Long

// Create a vector store with default COSINE distance metric
fun createVectorStore(dimension: Int): Long

// Create an HNSW index with a DistanceMetric enum
fun createHNSWIndex(dimension: Int, metric: DistanceMetric, maxElements: Long): Long

// Create an HNSW index with custom parameters
fun createHNSWIndex(dimension: Int, metric: DistanceMetric, maxElements: Long, M: Int, efConstruction: Int, seed: Int = 42): Long

// Create an HNSW index with default COSINE distance metric
fun createHNSWIndex(dimension: Int, maxElements: Long): Long

// Create an MMapVectorStore builder with a DistanceMetric enum
fun createMMapVectorStoreBuilder(dimension: Int, metric: DistanceMetric): Long

// Create an MMapVectorStore builder with default COSINE distance metric
fun createMMapVectorStoreBuilder(dimension: Int): Long

// Open an existing MMapVectorStore
fun openMMapVectorStore(filePath: String): Long

// Get the library version string
val version: String

// Get the major version number
val versionMajor: Int

// Get the minor version number
val versionMinor: Int

// Get the patch version number
val versionPatch: Int
```

## Performance Tips

### Which Vector Store to Choose?

- **VectorStore**: Use for exact nearest neighbor search with small to medium datasets (up to 10,000 vectors)
- **HNSWIndex**: Use for approximate nearest neighbor search with large datasets (10,000 to 1,000,000 vectors)
- **MMapVectorStore**: Use for extremely large datasets that may exceed RAM capacity (hundreds of thousands to millions of vectors)

### HNSWIndex Specific Tips

- HNSWIndex provides approximate nearest neighbor search with logarithmic time complexity
- Search performance is significantly faster than exact search for large datasets
- Memory usage increases with dataset size, but is more efficient than VectorStore for large datasets
- Perfect for applications that need fast search performance for large vector collections
- Adjust the `M` and `efConstruction` parameters to balance memory usage and search quality

### MMapVectorStore Specific Tips

- MMapVectorStore provides zero-copy access to vector data on disk, making it ideal for large datasets
- Loading an MMapVectorStore is instant, regardless of size, as it doesn't need to load all vectors into RAM
- Search performance is slower than in-memory VectorStore and HNSWIndex but more memory-efficient
- Perfect for applications that need to handle large vector datasets efficiently on mobile devices with limited RAM
- Use MMapVectorStoreBuilder for efficient bulk loading of vectors

### General Tips

- For common embedding sizes (384, 768, 1024, 3072), the SDK is optimized for performance
- Use appropriate batch sizes when adding vectors to minimize JNI overhead
- Prefer vector dimensions that are multiples of 16 for optimal SIMD performance
- For HNSWIndex, tune `efSearch` parameter: higher values improve search quality but decrease speed
- For MMapVectorStore, consider the trade-off between disk space and search performance

## Requirements

- Android 6.0+ (API level 23+)
- Android Studio 2022.2.1+ (Electric Eel+)
- Kotlin 1.8+ or Java 8+
- Gradle 7.4+

## Building from Source

To build the Android Kotlin SDK from source:

```bash
cd /path/to/llama_mobile_vector_database
./scripts/build-android-SDK.sh
```

This will build the native libraries and update the Kotlin SDK.

## Running Tests

The Android Kotlin SDK includes both unit tests and instrumented tests:

### Unit Tests

Unit tests run on the JVM and test basic functionality:

```bash
cd /path/to/llama_mobile_vector_database
cd llama_mobile_vd-android-SDK
./gradlew test
```

### Instrumented Tests

Instrumented tests run on an Android device or emulator and test the actual vector database functionality:

```bash
cd /path/to/llama_mobile_vector_database
cd llama_mobile_vd-android-SDK
./gradlew connectedAndroidTest
```

## License

See the LICENSE file for details.