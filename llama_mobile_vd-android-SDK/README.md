# LlamaMobileVD Android SDK

A high-performance vector database SDK for Android applications, built on top of the LlamaMobileVD native library. This SDK provides embeddable vector database capabilities for Android apps with both Java and Kotlin interfaces, running natively with SIMD acceleration.

## Features

- **Dual API**: Both Java and Kotlin interfaces for vector storage and search
- **High performance**: Built on a C++ core with ARM NEON acceleration
- **Multiple distance metrics**: Support for L2 (Euclidean), Cosine, and Dot Product distances
- **VectorStore**: Exact nearest neighbor search with thread-safe operations
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
- **MMapVectorStore**: Memory-mapped vector store optimized for large datasets exceeding RAM capacity
- **Auto-managed resources**: Implements `AutoCloseable` for proper resource management
- **Multi-dimensional support**: Handles common embedding sizes (384, 768, 1024, 3072 dimensions)

## Requirements

- Android API Level 21+ (Android 5.0+)
- Android Studio 4.0+
- Kotlin 1.5+
- Gradle 7.0+

## Installation

### Gradle (Android Studio)

1. In your project's `settings.gradle` file, add the repository:

```gradle
repositories {
    maven {
        url = uri('/path/to/llama_mobile_vector_database/llama_mobile_vd-android-SDK')
    }
}
```

2. In your app's `build.gradle` file, add the dependency:

```gradle
dependencies {
    implementation project(':llama_mobile_vd-android-SDK')
}
```

3. Make sure your app's `build.gradle` includes NDK support:

```gradle
android {
    defaultConfig {
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
    
    externalNativeBuild {
        cmake {
            path file('src/main/cpp/CMakeLists.txt')
        }
    }
}
```

### Manual Installation

1. Copy the `llama_mobile_vd-android-SDK` directory to your project
2. Add the following to your settings.gradle:

```gradle
include ':llama_mobile_vd-android-SDK'
```

3. Add the dependency in your app's build.gradle:

```gradle
dependencies {
    implementation project(':llama_mobile_vd-android-SDK')
}
```

## Usage

### VectorStore Example (Kotlin)

```kotlin
import com.llamamobile.vd.*

// Create a vector store with 512-dimensional vectors and cosine distance metric
val vectorStore = VectorStore(512, DistanceMetric.COSINE)

try {
    // Add vectors to the store
    val vector1 = FloatArray(512) { 0.5f }
    vectorStore.addVector(vector1, 1)
    
    val vector2 = FloatArray(512) { 0.8f }
    vectorStore.addVector(vector2, 2)
    
    // Search for nearest neighbors
    val queryVector = FloatArray(512) { 0.6f }
    val results = vectorStore.search(queryVector, 2)
    
    // Process the results
    for (result in results) {
        println("Vector ID: ${result.id}, Distance: ${result.distance}")
    }
    
    // Clear all vectors from the store
    vectorStore.clear()
    
} finally {
    // Close the store to free resources
    vectorStore.close()
}
```

### VectorStore Example (Java)

```java
import com.llamamobile.vd.*;

// Create a vector store with 512-dimensional vectors and cosine distance metric
VectorStore vectorStore = new VectorStore(512, DistanceMetric.COSINE);

try {
    // Add vectors to the store
    float[] vector1 = new float[512];
    for (int i = 0; i < vector1.length; i++) {
        vector1[i] = 0.5f;
    }
    vectorStore.addVector(vector1, 1);
    
    float[] vector2 = new float[512];
    for (int i = 0; i < vector2.length; i++) {
        vector2[i] = 0.8f;
    }
    vectorStore.addVector(vector2, 2);
    
    // Search for nearest neighbors
    float[] queryVector = new float[512];
    for (int i = 0; i < queryVector.length; i++) {
        queryVector[i] = 0.6f;
    }
    SearchResult[] results = vectorStore.search(queryVector, 2);
    
    // Process the results
    for (SearchResult result : results) {
        System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
    }
    
    // Clear all vectors from the store
    vectorStore.clear();
    
} finally {
    // Close the store to free resources
    vectorStore.close();
}
```

### MMapVectorStore Example (Kotlin)

```kotlin
import com.llamamobile.vd.*
import java.io.File

// Create a temporary file for the MMapVectorStore
val tempFile = File.createTempFile("mmap_store", ".store")
val tempFilePath = tempFile.absolutePath

try {
    // Create a builder with 512-dimensional vectors and cosine distance metric
    MMapVectorStoreBuilder(dimension = 512, metric = DistanceMetric.COSINE).use {
        // Add vectors to the builder
        it.addVector(FloatArray(512) { 1.0f }, 1)
        it.addVector(FloatArray(512) { 0.8f }, 2)
        it.addVector(FloatArray(512) { 0.5f }, 3)
        
        // Save the builder to disk
        it.save(tempFilePath)
    }
    
    // Open the MMapVectorStore from file
    MMapVectorStore.open(tempFilePath).use { store ->
        // Verify the store contents
        println("Total vectors: ${store.getCount()}")
        println("Dimension: ${store.dimension}")
        println("Metric: ${store.metric}")
        
        // Search for nearest neighbors
        val queryVector = FloatArray(512) { 0.9f }
        val results = store.search(queryVector, 2)
        
        // Process the results
        for (result in results) {
            println("Vector ID: ${result.id}, Distance: ${result.distance}")
        }
    }
} finally {
    // Clean up the temporary file
    tempFile.delete()
}
```

### MMapVectorStore Example (Java)

```java
import com.llamamobile.vd.*;
import java.io.File;
import java.io.IOException;

// Create a temporary file for the MMapVectorStore
File tempFile = null;
try {
    tempFile = File.createTempFile("mmap_store", ".store");
    String tempFilePath = tempFile.getAbsolutePath();
    
    // Create a builder with 512-dimensional vectors and cosine distance metric
    try (MMapVectorStoreBuilder builder = new MMapVectorStoreBuilder(512, DistanceMetric.COSINE)) {
        // Add vectors to the builder
        float[] vector1 = new float[512];
        for (int i = 0; i < vector1.length; i++) {
            vector1[i] = 1.0f;
        }
        builder.addVector(vector1, 1);
        
        float[] vector2 = new float[512];
        for (int i = 0; i < vector2.length; i++) {
            vector2[i] = 0.8f;
        }
        builder.addVector(vector2, 2);
        
        float[] vector3 = new float[512];
        for (int i = 0; i < vector3.length; i++) {
            vector3[i] = 0.5f;
        }
        builder.addVector(vector3, 3);
        
        // Save the builder to disk
        builder.save(tempFilePath);
    }
    
    // Open the MMapVectorStore from file
    try (MMapVectorStore store = MMapVectorStore.open(tempFilePath)) {
        // Verify the store contents
        System.out.println("Total vectors: " + store.getCount());
        System.out.println("Dimension: " + store.getDimension());
        System.out.println("Metric: " + store.getMetric());
        
        // Search for nearest neighbors
        float[] queryVector = new float[512];
        for (int i = 0; i < queryVector.length; i++) {
            queryVector[i] = 0.9f;
        }
        SearchResult[] results = store.search(queryVector, 2);
        
        // Process the results
        for (SearchResult result : results) {
            System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
        }
    }
} catch (IOException e) {
    e.printStackTrace();
} finally {
    if (tempFile != null) {
        // Clean up the temporary file
        tempFile.delete();
    }
}
```

### HNSWIndex Example

```kotlin
import com.llamamobile.vd.*

// Create an HNSW index with custom parameters
val hnswIndex = HNSWIndex(
    dimension = 768,
    metric = DistanceMetric.L2,
    m = 16, // Number of connections per node
    efConstruction = 200 // Size of dynamic list for construction
)

try {
    // Add vectors to the index
    for (i in 0 until 100) {
        val vector = FloatArray(768) { (i / 100.0f) }
        hnswIndex.addVector(vector, i + 1)
    }
    
    // Search for nearest neighbors with custom efSearch
    val queryVector = FloatArray(768) { 0.5f }
    val results = hnswIndex.search(queryVector, k = 5, efSearch = 100)
    
    // Process the results
    results.forEach { result ->
        println("Vector ID: ${result.id}, Distance: ${result.distance}")
    }
    
    // Get the number of vectors in the index
    val count = hnswIndex.getCount()
    println("Total vectors in index: $count")
    
} finally {
    // Close the index to free resources
    hnswIndex.close()
}
```

### Using with Kotlin's use() function

Both VectorStore and HNSWIndex implement `AutoCloseable`, so you can use Kotlin's `use()` function for automatic resource management:

```kotlin
import com.llamamobile.vd.*

VectorStore(512, DistanceMetric.COSINE).use { vectorStore ->
    // Add vectors and perform searches
    val vector = FloatArray(512) { 0.5f }
    vectorStore.addVector(vector, 1)
    
    val queryVector = FloatArray(512) { 0.6f }
    val results = vectorStore.search(queryVector, 1)
    println("Nearest vector: ${results[0].id}")
}
// vectorStore is automatically closed here
```

## API Reference

### MMapVectorStore

A memory-mapped vector store optimized for large datasets that may exceed RAM capacity. Uses memory mapping for efficient access to large datasets without loading everything into RAM.

```kotlin
class MMapVectorStore private constructor(private val pointer: Long) : AutoCloseable {
    companion object {
        // Open an MMapVectorStore from a file
        fun open(filename: String): MMapVectorStore
    }
    
    // Get a vector from the store by ID
    fun get(id: Int): FloatArray?
    
    // Search for the k nearest neighbors of a query vector
    fun search(queryVector: FloatArray, k: Int): Array<SearchResult>
    
    // Check if the store contains a vector with the given ID
    fun contains(id: Int): Boolean
    
    // Get the number of vectors in the store
    fun getCount(): Int
    
    // Get the dimension of the vectors in the store
    val dimension: Int
    
    // Get the distance metric used by the store
    val metric: DistanceMetric
    
    // Close the vector store and free resources
    override fun close()
}
```

```java
public class MMapVectorStore implements AutoCloseable {
    // Open an MMapVectorStore from a file
    public static MMapVectorStore open(String filename)
    
    // Get a vector from the store by ID
    public float[] get(int id)
    
    // Search for the k nearest neighbors of a query vector
    public SearchResult[] search(float[] queryVector, int k)
    
    // Check if the store contains a vector with the given ID
    public boolean contains(int id)
    
    // Get the number of vectors in the store
    public int getCount()
    
    // Get the dimension of the vectors in the store
    public int getDimension()
    
    // Get the distance metric used by the store
    public DistanceMetric getMetric()
    
    // Close the vector store and free resources
    @Override
    public void close()
}
```

### MMapVectorStoreBuilder

A builder for creating and saving MMapVectorStore instances.

```kotlin
class MMapVectorStoreBuilder(dimension: Int, metric: DistanceMetric) : AutoCloseable {
    // Add a vector to the builder
    fun addVector(vector: FloatArray, id: Int)
    
    // Reserve space for the specified number of vectors
    fun reserve(capacity: Int)
    
    // Save the builder's contents to a file, creating an MMapVectorStore
    fun save(filename: String): Boolean
    
    // Get the number of vectors in the builder
    fun getCount(): Int
    
    // Get the dimension of the vectors in the builder
    val dimension: Int
    
    // Close the builder and free resources
    override fun close()
}
```

```java
public class MMapVectorStoreBuilder implements AutoCloseable {
    // Create a new MMapVectorStore builder
    public MMapVectorStoreBuilder(int dimension, DistanceMetric metric)
    
    // Add a vector to the builder
    public void addVector(float[] vector, int id)
    
    // Reserve space for the specified number of vectors
    public void reserve(int capacity)
    
    // Save the builder's contents to a file, creating an MMapVectorStore
    public boolean save(String filename)
    
    // Get the number of vectors in the builder
    public int getCount()
    
    // Get the dimension of the vectors in the builder
    public int getDimension()
    
    // Close the builder and free resources
    @Override
    public void close()
}
```

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

```kotlin
enum class DistanceMetric {
    L2,      // Euclidean distance
    COSINE,  // Cosine distance
    DOT      // Dot product distance
}
```

```java
public enum DistanceMetric {
    L2(0),      // Euclidean distance
    COSINE(1),  // Cosine distance
    DOT(2);     // Dot product distance
    
    public int getValue() { ... }
}
```

### SearchResult

Class representing a result from a vector search operation:

```kotlin
data class SearchResult(
    val id: Int,         // The ID of the vector
    val distance: Float  // The distance between the query vector and the result vector
)
```

```java
public class SearchResult {
    public int getId() { ... }         // The ID of the vector
    public float getDistance() { ... }  // The distance between the query vector and the result vector
}
```

### VectorStore

Class for storing and searching vectors with exact nearest neighbor search. Implements `AutoCloseable` for resource management.

```kotlin
class VectorStore(
    dimension: Int,      // The dimension of vectors to be stored
    metric: DistanceMetric  // The distance metric to use for search
) : AutoCloseable {
    
    // Add a vector to the store
    fun addVector(vector: FloatArray, id: Int)
    
    // Search for the k nearest neighbors of a query vector
    fun search(queryVector: FloatArray, k: Int): Array<SearchResult>
    
    // Get the number of vectors in the store
    fun getCount(): Int
    
    // Clear all vectors from the store
    fun clear()
    
    // Close the store and free resources
    override fun close()
}
```

### HNSWIndex

Class for high-performance approximate nearest neighbor search using the HNSW algorithm. Implements `AutoCloseable` for resource management.

```kotlin
class HNSWIndex(
    dimension: Int,          // The dimension of vectors to be stored
    metric: DistanceMetric,  // The distance metric to use for search
    m: Int = 16,             // Maximum number of connections per node
    efConstruction: Int = 200  // Size of dynamic list for candidate selection during construction
) : AutoCloseable {
    
    // Add a vector to the index
    fun addVector(vector: FloatArray, id: Int)
    
    // Search for the k nearest neighbors of a query vector
    fun search(
        queryVector: FloatArray, 
        k: Int,                   // Number of nearest neighbors to return
        efSearch: Int = 50        // Size of dynamic list for candidate selection during search
    ): Array<SearchResult>
    
    // Get the number of vectors in the index
    fun getCount(): Int
    
    // Clear all vectors from the index
    fun clear()
    
    // Close the index and free resources
    override fun close()
}
```

## Performance Tips

- For large datasets (10,000+ vectors), use `HNSWIndex` instead of `VectorStore` for faster search performance
- For very large datasets that exceed RAM capacity (100,000+ vectors), use `MMapVectorStore` to leverage memory mapping
- MMapVectorStore is particularly useful for:
  - Datasets larger than device RAM
  - Applications with limited memory
  - Persistent vector storage needs
- Adjust `m` and `efConstruction` parameters when creating an `HNSWIndex`:
  - Higher `m` values create more connections per node (better search quality, higher memory usage)
  - Higher `efConstruction` values improve index quality (slower build time)
- Adjust `efSearch` parameter during search to balance speed and quality
- For common embedding sizes (384, 768, 1024, 3072), the SDK is optimized for performance
- Use try-with-resources (Java) or `use()` function (Kotlin) to ensure proper resource cleanup

## Building from Source

To build the Android SDK from source:

```bash
cd /path/to/llama_mobile_vector_database
./scripts/build-android.sh
```

This will build the native library and update the Kotlin SDK.

## Running Tests

The Android Kotlin SDK includes a comprehensive test suite that covers all API functionality:

### Using Android Studio

1. Open Android Studio and select `File > Open`
2. Navigate to the `llama_mobile_vd-android-SDK` directory
3. Select the directory
4. In the project view, navigate to `src/test/kotlin/com/llamamobile/vd`
5. Right-click on `LlamaMobileVDTests.kt` and select `Run 'LlamaMobileVDTests'`

### Using Terminal (Gradle)

To run the tests from the command line:

```bash
cd /path/to/llama_mobile_vector_database/llama_mobile_vd-android-SDK
./gradlew test
```

### Test Coverage

The test suite covers:
- VectorStore creation, addition, search, and deletion operations
- HNSWIndex creation, addition, search, and deletion operations
- MMapVectorStore creation, addition, search, and persistence operations
- All distance metrics (L2, Cosine, Dot)
- Various vector dimensions (384, 768, 1024, 3072)
- Edge cases and error handling
- AutoCloseable interface implementation
- Large vector dimensions
- Both Java and Kotlin interface functionality

## License

See the LICENSE file for details.
