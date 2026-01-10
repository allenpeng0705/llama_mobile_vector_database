# LlamaMobileVD iOS Swift SDK

A high-performance vector database SDK for iOS applications, built on top of the LlamaMobileVD native library. This SDK provides embeddable vector database capabilities for iOS apps, running natively with SIMD acceleration.

## Features

- **Native Swift API**: Clean, intuitive Swift interface for vector storage and search
- **High performance**: Built on a C++ core with ARM NEON acceleration
- **Multiple distance metrics**: Support for L2 (Euclidean), Cosine, and Dot Product distances
- **VectorStore**: Exact nearest neighbor search with thread-safe operations
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
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
let vectorStore = try VectorStore(dimension: 512, metric: .cosine)

// Add vectors to the store
let vector1 = Array(repeating: 0.5, count: 512)
try vectorStore.addVector(vector1, id: 1)

let vector2 = Array(repeating: 0.8, count: 512)
try vectorStore.addVector(vector2, id: 2)

// Search for nearest neighbors
let queryVector = Array(repeating: 0.6, count: 512)
let results = try vectorStore.search(queryVector, k: 2)

// Process the results
for result in results {
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}

// Clear all vectors from the store
try vectorStore.clear()
```

### HNSWIndex Example

```swift
import LlamaMobileVD

// Create an HNSW index with custom parameters
let hnswIndex = try HNSWIndex(
    dimension: 768,
    metric: .l2,
    m: 16, // Number of connections per node
    efConstruction: 200 // Size of dynamic list for construction
)

// Add vectors to the index
for i in 0..<100 {
    let vector = Array(repeating: Float(i) / 100.0, count: 768)
    try hnswIndex.addVector(vector, id: i + 1)
}

// Search for nearest neighbors with custom efSearch
let queryVector = Array(repeating: 0.5, count: 768)
let results = try hnswIndex.search(queryVector, k: 5, efSearch: 100)

// Process the results
results.forEach { result in
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}

// Get the number of vectors in the index
let count = hnswIndex.count
print("Total vectors in index: \(count)")
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `.l2`: Euclidean distance
- `.cosine`: Cosine distance
- `.dot`: Dot product distance

### SearchResult

Structure representing a result from a vector search:

```swift
public struct SearchResult {
    public let id: Int
    public let distance: Float
}
```

### VectorStore

Class for storing and searching vectors with exact nearest neighbor search:

```swift
public class VectorStore {
    // Initializer
    public init(dimension: Int, metric: DistanceMetric) throws
    
    // Methods
    public func addVector(_ vector: [Float], id: Int) throws
    public func search(_ queryVector: [Float], k: Int) throws -> [SearchResult]
    public func clear() throws
    
    // Properties
    public var count: Int
}
```

### HNSWIndex

Class for high-performance approximate nearest neighbor search:

```swift
public class HNSWIndex {
    // Initializers
    public init(dimension: Int, metric: DistanceMetric, m: Int = 16, efConstruction: Int = 200) throws
    
    // Methods
    public func addVector(_ vector: [Float], id: Int) throws
    public func search(_ queryVector: [Float], k: Int, efSearch: Int = 50) throws -> [SearchResult]
    public func clear() throws
    
    // Properties
    public var count: Int
}
```

## Performance Tips

- For large datasets (10,000+ vectors), use `HNSWIndex` instead of `VectorStore` for faster search performance
- Adjust `m` and `efConstruction` parameters when creating an `HNSWIndex`:
  - Higher `m` values create more connections per node (better search quality, higher memory usage)
  - Higher `efConstruction` values improve index quality (slower build time)
- Adjust `efSearch` parameter during search to balance speed and quality
- For common embedding sizes (384, 768, 1024, 3072), the SDK is optimized for performance

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
- All distance metrics (L2, Cosine, Dot)
- Various vector dimensions (384, 768, 1024, 3072)
- Edge cases and error handling
- Large vector dimensions

## License

See the LICENSE file for details.