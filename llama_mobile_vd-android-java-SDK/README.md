# LlamaMobileVD Android Java SDK

A high-performance vector database SDK for Android applications, built on top of the LlamaMobileVD native library. This SDK provides embeddable vector database capabilities for Android apps, running natively with SIMD acceleration.

## Features

- **Native Java API**: Clean, intuitive Java interface for vector storage and search
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
- Java 8+ or Kotlin 1.8+
- Gradle 7.4+

## Installation

### Gradle

1. In Android Studio, open your project
2. Add the following to your app's `build.gradle` file:

```groovy
// Add the Java SDK as a module dependency
implementation project(':llama_mobile_vd-android-java-SDK')
```

3. Import the LlamaMobileVD package in your Java files:

```java
import com.llamamobile.vd.LlamaMobileVD;
```

## Usage

### VectorStore Example

```java
// Create a vector store with 512-dimensional vectors and cosine distance metric
int dimension = 512;
long storeId = LlamaMobileVD.createVectorStore(dimension, LlamaMobileVD.DistanceMetric.COSINE);

// Add vectors to the store
float[] vector1 = new float[dimension];
for (int i = 0; i < dimension; i++) {
    vector1[i] = 0.5f;
}
LlamaMobileVD.nativeVectorStoreAddVector(storeId, 1, vector1);

float[] vector2 = new float[dimension];
for (int i = 0; i < dimension; i++) {
    vector2[i] = 0.8f;
}
LlamaMobileVD.nativeVectorStoreAddVector(storeId, 2, vector2);

// Search for nearest neighbors
float[] queryVector = new float[dimension];
for (int i = 0; i < dimension; i++) {
    queryVector[i] = 0.6f;
}
LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, 2);

// Process the results
for (LlamaMobileVD.SearchResult result : results) {
    System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
}

// Get vector by ID
float[] retrievedVector = LlamaMobileVD.nativeVectorStoreGetVector(storeId, 1);
if (retrievedVector != null) {
    System.out.print("Retrieved vector: [");
    for (int i = 0; i < Math.min(5, retrievedVector.length); i++) {
        System.out.print(retrievedVector[i]);
        if (i < 4) System.out.print(", ");
    }
    System.out.println("]...");
}

// Check if vector exists
boolean exists = LlamaMobileVD.nativeVectorStoreContains(storeId, 1);
System.out.println("Vector 1 exists: " + exists);

// Remove vector
boolean removed = LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, 1);
System.out.println("Vector 1 removed: " + removed);

// Get store information
long size = LlamaMobileVD.nativeVectorStoreGetSize(storeId);
int storeDimension = LlamaMobileVD.nativeVectorStoreGetDimension(storeId);
int metric = LlamaMobileVD.nativeVectorStoreGetMetric(storeId);
System.out.println("Store size: " + size + ", Dimension: " + storeDimension + ", Metric: " + metric);

// Update vector
float[] updatedVector = new float[dimension];
for (int i = 0; i < dimension; i++) {
    updatedVector[i] = 0.9f;
}
boolean updated = LlamaMobileVD.nativeVectorStoreUpdateVector(storeId, 2, updatedVector);
System.out.println("Vector 2 updated: " + updated);

// Reserve capacity
boolean reserved = LlamaMobileVD.nativeVectorStoreReserve(storeId, 100);
System.out.println("Capacity reserved: " + reserved);

// Clear all vectors
LlamaMobileVD.nativeVectorStoreClear(storeId);
System.out.println("Store cleared, size: " + LlamaMobileVD.nativeVectorStoreGetSize(storeId));

// Clean up
LlamaMobileVD.nativeVectorStoreDestroy(storeId);
```

### HNSWIndex Example

```java
// Create an HNSW index with 512-dimensional vectors and cosine distance metric
int dimension = 512;
long maxElements = 10000;
long indexId = LlamaMobileVD.createHNSWIndex(dimension, LlamaMobileVD.DistanceMetric.COSINE, maxElements);

// Set search parameters
int efSearch = 64;
LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch);

// Add vectors to the index
for (int i = 0; i < 1000; i++) {
    float[] vector = new float[dimension];
    for (int j = 0; j < dimension; j++) {
        vector[j] = (float) (Math.random() * 2 - 1);
    }
    LlamaMobileVD.nativeHNSWIndexAddVector(indexId, i, vector);
}

// Search for nearest neighbors
float[] queryVector = new float[dimension];
for (int i = 0; i < dimension; i++) {
    queryVector[i] = (float) (Math.random() * 2 - 1);
}
LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, 10);

// Process the results
for (LlamaMobileVD.SearchResult result : results) {
    System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
}

// Get index information
long size = LlamaMobileVD.nativeHNSWIndexGetSize(indexId);
int indexDimension = LlamaMobileVD.nativeHNSWIndexGetDimension(indexId);
long capacity = LlamaMobileVD.nativeHNSWIndexGetCapacity(indexId);
int currentEfSearch = LlamaMobileVD.nativeHNSWIndexGetEfSearch(indexId);
System.out.println("Index size: " + size + ", Dimension: " + indexDimension + ", Capacity: " + capacity + ", efSearch: " + currentEfSearch);

// Save index to file
File file = new File(context.getFilesDir(), "my_hnsw_index.bin");
boolean saved = LlamaMobileVD.nativeHNSWIndexSave(indexId, file.getAbsolutePath());
System.out.println("Index saved: " + saved);

// Load index from file
long loadedIndexId = LlamaMobileVD.nativeHNSWIndexLoad(file.getAbsolutePath());
System.out.println("Index loaded, size: " + LlamaMobileVD.nativeHNSWIndexGetSize(loadedIndexId));

// Clean up
LlamaMobileVD.nativeHNSWIndexDestroy(indexId);
LlamaMobileVD.nativeHNSWIndexDestroy(loadedIndexId);
```

### MMapVectorStore Example

```java
// Create a file path for the MMapVectorStore
File file = new File(context.getFilesDir(), "my_mmap_store.bin");
String filePath = file.getAbsolutePath();
int dimension = 512;

// Create MMapVectorStore using builder pattern
long builderId = LlamaMobileVD.createMMapVectorStoreBuilder(dimension, LlamaMobileVD.DistanceMetric.COSINE);

// Reserve capacity
LlamaMobileVD.nativeMMapVectorStoreBuilderReserve(builderId, 1000);

// Add vectors to the builder
for (int i = 0; i < 100; i++) {
    float[] vector = new float[dimension];
    for (int j = 0; j < dimension; j++) {
        vector[j] = (float) (Math.random() * 2 - 1);
    }
    LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, i, vector);
}

// Save builder to create MMapVectorStore
boolean saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, filePath);
System.out.println("Builder saved: " + saved);

// Destroy builder
LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId);

// Open the MMapVectorStore
long storeId = LlamaMobileVD.openMMapVectorStore(filePath);

// Search for nearest neighbors
float[] queryVector = new float[dimension];
for (int i = 0; i < dimension; i++) {
    queryVector[i] = (float) (Math.random() * 2 - 1);
}
LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, 5);

// Process search results
for (LlamaMobileVD.SearchResult result : results) {
    System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
}

// Get store information
long size = LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId);
int storeDimension = LlamaMobileVD.nativeMMapVectorStoreGetDimension(storeId);
int metric = LlamaMobileVD.nativeMMapVectorStoreGetMetric(storeId);
System.out.println("Store size: " + size + ", Dimension: " + storeDimension + ", Metric: " + metric);

// Check if vector exists
boolean exists = LlamaMobileVD.nativeMMapVectorStoreContains(storeId, 42);
System.out.println("Vector 42 exists: " + exists);

// Get vector by ID
float[] retrievedVector = LlamaMobileVD.nativeMMapVectorStoreGetVector(storeId, 42);
if (retrievedVector != null) {
    System.out.print("Retrieved vector: [");
    for (int i = 0; i < Math.min(5, retrievedVector.length); i++) {
        System.out.print(retrievedVector[i]);
        if (i < 4) System.out.print(", ");
    }
    System.out.println("]...");
}

// Close the store
LlamaMobileVD.nativeMMapVectorStoreClose(storeId);
```

### Version Information Example

```java
// Get version information
String version = LlamaMobileVD.getVersion();
int versionMajor = LlamaMobileVD.getVersionMajor();
int versionMinor = LlamaMobileVD.getVersionMinor();
int versionPatch = LlamaMobileVD.getVersionPatch();

System.out.println("Version: " + version);
System.out.println("Version Major: " + versionMajor);
System.out.println("Version Minor: " + versionMinor);
System.out.println("Version Patch: " + versionPatch);
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `L2`: Euclidean distance
- `COSINE`: Cosine distance
- `DOT`: Dot product distance

### SearchResult

Class representing a result from a vector search:

```java
public static class SearchResult {
    private final long id;
    private final float distance;
    
    public SearchResult(long id, float distance) {
        this.id = id;
        this.distance = distance;
    }
    
    public long getId() {
        return id;
    }
    
    public float getDistance() {
        return distance;
    }
    
    @Override
    public String toString() {
        return "SearchResult{id=" + id + ", distance=" + distance + "}";
    }
}
```

### LlamaMobileVDException

Exception class for error handling:

```java
public static class LlamaMobileVDException extends RuntimeException {
    public LlamaMobileVDException(String message) {
        super(message);
    }
    
    public LlamaMobileVDException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

### Native Methods

#### VectorStore Operations

```java
// Create a new vector store
public static native long nativeVectorStoreCreate(int dimension, int metric);

// Add a vector to the store
public static native void nativeVectorStoreAddVector(long storeId, long id, float[] vector);

// Search for nearest neighbors
public static native SearchResult[] nativeVectorStoreSearch(long storeId, float[] queryVector, int k);

// Get a vector by ID
public static native float[] nativeVectorStoreGetVector(long storeId, long id);

// Remove a vector by ID
public static native boolean nativeVectorStoreRemoveVector(long storeId, long id);

// Check if a vector exists by ID
public static native boolean nativeVectorStoreContains(long storeId, long id);

// Get the number of vectors in the store
public static native long nativeVectorStoreGetSize(long storeId);

// Get the dimension of vectors in the store
public static native int nativeVectorStoreGetDimension(long storeId);

// Get the distance metric used by the store
public static native int nativeVectorStoreGetMetric(long storeId);

// Update a vector by ID
public static native boolean nativeVectorStoreUpdateVector(long storeId, long id, float[] vector);

// Reserve capacity for vectors
public static native boolean nativeVectorStoreReserve(long storeId, long capacity);

// Clear all vectors from the store
public static native void nativeVectorStoreClear(long storeId);

// Destroy the vector store and free resources
public static native void nativeVectorStoreDestroy(long storeId);
```

#### HNSWIndex Operations

```java
// Create a new HNSW index
public static native long nativeHNSWIndexCreate(int dimension, int metric, long maxElements);

// Create a new HNSW index with custom parameters
public static native long nativeHNSWIndexCreateWithParams(int dimension, int metric, long maxElements, int M, int efConstruction, int seed);

// Add a vector to the index
public static native boolean nativeHNSWIndexAddVector(long indexId, long id, float[] vector);

// Search for nearest neighbors
public static native SearchResult[] nativeHNSWIndexSearch(long indexId, float[] queryVector, int k);

// Set the efSearch parameter for search quality
public static native boolean nativeHNSWIndexSetEfSearch(long indexId, int efSearch);

// Get the current efSearch parameter
public static native int nativeHNSWIndexGetEfSearch(long indexId);

// Get the number of vectors in the index
public static native long nativeHNSWIndexGetSize(long indexId);

// Get the dimension of vectors in the index
public static native int nativeHNSWIndexGetDimension(long indexId);

// Get the capacity of the index
public static native long nativeHNSWIndexGetCapacity(long indexId);

// Check if a vector exists by ID
public static native boolean nativeHNSWIndexContains(long indexId, long id);

// Get a vector by ID
public static native float[] nativeHNSWIndexGetVector(long indexId, long id);

// Save the index to a file
public static native boolean nativeHNSWIndexSave(long indexId, String filename);

// Load an index from a file
public static native long nativeHNSWIndexLoad(String filename);

// Destroy the index and free resources
public static native void nativeHNSWIndexDestroy(long indexId);
```

#### MMapVectorStoreBuilder Operations

```java
// Create a new MMapVectorStore builder
public static native long nativeMMapVectorStoreBuilderCreate(int dimension, int metric);

// Add a vector to the builder
public static native boolean nativeMMapVectorStoreBuilderAddVector(long builderId, long id, float[] vector);

// Reserve capacity for vectors
public static native boolean nativeMMapVectorStoreBuilderReserve(long builderId, long capacity);

// Save the builder to create an MMapVectorStore
public static native boolean nativeMMapVectorStoreBuilderSave(long builderId, String filename);

// Get the number of vectors in the builder
public static native long nativeMMapVectorStoreBuilderGetSize(long builderId);

// Get the dimension of vectors in the builder
public static native int nativeMMapVectorStoreBuilderGetDimension(long builderId);

// Destroy the builder and free resources
public static native void nativeMMapVectorStoreBuilderDestroy(long builderId);
```

#### MMapVectorStore Operations

```java
// Open an existing memory-mapped vector store
public static native long nativeMMapVectorStoreOpen(String filename);

// Get a vector by ID
public static native float[] nativeMMapVectorStoreGetVector(long storeId, long id);

// Check if a vector exists by ID
public static native boolean nativeMMapVectorStoreContains(long storeId, long id);

// Search for nearest neighbors
public static native SearchResult[] nativeMMapVectorStoreSearch(long storeId, float[] queryVector, int k);

// Get the number of vectors in the store
public static native long nativeMMapVectorStoreGetSize(long storeId);

// Get the dimension of vectors in the store
public static native int nativeMMapVectorStoreGetDimension(long storeId);

// Get the distance metric used by the store
public static native int nativeMMapVectorStoreGetMetric(long storeId);

// Close the memory-mapped store and free resources
public static native void nativeMMapVectorStoreClose(long storeId);
```

#### Version Information Methods

```java
// Get the library version string
public static native String nativeGetVersion();

// Get the major version number
public static native int nativeGetVersionMajor();

// Get the minor version number
public static native int nativeGetVersionMinor();

// Get the patch version number
public static native int nativeGetVersionPatch();
```

#### Convenience Methods

```java
// Create a vector store with a DistanceMetric enum
public static long createVectorStore(int dimension, DistanceMetric metric) {
    return nativeVectorStoreCreate(dimension, metric.getValue());
}

// Create a vector store with default COSINE distance metric
public static long createVectorStore(int dimension) {
    return createVectorStore(dimension, DistanceMetric.COSINE);
}

// Create an HNSW index with a DistanceMetric enum
public static long createHNSWIndex(int dimension, DistanceMetric metric, long maxElements) {
    return nativeHNSWIndexCreate(dimension, metric.getValue(), maxElements);
}

// Create an HNSW index with custom parameters
public static long createHNSWIndex(int dimension, DistanceMetric metric, long maxElements, int M, int efConstruction, int seed) {
    return nativeHNSWIndexCreateWithParams(dimension, metric.getValue(), maxElements, M, efConstruction, seed);
}

// Create an HNSW index with default COSINE distance metric
public static long createHNSWIndex(int dimension, long maxElements) {
    return createHNSWIndex(dimension, DistanceMetric.COSINE, maxElements);
}

// Create an MMapVectorStore builder with a DistanceMetric enum
public static long createMMapVectorStoreBuilder(int dimension, DistanceMetric metric) {
    return nativeMMapVectorStoreBuilderCreate(dimension, metric.getValue());
}

// Create an MMapVectorStore builder with default COSINE distance metric
public static long createMMapVectorStoreBuilder(int dimension) {
    return createMMapVectorStoreBuilder(dimension, DistanceMetric.COSINE);
}

// Open an existing MMapVectorStore
public static long openMMapVectorStore(String filePath) {
    return nativeMMapVectorStoreOpen(filePath);
}

// Get the library version string
public static String getVersion() {
    return nativeGetVersion();
}

// Get the major version number
public static int getVersionMajor() {
    return nativeGetVersionMajor();
}

// Get the minor version number
public static int getVersionMinor() {
    return nativeGetVersionMinor();
}

// Get the patch version number
public static int getVersionPatch() {
    return nativeGetVersionPatch();
}
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
- Java 8+ or Kotlin 1.8+
- Gradle 7.4+

## Building from Source

To build the Android Java SDK from source:

```bash
cd /path/to/llama_mobile_vector_database
./scripts/build-android-SDK.sh
```

This will build the native libraries and update the Java SDK.

## Running Tests

The Android Java SDK includes both unit tests and instrumented tests:

### Unit Tests

Unit tests run on the JVM and test basic functionality:

```bash
cd /path/to/llama_mobile_vector_database
cd llama_mobile_vd-android-java-SDK
./gradlew test
```

### Instrumented Tests

Instrumented tests run on an Android device or emulator and test the actual vector database functionality:

```bash
cd /path/to/llama_mobile_vector_database
cd llama_mobile_vd-android-java-SDK
./gradlew connectedAndroidTest
```

## License

See the LICENSE file for details.