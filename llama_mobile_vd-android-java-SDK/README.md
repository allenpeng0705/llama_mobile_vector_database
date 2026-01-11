# LlamaMobileVD Android Java SDK

A high-performance vector database SDK for Android applications, built on top of the LlamaMobileVD native library.

## Features

- **Easy-to-use Java API**: Simple and intuitive interface for vector storage and search
- **High performance**: Built on a C++ core with JNI bindings for maximum speed
- **Multiple distance metrics**: Support for L2, cosine, and dot product distances
- **VectorStore**: Simple in-memory vector storage
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
- **Self-contained**: Easy to copy and use in your Android projects
- **AutoCloseable**: Resources are automatically managed with Java's try-with-resources statement

## Requirements

- Android API level 24+
- Java 8+
- Android Studio 2022.1.1+

## Installation

### Android Studio

1. Copy the `llama_mobile_vd-android-java-SDK` directory to your project
2. In your project's `settings.gradle` file, add the following:

```groovy
include ':llama_mobile_vd-android-java-SDK'
```

3. In your app's `build.gradle` file, add the dependency:

```groovy
dependencies {
    implementation project(':llama_mobile_vd-android-java-SDK')
}
```

### Manual Installation

1. Copy the `llama_mobile_vd-android-java-SDK` directory to your project
2. Copy the native libraries from `src/main/jniLibs` to your app's `src/main/jniLibs` directory
3. Copy the Java source files from `src/main/java` to your app's source directory

## Usage

### VectorStore Example

```java
import com.llamamobile.vd.*;

// Create a vector store with 128-dimensional vectors and L2 distance metric
VectorStore vectorStore = new VectorStore(128, DistanceMetric.L2);

try {
    // Add vectors to the store
    float[] vector1 = new float[128];
    float[] vector2 = new float[128];
    for (int i = 0; i < 128; i++) {
        vector1[i] = 0.0f;
        vector2[i] = 1.0f;
    }

    vectorStore.addVector(vector1, 1);
    vectorStore.addVector(vector2, 2);

    // Search for nearest neighbors
    float[] queryVector = new float[128];
    for (int i = 0; i < 128; i++) {
        queryVector[i] = 0.1f;
    }
    SearchResult[] results = vectorStore.search(queryVector, 2);

    // Print results
    for (SearchResult result : results) {
        System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
    }
} finally {
    // Close the vector store when done
    vectorStore.close();
}
```

### HNSWIndex Example with try-with-resources

```java
import com.llamamobile.vd.*;

// Create an HNSW index with custom parameters using try-with-resources
try (HNSWIndex hnswIndex = new HNSWIndex(128, DistanceMetric.COSINE, 32, 400)) {
    // Add vectors to the index
    float[][] vectors = new float[100][128];
    for (int id = 0; id < 100; id++) {
        for (int dim = 0; dim < 128; dim++) {
            vectors[id][dim] = (float) id / 100.0f;
        }
        hnswIndex.addVector(vectors[id], id + 1);
    }

    // Search for nearest neighbors
    float[] queryVector = new float[128];
    for (int i = 0; i < 128; i++) {
        queryVector[i] = 0.5f;
    }
    SearchResult[] results = hnswIndex.search(queryVector, 5, 100);

    // Print results
    for (SearchResult result : results) {
        System.out.println("Vector ID: " + result.getId() + ", Distance: " + result.getDistance());
    }
} catch (Exception e) {
    // Handle any exceptions
    e.printStackTrace();
}
// The index is automatically closed when exiting the try-with-resources block
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `L2`: Euclidean distance
- `COSINE`: Cosine distance
- `DOT`: Dot product distance

### SearchResult

Class representing a result from a vector search:

- `int getId()`: Get the ID of the vector
- `float getDistance()`: Get the distance between the query vector and the result vector

### VectorStore

Class for storing and searching vectors, implementing `AutoCloseable`:

- `VectorStore(int dimension, DistanceMetric metric)`: Create a new vector store
- `void addVector(float[] vector, int id)`: Add a vector to the store
- `SearchResult[] search(float[] queryVector, int k)`: Search for nearest neighbors
- `int getCount()`: Get the number of vectors in the store
- `void clear()`: Clear all vectors from the store
- `void close()`: Close the vector store and free resources

### HNSWIndex

Class for high-performance approximate nearest neighbor search, implementing `AutoCloseable`:

- `HNSWIndex(int dimension, DistanceMetric metric)`: Create a new HNSW index with default parameters (m=16, efConstruction=200)
- `HNSWIndex(int dimension, DistanceMetric metric, int m, int efConstruction)`: Create a new HNSW index with custom parameters
- `void addVector(float[] vector, int id)`: Add a vector to the index
- `SearchResult[] search(float[] queryVector, int k)`: Search for nearest neighbors with default efSearch=50
- `SearchResult[] search(float[] queryVector, int k, int efSearch)`: Search for nearest neighbors with custom efSearch
- `int getCount()`: Get the number of vectors in the index
- `void clear()`: Clear all vectors from the index
- `void close()`: Close the index and free resources

## Building the SDK

The Android Java SDK is built automatically when you run `build-android.sh` from the `llama_mobile_vector_database/scripts` directory. The SDK will be updated with the latest native libraries.

You can also manually update the SDK by running:

```bash
cd /path/to/llama_mobile_vector_database/scripts
./build-android.sh
```

## Running Tests

The Android Java SDK includes a comprehensive test suite that covers all API functionality:

### Using Android Studio

1. Open Android Studio and select `File > Open`
2. Navigate to the `llama_mobile_vd-android-java-SDK` directory
3. Select the directory
4. In the project view, navigate to `src/test/java/com/llamamobile/vd`
5. Right-click on `LlamaMobileVDTests.java` and select `Run 'LlamaMobileVDTests'`

### Using Terminal (Gradle)

To run the tests from the command line:

```bash
cd /path/to/llama_mobile_vector_database/llama_mobile_vd-android-java-SDK
./gradlew test
```

### Test Coverage

The test suite covers:
- VectorStore creation, addition, search, and deletion operations
- HNSWIndex creation, addition, search, and deletion operations
- All distance metrics (L2, Cosine, Dot)
- Various vector dimensions (384, 768, 1024, 3072)
- Edge cases and error handling
- Try-with-resources interface implementation
- Large vector dimensions
- Search results ordering

## Performance Tips

- For large datasets, use `HNSWIndex` instead of `VectorStore` for faster search performance
- Adjust the `m` and `efConstruction` parameters when creating an `HNSWIndex` for your specific use case:
  - Higher `m` values create more connections per node, improving search quality but increasing memory usage
  - Higher `efConstruction` values improve index quality but increase build time
- Adjust `efSearch` parameter during search to balance between search speed and quality

## License

See the LICENSE file for details.
