# LlamaMobileVD Android Kotlin SDK

A high-performance vector database SDK for Android applications, built on top of the LlamaMobileVD native library. This SDK provides embeddable vector database capabilities for Android apps, running natively with SIMD acceleration.

## Features

- **Native Kotlin API**: Clean, intuitive Kotlin interface for vector storage and search
- **High performance**: Built on a C++ core with ARM NEON acceleration
- **Multiple distance metrics**: Support for L2 (Euclidean), Cosine, and Dot Product distances
- **VectorStore**: Exact nearest neighbor search with thread-safe operations
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
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

### VectorStore Example

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

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

```kotlin
enum class DistanceMetric {
    L2,      // Euclidean distance
    COSINE,  // Cosine distance
    DOT      // Dot product distance
}
```

### SearchResult

Data class representing a result from a vector search operation:

```kotlin
data class SearchResult(
    val id: Int,         // The ID of the vector
    val distance: Float  // The distance between the query vector and the result vector
)
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
- Adjust `m` and `efConstruction` parameters when creating an `HNSWIndex`:
  - Higher `m` values create more connections per node (better search quality, higher memory usage)
  - Higher `efConstruction` values improve index quality (slower build time)
- Adjust `efSearch` parameter during search to balance speed and quality
- For common embedding sizes (384, 768, 1024, 3072), the SDK is optimized for performance
- Use `use()` function to ensure proper resource cleanup

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
- All distance metrics (L2, Cosine, Dot)
- Various vector dimensions (384, 768, 1024, 3072)
- Edge cases and error handling
- AutoCloseable interface implementation
- Large vector dimensions

## License

See the LICENSE file for details.
