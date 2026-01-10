# LlamaMobileVD iOS Swift SDK

A high-performance vector database SDK for iOS applications, built on top of the LlamaMobileVD framework.

## Features

- **Easy-to-use Swift API**: Simple and intuitive interface for vector storage and search
- **High performance**: Built on a C++ core for maximum speed
- **Multiple distance metrics**: Support for L2, cosine, and dot product distances
- **VectorStore**: Simple in-memory vector storage
- **HNSWIndex**: High-performance approximate nearest neighbor search using the Hierarchical Navigable Small World algorithm
- **Self-contained**: Easy to copy and use in your iOS projects

## Requirements

- iOS 13.0+
- Swift 5.7+
- Xcode 14.0+

## Installation

### Swift Package Manager

1. Add the LlamaMobileVD iOS Swift SDK to your project by selecting **File > Add Packages...**
2. Enter the path to the `llama_mobile_vd-ios-SDK` directory
3. Click **Add Package**

### Manual Installation

1. Copy the `llama_mobile_vd-ios-SDK` directory to your project
2. Drag the `LlamaMobileVD.xcframework` from the `Frameworks` directory to your Xcode project
3. Make sure to select **Copy items if needed**
4. In your target's **General** settings, add the framework to **Frameworks, Libraries, and Embedded Content**

## Usage

### VectorStore Example

```swift
import LlamaMobileVD

// Create a vector store with 128-dimensional vectors and L2 distance metric
let vectorStore = try VectorStore(dimension: 128, metric: .l2)

// Add vectors to the store
let vector1: [Float] = Array(repeating: 0.0, count: 128)
let vector2: [Float] = Array(repeating: 1.0, count: 128)

try vectorStore.addVector(vector1, id: 1)
try vectorStore.addVector(vector2, id: 2)

// Search for nearest neighbors
let queryVector: [Float] = Array(repeating: 0.1, count: 128)
let results = try vectorStore.search(queryVector, k: 2)

// Print results
for result in results {
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}
```

### HNSWIndex Example

```swift
import LlamaMobileVD

// Create an HNSW index with 128-dimensional vectors and cosine distance metric
let hnswIndex = try HNSWIndex(dimension: 128, metric: .cosine)

// Add vectors to the index
let vectors: [[Float]] = (0..<100).map { id in
    Array(repeating: Float(id) / 100.0, count: 128)
}

for (id, vector) in vectors.enumerated() {
    try hnswIndex.addVector(vector, id: id + 1)
}

// Search for nearest neighbors
let queryVector: [Float] = Array(repeating: 0.5, count: 128)
let results = try hnswIndex.search(queryVector, k: 5, efSearch: 100)

// Print results
for result in results {
    print("Vector ID: \(result.id), Distance: \(result.distance)")
}
```

## API Reference

### DistanceMetric

Enum representing the distance metrics supported by LlamaMobileVD:

- `l2`: Euclidean distance
- `cosine`: Cosine distance
- `dot`: Dot product distance

### SearchResult

Struct representing a result from a vector search:

- `id: Int`: The ID of the vector
- `distance: Float`: The distance between the query vector and the result vector

### VectorStore

Class for storing and searching vectors:

- `init(dimension: Int, metric: DistanceMetric) throws`: Create a new vector store
- `func addVector(_ vector: [Float], id: Int) throws`: Add a vector to the store
- `func search(_ queryVector: [Float], k: Int) throws -> [SearchResult]`: Search for nearest neighbors
- `var count: Int`: Get the number of vectors in the store
- `func clear() throws`: Clear all vectors from the store

### HNSWIndex

Class for high-performance approximate nearest neighbor search:

- `init(dimension: Int, metric: DistanceMetric) throws`: Create a new HNSW index with default parameters
- `init(dimension: Int, metric: DistanceMetric, m: Int, efConstruction: Int) throws`: Create a new HNSW index with custom parameters
- `func addVector(_ vector: [Float], id: Int) throws`: Add a vector to the index
- `func search(_ queryVector: [Float], k: Int, efSearch: Int = 50) throws -> [SearchResult]`: Search for nearest neighbors
- `var count: Int`: Get the number of vectors in the index
- `func clear() throws`: Clear all vectors from the index

## Building the SDK

The iOS Swift SDK is built automatically when you run `build-ios.sh` from the `llama_mobile_vd/scripts` directory. The SDK will be updated with the latest framework.

You can also manually update the SDK by running:

```bash
cd /Users/shileipeng/Documents/mygithub/llama_mobile/llama_mobile_vd/scripts
./build-ios-SDK.sh
```

## License

See the LICENSE file for details.
