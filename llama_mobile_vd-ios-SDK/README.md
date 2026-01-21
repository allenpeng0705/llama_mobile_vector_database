# LlamaMobileVD iOS Swift SDK

A high-performance vector database SDK for iOS applications, built on top of the LlamaMobileVD native library. This SDK provides embeddable vector database capabilities for iOS apps, running natively with SIMD acceleration.

## Features

- **Native Swift API**: Clean, intuitive Swift interface for vector storage and search
- **High performance**: Built on a C++ core with ARM NEON acceleration
- **Multiple distance metrics**: Support for L2 (Euclidean), Cosine, and Dot Product distances
- **VectorStore**: Exact nearest neighbor search with thread-safe operations
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
- **MMapVectorStore**: Memory-mapped vector store for large datasets that may exceed RAM capacity
- **Auto-managed resources**: Automatic memory management with Swift's ARC
- **Multi-dimensional support**: Handles common embedding sizes (384, 768, 1024, 3072 dimensions)

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

### Swift Package Manager

1. In Xcode, open your project and select `File > Add Package Dependencies`
2. Enter the URL of this repository
3. Select the `llama_mobile_vd-ios-SDK` directory
4. Add the package to your target

### Manual Installation

1. Copy the `llama_mobile_vd-ios-SDK` directory to your project
2. Add the `LlamaMobileVD.swift` file to your project
3. Copy the `LlamaMobileVD.framework` from `Sources/LlamaMobileVD/Frameworks/` to your project's Frameworks directory
4. Ensure the framework is included in your app's Frameworks, Libraries, and Embedded Content

## Usage

### VectorStore Example

```swift
import LlamaMobileVD

// Create a vector store with 512-dimensional vectors and cosine distance metric
let vectorStore = try LlamaMobileVD.VectorStore(dimension: 512, metric: .cosine)

// Add vectors to the store
let vector1 = Array(repeating: 0.5, count: 512)
try vectorStore.addVector(id: 1, vector: vector1)

let vector2 = Array(repeating: 0.8, count: 512)
try vectorStore.addVector(id: 2, vector: vector2)

// Search for nearest neighbors
let queryVector = Array(repeating: 0.6, count: 512)
let results = try vectorStore.search(query: queryVector, k: 2)

// Process the results
for result in results {
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}

// Get vector by ID
let retrievedVector = try vectorStore.getVector(id: 1)
print("Retrieved vector: \(retrievedVector.prefix(5))...")

// Update vector
let updatedVector = Array(repeating: 0.9, count: 512)
try vectorStore.updateVector(id: 1, vector: updatedVector)

// Check if vector exists
let exists = try vectorStore.containsVector(id: 1)
print("Vector 1 exists: \(exists)")

// Remove vector
let removed = try vectorStore.removeVector(id: 1)
print("Vector 1 removed: \(removed)")

// Clear all vectors from the store
try vectorStore.clear()
```

### HNSWIndex Example

```swift
import LlamaMobileVD

// Create an HNSW index with custom parameters
let hnswIndex = try LlamaMobileVD.HNSWIndex(
    dimension: 768,
    metric: .l2,
    maxElements: 1000, // Maximum number of vectors the index can hold
    m: 16, // Number of connections per node
    efConstruction: 200 // Size of dynamic list for construction
)

// Add vectors to the index
for i in 0..<100 {
    let vector = Array(repeating: Float(i) / 100.0, count: 768)
    try hnswIndex.addVector(id: UInt64(i + 1), vector: vector)
}

// Set custom efSearch for better search quality

try hnswIndex.setEfSearch(100)

// Search for nearest neighbors
let queryVector = Array(repeating: 0.5, count: 768)
let results = try hnswIndex.search(query: queryVector, k: 5)

// Process the results
results.forEach { result in
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}

// Get index properties
let count = try hnswIndex.count()
let dimension = try hnswIndex.dimension()
let capacity = try hnswIndex.capacity()

print("Total vectors in index: \(count)")
print("Index dimension: \(dimension)")
print("Index capacity: \(capacity)")

// Check if a vector exists
let exists = try hnswIndex.contains(id: 42)
print("Vector 42 exists: \(exists)")
```

### MMapVectorStore Example

```swift
import LlamaMobileVD

// Create a temporary file path
let tempDir = NSTemporaryDirectory()
let vectorStorePath = tempDir.appending("my_mmap_store.bin")

// Build the MMapVectorStore using the builder
let dimension = 1024
let metric = LlamaMobileVD.DistanceMetric.cosine

// Create a builder
let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)

// Add vectors to the builder
for i in 0..<1000 {
    let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
    try builder.addVector(id: UInt64(i + 1), vector: vector)
}

// Save the builder to file, creating an MMapVectorStore
try builder.save(to: vectorStorePath)

// Open the MMapVectorStore from file
let vectorStore = try LlamaMobileVD.MMapVectorStore.open(from: vectorStorePath)

// Get a vector by ID
let vector = try vectorStore.getVector(id: 42)
print("Vector 42: \(vector.prefix(5))...")

// Search for nearest neighbors
let queryVector = Array(repeating: 0.0, count: dimension)
let results = try vectorStore.search(query: queryVector, k: 5)

// Process search results
for result in results {
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}

// Check store properties
let storeCount = try vectorStore.count()
let storeDimension = try vectorStore.dimension()
let storeMetric = try vectorStore.metric()
let containsVector = try vectorStore.contains(id: 42)

print("Store dimension: \(storeDimension)")
print("Store metric: \(storeMetric)")
print("Total vectors: \(storeCount)")
print("Store contains vector 42: \(containsVector)")

// Clean up
let fileManager = FileManager.default
if fileManager.fileExists(atPath: vectorStorePath) {
    try? fileManager.removeItem(atPath: vectorStorePath)
}
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `.l2`: Euclidean distance
- `.cosine`: Cosine distance
- `.dot`: Dot product distance

### SearchResult

Tuple representing a result from a vector search:

```swift
(id: UInt64, distance: Float)
```

### VectorStore

Class for storing and searching vectors with exact nearest neighbor search:

```swift
public class VectorStore {
    // Initializer with default L2 distance metric
    public init(dimension: Int, metric: DistanceMetric = .l2) throws
    
    // Core operations
    public func addVector(id: UInt64, vector: [Float]) throws
    public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)]
    public func removeVector(id: UInt64) throws -> Bool
    public func getVector(id: UInt64) throws -> [Float]
    public func updateVector(id: UInt64, vector: [Float]) throws
    public func clear() throws
    
    // Metadata operations
    public func count() throws -> UInt64
    public func dimension() throws -> UInt64
    public func metric() throws -> DistanceMetric
    public func containsVector(id: UInt64) throws -> Bool
    public func reserveCapacity(capacity: UInt64) throws
}
```

### HNSWIndex

Class for high-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm:

```swift
public class HNSWIndex {
    // Initializers
    public init(dimension: Int, metric: DistanceMetric, maxElements: Int) throws
    public init(
        dimension: Int,
        metric: DistanceMetric,
        maxElements: Int,
        m: Int,
        efConstruction: Int,
        seed: UInt32 = 0
    ) throws
    
    // Core operations
    public func addVector(id: UInt64, vector: [Float]) throws
    public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)]
    public func getVector(id: UInt64) throws -> [Float]
    public func save(to filename: String) throws
    
    // Static load method
    public static func load(from filename: String) throws -> HNSWIndex
    
    // Configuration and metadata
    public func setEfSearch(_ efSearch: Int) throws
    public func getEfSearch() throws -> Int
    public func count() throws -> UInt64
    public func dimension() throws -> UInt64
    public func capacity() throws -> UInt64
    public func contains(id: UInt64) throws -> Bool
}
```

### MMapVectorStoreBuilder

Builder class for creating and saving MMapVectorStore instances:

```swift
public class MMapVectorStoreBuilder {
    // Initializer
    public init(dimension: Int, metric: DistanceMetric) throws
    
    // Methods
    public func addVector(id: UInt64, vector: [Float]) throws
    public func reserve(capacity: UInt64) throws
    public func save(to filename: String) throws
    
    // Metadata
    public func count() throws -> UInt64
    public func dimension() throws -> UInt64
}
```

### MMapVectorStore

Memory-mapped vector store optimized for large datasets that may exceed RAM capacity:

```swift
public class MMapVectorStore {
    // Static methods
    public static func open(from filename: String) throws -> MMapVectorStore
    
    // Methods
    public func getVector(id: UInt64) throws -> [Float]
    public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)]
    public func contains(id: UInt64) throws -> Bool
    
    // Metadata
    public func count() throws -> UInt64
    public func dimension() throws -> UInt64
    public func metric() throws -> DistanceMetric
}
```

## Performance Tips

### Which Vector Store to Choose?

- **VectorStore**: Use for exact nearest neighbor search with small to medium datasets (up to 10,000 vectors)
- **HNSWIndex**: Use for high-performance approximate nearest neighbor search with large datasets (10,000+ vectors)
- **MMapVectorStore**: Use for extremely large datasets that may exceed RAM capacity (hundreds of thousands to millions of vectors)

### MMapVectorStore Specific Tips

- MMapVectorStore provides zero-copy access to vector data on disk, making it ideal for large datasets
- Loading an MMapVectorStore is instant, regardless of size, as it doesn't need to load all vectors into RAM
- Search performance is slower than HNSWIndex but faster than VectorStore for very large datasets
- Perfect for applications that need to handle large vector datasets efficiently on mobile devices with limited RAM

### HNSWIndex Optimization

- Adjust `m` and `efConstruction` parameters when creating an `HNSWIndex`:
  - Higher `m` values create more connections per node (better search quality, higher memory usage)
  - Higher `efConstruction` values improve index quality (slower build time)
- Adjust `efSearch` parameter during search to balance speed and quality

### General Tips

- For common embedding sizes (384, 768, 1024, 3072), the SDK is optimized for performance
- Use `reserve()` method when you know the expected number of vectors to reduce memory reallocations
- Prefer vector dimensions that are multiples of 16 for optimal SIMD performance

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.0+

## Building from Source

To build the iOS SDK from source:

```bash
cd /path/to/llama_mobile_vector_database
./scripts/build-ios.sh
```

This will build the native framework and update the Swift SDK.

## Running Tests

The iOS SDK includes a comprehensive test suite that covers all API functionality:

### Using Xcode

1. Open Xcode and select `File > Open`
2. Navigate to the `llama_mobile_vd-ios-SDK` directory
3. Select the package
4. In the test navigator (Cmd+6), select the `LlamaMobileVDTests` target
5. Click the play button to run all tests

### Using Terminal

To run the tests from the command line:

```bash
cd /path/to/llama_mobile_vector_database/llama_mobile_vd-ios-SDK
xcodebuild test -scheme LlamaMobileVD -destination "platform=iOS Simulator,name=iPhone 14,OS=latest"
```

### Test Coverage

The test suite covers:
- VectorStore creation, addition, search, and deletion operations
- HNSWIndex creation, addition, search, and deletion operations
- MMapVectorStoreBuilder creation, vector addition, and saving operations
- MMapVectorStore opening, vector retrieval, and search operations
- All distance metrics (L2, Cosine, Dot)
- Various vector dimensions (384, 768, 1024, 3072)
- Edge cases and error handling
- Large vector dimensions

## License

See the LICENSE file for details.