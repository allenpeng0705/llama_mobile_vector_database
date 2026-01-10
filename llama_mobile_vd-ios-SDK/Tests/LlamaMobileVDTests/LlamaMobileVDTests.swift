import XCTest
import LlamaMobileVD

final class LlamaMobileVDTests: XCTestCase {
    
    // Test vector dimensions (including common sizes like 384, 768, 1024)
    private let testDimensions = [384, 768, 1024]
    
    // Test distance metrics
    private let testMetrics: [DistanceMetric] = [.l2, .cosine, .dot]
    
    func testVectorStoreCreation() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let vectorStore = try VectorStore(dimension: dimension, metric: metric)
                    XCTAssertEqual(vectorStore.count, 0)
                }, "Failed to create VectorStore with dimension dimension) and metric metric)")
            }
        }
    }
    
    func testVectorStoreAddVector() {
        let dimension = 512
        let metric = DistanceMetric.l2
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            
            // Test adding a single vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(vector, id: 1)
            XCTAssertEqual(vectorStore.count, 1)
            
            // Test adding multiple vectors
            for i in 2...10 {
                let vector = Array(repeating: Float(i) / 10.0, count: dimension)
                try vectorStore.addVector(vector, id: i)
            }
            XCTAssertEqual(vectorStore.count, 10)
        })
    }
    
    func testVectorStoreSearch() {
        let dimension = 512
        let metric = DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            
            // Add known vectors for predictable search results
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            let vector3 = Array(repeating: Float(0.25), count: dimension)
            
            try vectorStore.addVector(vector1, id: 1)
            try vectorStore.addVector(vector2, id: 2)
            try vectorStore.addVector(vector3, id: 3)
            
            // Search for the most similar vector
            let queryVector = Array(repeating: Float(0.6), count: dimension)
            let results = try vectorStore.search(queryVector, k: 2)
            
            // With cosine similarity, vector2 (0.5) should be closer to 0.6 than vector1 (1.0) or vector3 (0.25)
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].id, 2) // Most similar
            XCTAssertEqual(results[1].id, 1) // Second most similar
        })
    }
    
    func testVectorStoreClear() {
        let dimension = 256
        let metric = DistanceMetric.dot
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            
            // Add some vectors
            for i in 1...5 {
                let vector = Array(repeating: Float(i), count: dimension)
                try vectorStore.addVector(vector, id: i)
            }
            XCTAssertEqual(vectorStore.count, 5)
            
            // Clear the store
            try vectorStore.clear()
            XCTAssertEqual(vectorStore.count, 0)
            
            // Verify we can still use the cleared store
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(vector, id: 1)
            XCTAssertEqual(vectorStore.count, 1)
        })
    }
    
    func testHNSWIndexCreation() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric, m: 16, efConstruction: 200)
                    XCTAssertEqual(hnswIndex.count, 0)
                }, "Failed to create HNSWIndex with dimension dimension) and metric metric)")
            }
        }
    }
    
    func testHNSWIndexAddVector() {
        let dimension = 768
        let metric = DistanceMetric.l2
        
        XCTAssertNoThrow({
            let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric)
            
            // Test adding a single vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try hnswIndex.addVector(vector, id: 1)
            XCTAssertEqual(hnswIndex.count, 1)
            
            // Test adding multiple vectors (simulating embedding vectors)
            for i in 2...20 {
                let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
                try hnswIndex.addVector(vector, id: i)
            }
            XCTAssertEqual(hnswIndex.count, 20)
        })
    }
    
    func testHNSWIndexSearch() {
        let dimension = 1024
        let metric = DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric, m: 16, efConstruction: 100)
            
            // Add known vectors for predictable search results
            let baseVector = Array(repeating: Float(0.5), count: dimension)
            let similarVector = Array(repeating: Float(0.6), count: dimension)
            let dissimilarVector = Array(repeating: Float(-0.5), count: dimension)
            
            try hnswIndex.addVector(baseVector, id: 1)
            try hnswIndex.addVector(similarVector, id: 2)
            try hnswIndex.addVector(dissimilarVector, id: 3)
            
            // Add some random vectors to make the search more realistic
            for i in 4...10 {
                let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
                try hnswIndex.addVector(vector, id: i)
            }
            
            // Search with different efSearch values
            let queryVector = Array(repeating: Float(0.55), count: dimension)
            
            // Search with default efSearch
            let results1 = try hnswIndex.search(queryVector, k: 3)
            XCTAssertEqual(results1.count, 3)
            
            // Search with custom efSearch
            let results2 = try hnswIndex.search(queryVector, k: 3, efSearch: 100)
            XCTAssertEqual(results2.count, 3)
            
            // Both searches should return vector 2 (similarVector) as one of the results
            XCTAssertTrue(results1.contains { $0.id == 2 })
            XCTAssertTrue(results2.contains { $0.id == 2 })
        })
    }
    
    func testHNSWIndexClear() {
        let dimension = 384
        let metric = DistanceMetric.l2
        
        XCTAssertNoThrow({
            let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric)
            
            // Add some vectors
            for i in 1...10 {
                let vector = Array(repeating: Float(i) / 10.0, count: dimension)
                try hnswIndex.addVector(vector, id: i)
            }
            XCTAssertEqual(hnswIndex.count, 10)
            
            // Clear the index
            try hnswIndex.clear()
            XCTAssertEqual(hnswIndex.count, 0)
            
            // Verify we can still use the cleared index
            let vector = Array(repeating: Float(0.7), count: dimension)
            try hnswIndex.addVector(vector, id: 1)
            XCTAssertEqual(hnswIndex.count, 1)
        })
    }
    
    func testDistanceMetrics() {
        let dimension = 128
        
        // Test L2 distance
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: .l2)
            try vectorStore.addVector(Array(repeating: Float(1.0), count: dimension), id: 1)
        })
        
        // Test Cosine distance
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: .cosine)
            try vectorStore.addVector(Array(repeating: Float(1.0), count: dimension), id: 1)
        })
        
        // Test Dot product distance
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: .dot)
            try vectorStore.addVector(Array(repeating: Float(1.0), count: dimension), id: 1)
        })
    }
    
    func testLargeDimensions() {
        // Test with 3072 dimension (common for large models like Claude)
        let dimension = 3072
        let metric = DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            
            // Add a large dimension vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(vector, id: 1)
            XCTAssertEqual(vectorStore.count, 1)
            
            // Search with the same vector should return itself as the closest
            let results = try vectorStore.search(vector, k: 1)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].id, 1)
            XCTAssertEqual(results[0].distance, 0.0, accuracy: 0.001)
        })
    }
    
    func testEdgeCases() {
        let dimension = 16
        let metric = DistanceMetric.l2
        
        // Test adding vectors with different IDs
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            // Add vectors with positive IDs
            try vectorStore.addVector(vector, id: 1)
            try vectorStore.addVector(vector, id: 1000)
            
            // Add vectors with negative IDs
            try vectorStore.addVector(vector, id: -1)
            try vectorStore.addVector(vector, id: -1000)
            
            XCTAssertEqual(vectorStore.count, 4)
        })
        
        // Test searching with k larger than the number of vectors
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            try vectorStore.addVector(vector, id: 1)
            try vectorStore.addVector(vector, id: 2)
            
            // Search for 5 results when only 2 exist
            let results = try vectorStore.search(vector, k: 5)
            XCTAssertEqual(results.count, 2)
        })
    }
    
    func testVectorStoreRemove() {
        let dimension = 32
        let metric = DistanceMetric.l2
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(2.0), count: dimension)
            
            // Add vectors
            try vectorStore.addVector(vector1, id: 1)
            try vectorStore.addVector(vector2, id: 2)
            XCTAssertEqual(vectorStore.count, 2)
            
            // Remove a vector that exists
            let removed1 = try vectorStore.remove(id: 1)
            XCTAssertTrue(removed1)
            XCTAssertEqual(vectorStore.count, 1)
            
            // Remove a vector that doesn't exist
            let removed2 = try vectorStore.remove(id: 3)
            XCTAssertFalse(removed2)
            XCTAssertEqual(vectorStore.count, 1)
            
            // Verify the remaining vector
            let results = try vectorStore.search(vector2, k: 1)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].id, 2)
        })
    }
    
    func testVectorStoreGet() {
        let dimension = 64
        let metric = DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            
            // Add vectors
            try vectorStore.addVector(vector1, id: 1)
            try vectorStore.addVector(vector2, id: 2)
            
            // Get existing vectors
            let retrieved1 = try vectorStore.get(id: 1)
            XCTAssertNotNil(retrieved1)
            XCTAssertEqual(retrieved1, vector1)
            
            let retrieved2 = try vectorStore.get(id: 2)
            XCTAssertNotNil(retrieved2)
            XCTAssertEqual(retrieved2, vector2)
            
            // Get non-existent vector
            let retrieved3 = try vectorStore.get(id: 3)
            XCTAssertNil(retrieved3)
        })
    }
    
    func testVectorStoreUpdate() {
        let dimension = 128
        let metric = DistanceMetric.dot
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            let initialVector = Array(repeating: Float(0.5), count: dimension)
            let updatedVector = Array(repeating: Float(0.8), count: dimension)
            
            // Add a vector
            try vectorStore.addVector(initialVector, id: 1)
            XCTAssertEqual(vectorStore.count, 1)
            
            // Update the vector
            let updated = try vectorStore.update(id: 1, vector: updatedVector)
            XCTAssertTrue(updated)
            XCTAssertEqual(vectorStore.count, 1)
            
            // Verify the update
            let retrieved = try vectorStore.get(id: 1)
            XCTAssertNotNil(retrieved)
            XCTAssertEqual(retrieved, updatedVector)
            
            // Update a non-existent vector
            XCTAssertThrowsError({
                try vectorStore.update(id: 2, vector: updatedVector)
            })
        })
    }
    
    func testVectorStoreDimensionMetric() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let vectorStore = try VectorStore(dimension: dimension, metric: metric)
                    
                    // Verify dimension and metric
                    XCTAssertEqual(vectorStore.dimension, dimension)
                    XCTAssertEqual(vectorStore.metric, metric)
                }, "Failed for dimension dimension) and metric metric)")
            }
        }
    }
    
    func testVectorStoreContains() {
        let dimension = 256
        let metric = DistanceMetric.l2
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            // Add a vector
            try vectorStore.addVector(vector, id: 1)
            
            // Check if vector exists
            XCTAssertTrue(try vectorStore.contains(id: 1))
            XCTAssertFalse(try vectorStore.contains(id: 2))
            
            // Remove the vector and check again
            try vectorStore.remove(id: 1)
            XCTAssertFalse(try vectorStore.contains(id: 1))
        })
    }
    
    func testVectorStoreReserve() {
        let dimension = 512
        let metric = DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let vectorStore = try VectorStore(dimension: dimension, metric: metric)
            
            // Test reserve
            try vectorStore.reserve(capacity: 1000)
            
            // Verify we can add vectors up to the reserved capacity
            for i in 1...100 {
                let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
                try vectorStore.addVector(vector, id: i)
            }
            XCTAssertEqual(vectorStore.count, 100)
        })
    }
    
    func testHNSWIndexSetGetEfSearch() {
        let dimension = 128
        let metric = DistanceMetric.l2
        
        XCTAssertNoThrow({
            let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric)
            
            // Test default efSearch
            let defaultEfSearch = try hnswIndex.getEfSearch()
            XCTAssertEqual(defaultEfSearch, 200) // Default value from the implementation
            
            // Set and verify new efSearch values
            let testValues = [10, 50, 100, 200, 500]
            for efValue in testValues {
                try hnswIndex.setEfSearch(efValue)
                let retrieved = try hnswIndex.getEfSearch()
                XCTAssertEqual(retrieved, efValue)
            }
        })
    }
    
    func testHNSWIndexDimensionCapacity() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric)
                    
                    // Verify dimension
                    XCTAssertEqual(hnswIndex.dimension, dimension)
                    
                    // Verify capacity is set to a reasonable default
                    XCTAssertGreaterThan(hnswIndex.capacity, 0)
                    XCTAssertGreaterThanOrEqual(hnswIndex.capacity, dimension * 1000) // As set in init
                }, "Failed for dimension dimension) and metric metric)")
            }
        }
    }
    
    func testHNSWIndexContains() {
        let dimension = 256
        let metric = DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            // Add a vector
            try hnswIndex.addVector(vector, id: 1)
            
            // Check if vector exists
            XCTAssertTrue(try hnswIndex.contains(id: 1))
            XCTAssertFalse(try hnswIndex.contains(id: 2))
            
            // Add more vectors and check
            try hnswIndex.addVector(vector, id: 2)
            try hnswIndex.addVector(vector, id: 3)
            
            XCTAssertTrue(try hnswIndex.contains(id: 2))
            XCTAssertTrue(try hnswIndex.contains(id: 3))
        })
    }
    
    func testHNSWIndexGetVector() {
        let dimension = 512
        let metric = DistanceMetric.dot
        
        XCTAssertNoThrow({
            let hnswIndex = try HNSWIndex(dimension: dimension, metric: metric)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            
            // Add vectors
            try hnswIndex.addVector(vector1, id: 1)
            try hnswIndex.addVector(vector2, id: 2)
            
            // Get existing vectors
            let retrieved1 = try hnswIndex.getVector(id: 1)
            XCTAssertNotNil(retrieved1)
            XCTAssertEqual(retrieved1, vector1)
            
            let retrieved2 = try hnswIndex.getVector(id: 2)
            XCTAssertNotNil(retrieved2)
            XCTAssertEqual(retrieved2, vector2)
            
            // Get non-existent vector
            let retrieved3 = try hnswIndex.getVector(id: 3)
            XCTAssertNil(retrieved3)
        })
    }
    
    func testHNSWIndexSaveLoad() {
        let dimension = 64
        let metric = DistanceMetric.l2
        
        // Create a temporary file path
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appending("test_hnsw_index.bin")
        
        // Clean up any existing file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        XCTAssertNoThrow({
            // Create and populate an index
            let hnswIndex1 = try HNSWIndex(dimension: dimension, metric: metric)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            let vector3 = Array(repeating: Float(0.25), count: dimension)
            
            try hnswIndex1.addVector(vector1, id: 1)
            try hnswIndex1.addVector(vector2, id: 2)
            try hnswIndex1.addVector(vector3, id: 3)
            
            // Set a custom efSearch value
            try hnswIndex1.setEfSearch(100)
            
            // Save the index
            let saved = try hnswIndex1.save(filename: tempFile)
            XCTAssertTrue(saved)
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile))
            
            // Load the index
            let hnswIndex2 = try HNSWIndex.load(filename: tempFile)
            
            // Verify the loaded index has the same properties
            XCTAssertEqual(hnswIndex2.dimension, dimension)
            XCTAssertEqual(hnswIndex2.count, 3)
            
            // Verify the efSearch value was preserved
            let loadedEfSearch = try hnswIndex2.getEfSearch()
            XCTAssertEqual(loadedEfSearch, 100)
            
            // Verify vectors are present and correct
            XCTAssertTrue(try hnswIndex2.contains(id: 1))
            XCTAssertTrue(try hnswIndex2.contains(id: 2))
            XCTAssertTrue(try hnswIndex2.contains(id: 3))
            
            let retrieved1 = try hnswIndex2.getVector(id: 1)
            XCTAssertNotNil(retrieved1)
            XCTAssertEqual(retrieved1, vector1)
            
            // Verify search works correctly
            let results = try hnswIndex2.search(vector1, k: 2)
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].id, 1)
            XCTAssertEqual(results[1].id, 2)
        })
        
        // Clean up the temporary file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
    }
}
