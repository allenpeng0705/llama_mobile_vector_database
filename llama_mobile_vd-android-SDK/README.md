# LlamaMobileVD Android Kotlin SDK

A high-performance vector database SDK for Android applications, built on top of the LlamaMobileVD native library.

## Features

- **Easy-to-use Kotlin API**: Simple and intuitive interface for vector storage and search
- **High performance**: Built on a C++ core with JNI bindings for maximum speed
- **Multiple distance metrics**: Support for L2, cosine, and dot product distances
- **VectorStore**: Simple in-memory vector storage
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
- **Self-contained**: Easy to copy and use in your Android projects
- **AutoCloseable**: Resources are automatically managed with Kotlin's `use` function

## Requirements

- Android API level 24+
- Kotlin 1.8+
- Android Studio 2022.1.1+

## Installation

### Android Studio

1. Copy the `llama_mobile_vd-android-SDK` directory to your project
2. In your project's `settings.gradle` file, add the following:

```groovy
include ':llama_mobile_vd-android-SDK'
```

3. In your app's `build.gradle` file, add the dependency:

```groovy
dependencies {
    implementation project(':llama_mobile_vd-android-SDK')
}
```

### Manual Installation

1. Copy the `llama_mobile_vd-android-SDK` directory to your project
2. Copy the native libraries from `src/main/jniLibs` to your app's `src/main/jniLibs` directory
3. Copy the Kotlin source files from `src/main/kotlin` to your app's source directory

## Usage

### VectorStore Example

```kotlin
import com.llamamobile.vd.*

// Create a vector store with 128-dimensional vectors and L2 distance metric
val vectorStore = VectorStore(128, DistanceMetric.L2)

// Add vectors to the store
val vector1 = FloatArray(128) { 0.0f }
val vector2 = FloatArray(128) { 1.0f }

vectorStore.addVector(vector1, 1)
vectorStore.addVector(vector2, 2)

// Search for nearest neighbors
val queryVector = FloatArray(128) { 0.1f }
val results = vectorStore.search(queryVector, 2)

// Print results
results.forEach { result ->
    println("Vector ID: ${result.id}, Distance: ${result.distance}")
}

// Close the vector store when done
vectorStore.close()
```

### HNSWIndex Example with AutoCloseable

```kotlin
import com.llamamobile.vd.*

// Create an HNSW index with custom parameters
HNSWIndex(128, DistanceMetric.COSINE, m = 32, efConstruction = 400).use { hnswIndex ->
    // Add vectors to the index
    val vectors = Array(100) { id ->
        FloatArray(128) { Float(id) / 100.0f }
    }

    vectors.forEachIndexed { index, vector ->
        hnswIndex.addVector(vector, index + 1)
    }

    // Search for nearest neighbors
    val queryVector = FloatArray(128) { 0.5f }
    val results = hnswIndex.search(queryVector, k = 5, efSearch = 100)

    // Print results
    results.forEach { result ->
        println("Vector ID: ${result.id}, Distance: ${result.distance}")
    }
}
// The index is automatically closed when exiting the use block
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `L2`: Euclidean distance
- `COSINE`: Cosine distance
- `DOT`: Dot product distance

### SearchResult

Data class representing a result from a vector search:

- `id: Int`: The ID of the vector
- `distance: Float`: The distance between the query vector and the result vector

### VectorStore

Class for storing and searching vectors, implementing `AutoCloseable`:

- `constructor(dimension: Int, metric: DistanceMetric)`: Create a new vector store
- `fun addVector(vector: FloatArray, id: Int)`: Add a vector to the store
- `fun search(queryVector: FloatArray, k: Int): Array<SearchResult>`: Search for nearest neighbors
- `fun getCount(): Int`: Get the number of vectors in the store
- `fun clear()`: Clear all vectors from the store
- `fun close()`: Close the vector store and free resources

### HNSWIndex

Class for high-performance approximate nearest neighbor search, implementing `AutoCloseable`:

- `constructor(dimension: Int, metric: DistanceMetric)`: Create a new HNSW index with default parameters (m=16, efConstruction=200)
- `constructor(dimension: Int, metric: DistanceMetric, m: Int, efConstruction: Int)`: Create a new HNSW index with custom parameters
- `fun addVector(vector: FloatArray, id: Int)`: Add a vector to the index
- `fun search(queryVector: FloatArray, k: Int, efSearch: Int = 50): Array<SearchResult>`: Search for nearest neighbors
- `fun getCount(): Int`: Get the number of vectors in the index
- `fun clear()`: Clear all vectors from the index
- `fun close()`: Close the index and free resources

## Building the SDK

The Android Kotlin SDK is built automatically when you run `build-android.sh` from the `llama_mobile_vd/scripts` directory. The SDK will be updated with the latest native libraries.

You can also manually update the SDK by running:

```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
./build-android-SDK.sh
```

## Performance Tips

- For large datasets, use `HNSWIndex` instead of `VectorStore` for faster search performance
- Adjust the `m` and `efConstruction` parameters when creating an `HNSWIndex` for your specific use case:
  - Higher `m` values create more connections per node, improving search quality but increasing memory usage
  - Higher `efConstruction` values improve index quality but increase build time
- Adjust `efSearch` parameter during search to balance between search speed and quality

## License

See the LICENSE file for details.
