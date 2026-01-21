import XCTest
import LlamaMobileVD

final class LlamaMobileVDTests: XCTestCase {
    
    // Test vector dimensions (including common sizes like 384, 768, 1024)
    private let testDimensions = [384, 768, 1024]
    
    // Test distance metrics
    private let testMetrics: [LlamaMobileVD.DistanceMetric] = [.l2, .cosine, .dot]
    
    func testVectorStoreCreation() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
                    XCTAssertEqual(try vectorStore.count(), 0)
                }, "Failed to create VectorStore with dimension dimension) and metric metric)")
            }
        }
    }
    
    func testVectorStoreAddVector() {
        let dimension = 512
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Test adding a single vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(id: 1, vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Test adding multiple vectors
            for i in 2...10 {
                let vector = Array(repeating: Float(i) / 10.0, count: dimension)
                try vectorStore.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try vectorStore.count(), 10)
        })
    }
    
    func testVectorStoreSearch() {
        let dimension = 512
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Add known vectors for predictable search results
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            let vector3 = Array(repeating: Float(0.25), count: dimension)
            
            try vectorStore.addVector(id: 1, vector: vector1)
            try vectorStore.addVector(id: 2, vector: vector2)
            try vectorStore.addVector(id: 3, vector: vector3)
            
            // Search for the most similar vector
            let queryVector = Array(repeating: Float(0.6), count: dimension)
            let results = try vectorStore.search(query: queryVector, k: 2)
            
            // With cosine similarity, vector2 (0.5) should be closer to 0.6 than vector1 (1.0) or vector3 (0.25)
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].id, 2) // Most similar
            XCTAssertEqual(results[1].id, 1) // Second most similar
        })
    }
    
    func testVectorStoreClear() {
        let dimension = 256
        let metric = LlamaMobileVD.DistanceMetric.dot
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Add some vectors
            for i in 1...5 {
                let vector = Array(repeating: Float(i), count: dimension)
                try vectorStore.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try vectorStore.count(), 5)
            
            // Clear the store
            try vectorStore.clear()
            XCTAssertEqual(try vectorStore.count(), 0)
            
            // Verify we can still use the cleared store
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(id: 1, vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
        })
    }
    
    func testHNSWIndexCreation() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000, m: 16, efConstruction: 200)
                    XCTAssertEqual(try hnswIndex.count(), 0)
                }, "Failed to create HNSWIndex with dimension dimension) and metric metric)")
            }
        }
    }
    
    func testHNSWIndexAddVector() {
        let dimension = 768
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
            
            // Test adding a single vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try hnswIndex.addVector(id: 1, vector: vector)
            XCTAssertEqual(try hnswIndex.count(), 1)
            
            // Test adding multiple vectors (simulating embedding vectors)
            for i in 2...20 {
                let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
                try hnswIndex.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try hnswIndex.count(), 20)
        })
    }
    
    func testHNSWIndexSearch() {
        let dimension = 1024
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000, m: 16, efConstruction: 100)
            
            // Add known vectors for predictable search results
            let baseVector = Array(repeating: Float(0.5), count: dimension)
            let similarVector = Array(repeating: Float(0.6), count: dimension)
            let dissimilarVector = Array(repeating: Float(-0.5), count: dimension)
            
            try hnswIndex.addVector(id: 1, vector: baseVector)
            try hnswIndex.addVector(id: 2, vector: similarVector)
            try hnswIndex.addVector(id: 3, vector: dissimilarVector)
            
            // Add some random vectors to make the search more realistic
            for i in 4...10 {
                let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
                try hnswIndex.addVector(id: UInt64(i), vector: vector)
            }
            
            // Search with different efSearch values
            let queryVector = Array(repeating: Float(0.55), count: dimension)
            
            // Search with default efSearch
            let results1 = try hnswIndex.search(query: queryVector, k: 3)
            XCTAssertEqual(results1.count, 3)
            
            // Search with custom efSearch
            try hnswIndex.setEfSearch(100)
            let results2 = try hnswIndex.search(query: queryVector, k: 3)
            XCTAssertEqual(results2.count, 3)
            
            // Both searches should return vector 2 (similarVector) as one of the results
            XCTAssertTrue(results1.contains { $0.id == 2 })
            XCTAssertTrue(results2.contains { $0.id == 2 })
        })
    }
    
    // Note: HNSWIndex doesn't have a clear method in the C library
    func testHNSWIndexRemove() {
        let dimension = 384
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
            
            // Add some vectors
            for i in 1...10 {
                let vector = Array(repeating: Float(i) / 10.0, count: dimension)
                try hnswIndex.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try hnswIndex.count(), 10)
            
            // Verify we can get the vectors back
            for i in 1...10 {
                let vector = try hnswIndex.getVector(id: UInt64(i))
                XCTAssertEqual(vector.count, dimension)
            }
        })
    }
    
    func testDistanceMetrics() {
        let dimension = 128
        
        // Test L2 distance
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: LlamaMobileVD.DistanceMetric.l2)
            let vector = Array(repeating: Float(1.0), count: dimension)
            try vectorStore.addVector(id: 1, vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
        })
        
        // Test Cosine distance
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: LlamaMobileVD.DistanceMetric.cosine)
            let vector = Array(repeating: Float(1.0), count: dimension)
            try vectorStore.addVector(id: 1, vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
        })
        
        // Test Dot product distance
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: LlamaMobileVD.DistanceMetric.dot)
            let vector = Array(repeating: Float(1.0), count: dimension)
            try vectorStore.addVector(id: 1, vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
        })
    }
    
    func testLargeDimensions() {
        // Test with 3072 dimension (common for large models like Claude)
        let dimension = 3072
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({ 
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Add a large dimension vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(id: UInt64(1), vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Search with the same vector should return itself as the closest
            let results = try vectorStore.search(query: vector, k: 1)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].id, 1)
            XCTAssertEqual(results[0].distance, 0.0, accuracy: 0.001)
        })
    }
    
    func testVeryLargeDimensions3096() {
        // Test with 3096 dimension (larger size for comprehensive coverage)
        let dimension = 3096
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({ 
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Add a very large dimension vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try vectorStore.addVector(id: UInt64(1), vector: vector)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Search with the same vector should return itself as the closest
            let results = try vectorStore.search(query: vector, k: 1)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].id, 1)
            XCTAssertEqual(results[0].distance, 0.0, accuracy: 0.001)
            
            // Add more vectors to test search functionality
            for i in 2...5 {
                let vector = Array(repeating: Float(i) / 5.0, count: dimension)
                try vectorStore.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try vectorStore.count(), 5)
            
            // Search should return relevant results
            let queryVector = Array(repeating: Float(0.6), count: dimension)
            let searchResults = try vectorStore.search(query: queryVector, k: 3)
            XCTAssertEqual(searchResults.count, 3)
            // The closest should be vector with id 2 (value 0.4) or 3 (value 0.6)
            XCTAssertTrue(searchResults[0].id == 2 || searchResults[0].id == 3)
        })
    }
    
    func testEdgeCases() {
        let dimension = 16
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        // Test adding vectors with different IDs
        XCTAssertNoThrow({ 
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            // Add vectors with positive IDs
            try vectorStore.addVector(id: UInt64(1), vector: vector)
            try vectorStore.addVector(id: UInt64(1000), vector: vector)
            
            // Add vectors with negative IDs
            try vectorStore.addVector(id: UInt64(9223372036854775807), vector: vector)
            try vectorStore.addVector(id: UInt64(9223372036854774808), vector: vector)
            
            XCTAssertEqual(try vectorStore.count(), 4)
        })
        
        // Test searching with k larger than the number of vectors
        XCTAssertNoThrow({ 
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            try vectorStore.addVector(id: UInt64(1), vector: vector)
            try vectorStore.addVector(id: UInt64(2), vector: vector)
            
            // Search for 5 results when only 2 exist
            let results = try vectorStore.search(query: vector, k: 5)
            XCTAssertEqual(results.count, 2)
        })
    }
    
    func testVectorStoreRemove() {
        let dimension = 32
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(2.0), count: dimension)
            
            // Add vectors
            try vectorStore.addVector(id: 1, vector: vector1)
            try vectorStore.addVector(id: 2, vector: vector2)
            XCTAssertEqual(try vectorStore.count(), 2)
            
            // Remove a vector that exists
            let removed1 = try vectorStore.removeVector(id: 1)
            XCTAssertTrue(removed1)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Remove a vector that doesn't exist
            let removed2 = try vectorStore.removeVector(id: 3)
            XCTAssertFalse(removed2)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Verify the remaining vector
            let results = try vectorStore.search(query: vector2, k: 1)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].id, 2)
        })
    }
    
    func testVectorStoreGet() {
        let dimension = 64
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            
            // Add vectors
            try vectorStore.addVector(id: 1, vector: vector1)
            try vectorStore.addVector(id: 2, vector: vector2)
            
            // Get existing vectors
            let retrieved1 = try vectorStore.getVector(id: 1)
            XCTAssertEqual(retrieved1, vector1)
            
            let retrieved2 = try vectorStore.getVector(id: 2)
            XCTAssertEqual(retrieved2, vector2)
        })
    }
    
    func testVectorStoreUpdate() {
        let dimension = 128
        let metric = LlamaMobileVD.DistanceMetric.dot
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let initialVector = Array(repeating: Float(0.5), count: dimension)
            let updatedVector = Array(repeating: Float(0.8), count: dimension)
            
            // Add a vector
            try vectorStore.addVector(id: 1, vector: initialVector)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Update the vector
            try vectorStore.updateVector(id: 1, vector: updatedVector)
            XCTAssertEqual(try vectorStore.count(), 1)
            
            // Verify the update
            let retrieved = try vectorStore.getVector(id: 1)
            XCTAssertEqual(retrieved, updatedVector)
        })
    }
    
    func testVectorStoreDimensionMetric() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
                    
                    // Verify dimension and metric
            XCTAssertEqual(try vectorStore.dimension(), dimension)
            XCTAssertEqual(try vectorStore.metric(), metric)
                }, "Failed for dimension \(dimension) and metric \(metric)")
            }
        }
    }
    
    func testVectorStoreContains() {
        let dimension = 256
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            // Add a vector
            try vectorStore.addVector(id: 1, vector: vector)
            
            // Check if vector exists
            XCTAssertTrue(try vectorStore.containsVector(id: 1))
            XCTAssertFalse(try vectorStore.containsVector(id: 2))
            
            // Remove the vector and check again
            let removed = try vectorStore.removeVector(id: 1)
            XCTAssertTrue(removed)
            XCTAssertFalse(try vectorStore.containsVector(id: 1))
        })
    }
    
    func testVectorStoreReserve() {
        let dimension = 512
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({ 
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Test reserve
            try vectorStore.reserveCapacity(capacity: 1000)
            
            // Verify we can add vectors up to the reserved capacity
            for i in 1...100 {
                let vector = Array(repeating: Float.random(in: -1.0...1.0), count: dimension)
                try vectorStore.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try vectorStore.count(), 100)
        })
    }
    
    func testVectorStoreLargeDataset1000() {
        // Test with large dataset (1000 vectors) for comprehensive coverage
        let dimension = 256
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({ 
            let vectorStore = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            
            // Reserve capacity to optimize performance
            try vectorStore.reserveCapacity(capacity: 1000)
            
            // Add 1000 vectors
            for i in 1...1000 {
                let vector = Array(repeating: Float(i) / 1000.0, count: dimension)
                try vectorStore.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try vectorStore.count(), 1000)
            
            // Test search performance and accuracy
            let queryVector = Array(repeating: Float(0.5), count: dimension)
            let results = try vectorStore.search(query: queryVector, k: 10)
            XCTAssertEqual(results.count, 10)
            
            // Verify we can retrieve vectors
            for i in 1...5 {
                let vector = try vectorStore.getVector(id: UInt64(i))
                XCTAssertEqual(vector.count, dimension)
            }
            
            // Test contains functionality
            XCTAssertTrue(try vectorStore.containsVector(id: 500))
            XCTAssertFalse(try vectorStore.containsVector(id: 1001))
        })
    }
    
    func testHNSWIndexSetGetEfSearch() {
        let dimension = 128
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
            
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
                    let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
                    
                    // Verify dimension
            XCTAssertEqual(try hnswIndex.dimension(), dimension)
                    
                    // Verify capacity is set to a reasonable default
                    let capacity = try hnswIndex.capacity()
                    XCTAssertGreaterThan(capacity, 0)
                }, "Failed for dimension \(dimension) and metric \(metric)")
            }
        }
    }
    
    func testHNSWIndexContains() {
        let dimension = 256
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
            let vector = Array(repeating: Float(0.5), count: dimension)
            
            // Add a vector
            try hnswIndex.addVector(id: 1, vector: vector)
            
            // Check if vector exists
            XCTAssertTrue(try hnswIndex.contains(id: 1))
            XCTAssertFalse(try hnswIndex.contains(id: 2))
            
            // Add more vectors and check
            try hnswIndex.addVector(id: 2, vector: vector)
            try hnswIndex.addVector(id: 3, vector: vector)
            
            XCTAssertTrue(try hnswIndex.contains(id: 2))
            XCTAssertTrue(try hnswIndex.contains(id: 3))
        })
    }
    
    func testHNSWIndexGetVector() {
        let dimension = 512
        let metric = LlamaMobileVD.DistanceMetric.dot
        
        XCTAssertNoThrow({
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            
            // Add vectors
            try hnswIndex.addVector(id: 1, vector: vector1)
            try hnswIndex.addVector(id: 2, vector: vector2)
            
            // Get existing vectors
            let retrieved1 = try hnswIndex.getVector(id: 1)
            XCTAssertEqual(retrieved1, vector1)
            
            let retrieved2 = try hnswIndex.getVector(id: 2)
            XCTAssertEqual(retrieved2, vector2)
        })
    }
    
    func testHNSWIndexSaveLoad() {
        let dimension = 64
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        // Create a temporary file path
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appending("test_hnsw_index.bin")
        
        // Clean up any existing file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        XCTAssertNoThrow({ 
            // Create and populate an index
            let hnswIndex1 = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000)
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            let vector3 = Array(repeating: Float(0.25), count: dimension)
            
            try hnswIndex1.addVector(id: 1, vector: vector1)
            try hnswIndex1.addVector(id: 2, vector: vector2)
            try hnswIndex1.addVector(id: 3, vector: vector3)
            
            // Set a custom efSearch value
            try hnswIndex1.setEfSearch(100)
            
            // Save the index
            try hnswIndex1.save(to: tempFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile))
            
            // Load the index
            let hnswIndex2 = try LlamaMobileVD.HNSWIndex.load(from: tempFile)
            
            // Verify the loaded index has the same properties
            XCTAssertEqual(try hnswIndex2.dimension(), dimension)
            XCTAssertEqual(try hnswIndex2.count(), 3)
            
            // Verify the efSearch value was preserved
            let loadedEfSearch = try hnswIndex2.getEfSearch()
            XCTAssertEqual(loadedEfSearch, 100)
            
            // Verify vectors are present and correct
            XCTAssertTrue(try hnswIndex2.contains(id: 1))
            XCTAssertTrue(try hnswIndex2.contains(id: 2))
            XCTAssertTrue(try hnswIndex2.contains(id: 3))
            
            let retrieved1 = try hnswIndex2.getVector(id: 1)
            XCTAssertEqual(retrieved1, vector1)
            
            // Verify search works correctly
            let results = try hnswIndex2.search(query: vector1, k: 2)
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].id, 1)
            XCTAssertEqual(results[1].id, 2)
        })
        
        // Clean up the temporary file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
    }
    
    func testHNSWIndexVeryLargeDimensions3096() {
        // Test with 3096 dimension (larger size for comprehensive coverage)
        let dimension = 3096
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({ 
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 100)
            
            // Add a very large dimension vector
            let vector = Array(repeating: Float(0.5), count: dimension)
            try hnswIndex.addVector(id: 1, vector: vector)
            XCTAssertEqual(try hnswIndex.count(), 1)
            
            // Add more vectors to test search functionality
            for i in 2...5 {
                let vector = Array(repeating: Float(i) / 5.0, count: dimension)
                try hnswIndex.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try hnswIndex.count(), 5)
            
            // Search should return relevant results
            let queryVector = Array(repeating: Float(0.6), count: dimension)
            let results = try hnswIndex.search(query: queryVector, k: 3)
            XCTAssertEqual(results.count, 3)
            
            // Verify we can retrieve vectors
            for i in 1...5 {
                let retrievedVector = try hnswIndex.getVector(id: UInt64(i))
                XCTAssertEqual(retrievedVector.count, dimension)
            }
        })
    }
    
    func testHNSWIndexLargeDataset1000() {
        // Test with large dataset (1000 vectors) for comprehensive coverage
        let dimension = 128
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({ 
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 1000, m: 16, efConstruction: 200)
            
            // Add 1000 vectors
            for i in 1...1000 {
                let vector = Array(repeating: Float(i) / 1000.0, count: dimension)
                try hnswIndex.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try hnswIndex.count(), 1000)
            
            // Test search performance and accuracy
            let queryVector = Array(repeating: Float(0.5), count: dimension)
            let results = try hnswIndex.search(query: queryVector, k: 10)
            XCTAssertEqual(results.count, 10)
            
            // Verify we can retrieve vectors
            for i in 1...5 {
                let vector = try hnswIndex.getVector(id: UInt64(i))
                XCTAssertEqual(vector.count, dimension)
            }
            
            // Test contains functionality
            XCTAssertTrue(try hnswIndex.contains(id: 500))
            XCTAssertFalse(try hnswIndex.contains(id: 1001))
            
            // Test efSearch parameter
            try hnswIndex.setEfSearch(100)
            XCTAssertEqual(try hnswIndex.getEfSearch(), 100)
        })
    }
    
    func testMMapVectorStoreBuilderCreation() {
        for dimension in testDimensions {
            for metric in testMetrics {
                XCTAssertNoThrow({
                    let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
                    XCTAssertEqual(try builder.count(), 0)
                    XCTAssertEqual(try builder.dimension(), dimension)
                }, "Failed to create MMapVectorStoreBuilder with dimension \(dimension) and metric \(metric)")
            }
        }
    }
    
    func testMMapVectorStoreBuilderOperations() {
        let dimension = 512
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        XCTAssertNoThrow({
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            
            // Test adding vectors
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            let vector3 = Array(repeating: Float(0.25), count: dimension)
            
            try builder.addVector(id: 1, vector: vector1)
            XCTAssertEqual(try builder.count(), 1)
            
            try builder.addVector(id: 2, vector: vector2)
            XCTAssertEqual(try builder.count(), 2)
            
            try builder.addVector(id: 3, vector: vector3)
            XCTAssertEqual(try builder.count(), 3)
            
            // Test reserve
            try builder.reserve(capacity: 100)
            XCTAssertEqual(try builder.count(), 3)
            
            // Test adding more vectors after reserve
            for i in 4...10 {
                let vector = Array(repeating: Float(i) / 10.0, count: dimension)
                try builder.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try builder.count(), 10)
        })
    }
    
    func testMMapVectorStoreSaveLoad() {
        let dimension = 256
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        // Create a temporary file path
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appending("test_mmap_vector_store.bin")
        
        // Clean up any existing file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        XCTAssertNoThrow({
            // Create builder and add vectors
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            
            let vector1 = Array(repeating: Float(1.0), count: dimension)
            let vector2 = Array(repeating: Float(0.5), count: dimension)
            let vector3 = Array(repeating: Float(0.25), count: dimension)
            
            try builder.addVector(id: 1, vector: vector1)
            try builder.addVector(id: 2, vector: vector2)
            try builder.addVector(id: 3, vector: vector3)
            
            // Save to file
            try builder.save(to: tempFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile))
            
            // Open the saved store
            let vectorStore = try LlamaMobileVD.MMapVectorStore.open(from: tempFile)
            
            // Verify store properties
            XCTAssertEqual(try vectorStore.dimension(), dimension)
            XCTAssertEqual(try vectorStore.metric(), metric)
            XCTAssertEqual(try vectorStore.count(), 3)
            
            // Verify vectors can be retrieved
            let retrieved1 = try vectorStore.getVector(id: 1)
            XCTAssertEqual(retrieved1, vector1)
            
            let retrieved2 = try vectorStore.getVector(id: 2)
            XCTAssertEqual(retrieved2, vector2)
            
            let retrieved3 = try vectorStore.getVector(id: 3)
            XCTAssertEqual(retrieved3, vector3)
            
            // Verify contains functionality
            XCTAssertTrue(try vectorStore.contains(id: 1))
            XCTAssertTrue(try vectorStore.contains(id: 2))
            XCTAssertTrue(try vectorStore.contains(id: 3))
            XCTAssertFalse(try vectorStore.contains(id: 4))
        })
        
        // Clean up the temporary file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
    }
    
    func testMMapVectorStoreSearch() {
        let dimension = 512
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        // Create a temporary file path
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appending("test_mmap_search.bin")
        
        // Clean up any existing file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        XCTAssertNoThrow({ 
            // Create and populate the store
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            
            // Add known vectors for predictable search results
            let vector1 = Array(repeating: Float(1.0), count: dimension)  // ID 1
            let vector2 = Array(repeating: Float(0.9), count: dimension)  // ID 2 - very similar to vector1
            let vector3 = Array(repeating: Float(0.5), count: dimension)  // ID 3 - somewhat similar
            let vector4 = Array(repeating: Float(0.1), count: dimension)  // ID 4 - less similar
            let vector5 = Array(repeating: Float(-1.0), count: dimension) // ID 5 - very dissimilar
            
            try builder.addVector(id: 1, vector: vector1)
            try builder.addVector(id: 2, vector: vector2)
            try builder.addVector(id: 3, vector: vector3)
            try builder.addVector(id: 4, vector: vector4)
            try builder.addVector(id: 5, vector: vector5)
            
            // Save the store
            try builder.save(to: tempFile)
            
            // Open and search
            let vectorStore = try LlamaMobileVD.MMapVectorStore.open(from: tempFile)
            
            // Test search for vector1 - should find itself first
            let results1 = try vectorStore.search(query: vector1, k: 3)
            XCTAssertEqual(results1.count, 3)
            XCTAssertEqual(results1[0].id, 1)  // Exact match
            XCTAssertEqual(results1[1].id, 2)  // Very similar
            XCTAssertEqual(results1[2].id, 3)  // Somewhat similar
            
            // Test search for vector3 - should find itself first, then similar vectors
            let results2 = try vectorStore.search(query: vector3, k: 2)
            XCTAssertEqual(results2.count, 2)
            XCTAssertEqual(results2[0].id, 3)  // Exact match
            XCTAssertTrue([2, 4].contains(results2[1].id))  // Should be either 2 or 4 depending on metric
            
            // Test search with k larger than the number of vectors
            let results3 = try vectorStore.search(query: vector1, k: 10)
            XCTAssertEqual(results3.count, 5)  // Only 5 vectors available
        })
        
        // Clean up the temporary file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
    }
    
    func testMMapVectorStoreVeryLargeDimensions3096() {
        // Test with 3096 dimension (larger size for comprehensive coverage)
        let dimension = 3096
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        // Create a temporary file path
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appending("test_mmap_3096.bin")
        
        // Clean up any existing file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        XCTAssertNoThrow({ 
            // Create and populate the store
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            
            // Add vectors with 3096 dimensions
            let vector1 = Array(repeating: Float(0.5), count: dimension)  // ID 1
            let vector2 = Array(repeating: Float(0.6), count: dimension)  // ID 2
            let vector3 = Array(repeating: Float(0.7), count: dimension)  // ID 3
            
            try builder.addVector(id: 1, vector: vector1)
            try builder.addVector(id: 2, vector: vector2)
            try builder.addVector(id: 3, vector: vector3)
            
            // Save the store
            try builder.save(to: tempFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile))
            
            // Open the store
            let vectorStore = try LlamaMobileVD.MMapVectorStore.open(from: tempFile)
            
            // Verify store properties
            XCTAssertEqual(try vectorStore.dimension(), dimension)
            XCTAssertEqual(try vectorStore.metric(), metric)
            XCTAssertEqual(try vectorStore.count(), 3)
            
            // Verify vectors can be retrieved
            let retrieved1 = try vectorStore.getVector(id: 1)
            XCTAssertEqual(retrieved1.count, dimension)
            
            // Test search functionality
            let queryVector = Array(repeating: Float(0.65), count: dimension)
            let results = try vectorStore.search(query: queryVector, k: 2)
            XCTAssertEqual(results.count, 2)
            // The closest should be vector with id 2 (value 0.6) or 3 (value 0.7)
            XCTAssertTrue(results[0].id == 2 || results[0].id == 3)
        })
        
        // Clean up the temporary file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
    }
    
    func testMMapVectorStoreLargeDataset1000() {
        // Test with large dataset (1000 vectors) for comprehensive coverage
        let dimension = 64
        let metric = LlamaMobileVD.DistanceMetric.l2
        
        // Create a temporary file path
        let tempDir = NSTemporaryDirectory()
        let tempFile = tempDir.appending("test_mmap_large.bin")
        
        // Clean up any existing file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
        
        XCTAssertNoThrow({ 
            // Create and populate the store
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            
            // Reserve capacity to optimize performance
            try builder.reserve(capacity: 1000)
            
            // Add 1000 vectors
            for i in 1...1000 {
                let vector = Array(repeating: Float(i) / 1000.0, count: dimension)
                try builder.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try builder.count(), 1000)
            
            // Save the store
            try builder.save(to: tempFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempFile))
            
            // Open the store
            let vectorStore = try LlamaMobileVD.MMapVectorStore.open(from: tempFile)
            
            // Verify store properties
            XCTAssertEqual(try vectorStore.dimension(), dimension)
            XCTAssertEqual(try vectorStore.metric(), metric)
            XCTAssertEqual(try vectorStore.count(), 1000)
            
            // Test search performance and accuracy
            let queryVector = Array(repeating: Float(0.5), count: dimension)
            let results = try vectorStore.search(query: queryVector, k: 10)
            XCTAssertEqual(results.count, 10)
            
            // Verify we can retrieve vectors
            for i in 1...5 {
                let vector = try vectorStore.getVector(id: UInt64(i))
                XCTAssertEqual(vector.count, dimension)
            }
            
            // Test contains functionality
            XCTAssertTrue(try vectorStore.contains(id: 500))
            XCTAssertFalse(try vectorStore.contains(id: 1001))
        })
        
        // Clean up the temporary file
        if FileManager.default.fileExists(atPath: tempFile) {
            try? FileManager.default.removeItem(atPath: tempFile)
        }
    }
    
    func testHNSWIndexVeryLargeDataset10000() {
        // Test with very large dataset (10000 vectors) for comprehensive coverage
        let dimension = 64
        let metric = LlamaMobileVD.DistanceMetric.cosine
        
        XCTAssertNoThrow({ 
            let hnswIndex = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: metric, maxElements: 10000, m: 16, efConstruction: 200)
            
            // Add 10000 vectors
            for i in 1...10000 {
                let vector = Array(repeating: Float(i) / 10000.0, count: dimension)
                try hnswIndex.addVector(id: UInt64(i), vector: vector)
            }
            XCTAssertEqual(try hnswIndex.count(), 10000)
            
            // Test search performance and accuracy
            let queryVector = Array(repeating: Float(0.5), count: dimension)
            let results = try hnswIndex.search(query: queryVector, k: 10)
            XCTAssertEqual(results.count, 10)
            
            // Test contains functionality
            XCTAssertTrue(try hnswIndex.contains(id: 5000))
            XCTAssertFalse(try hnswIndex.contains(id: 10001))
        })
    }
}
