/// LlamaMobileVD iOS Swift SDK
/// A high-performance vector database for mobile applications
import Foundation

/// Distance metrics supported by LlamaMobileVD
public enum DistanceMetric {
    case l2
    case cosine
    case dot
    
    /// Convert to the underlying Objective-C enum
    internal var objcValue: LlamaMobileVDDistanceMetric {
        switch self {
        case .l2:
            return LlamaMobileVDDistanceMetricL2
        case .cosine:
            return LlamaMobileVDDistanceMetricCosine
        case .dot:
            return LlamaMobileVDDistanceMetricDot
        }
    }
}

/// A result from a vector search operation
public struct SearchResult {
    public let id: Int
    public let distance: Float
    
    /// Initialize a new search result
    /// - Parameters:
    ///   - id: The ID of the vector
    ///   - distance: The distance between the query vector and the result vector
    public init(id: Int, distance: Float) {
        self.id = id
        self.distance = distance
    }
}

/// A vector store for efficiently storing and searching vectors
public class VectorStore {
    private var objcStore: LlamaMobileVDVectorStore
    
    /// Initialize a new vector store
    /// - Parameters:
    ///   - dimension: The dimension of the vectors
    ///   - metric: The distance metric to use for similarity search
    /// - Throws: An error if the vector store could not be created
    public init(dimension: Int, metric: DistanceMetric) throws {
        var error: NSError?
        guard let store = LlamaMobileVDVectorStoreCreate(Int32(dimension), metric.objcValue, &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create vector store"])
        }
        objcStore = store
    }
    
    deinit {
        LlamaMobileVDVectorStoreDestroy(objcStore)
    }
    
    /// Add a vector to the store
    /// - Parameters:
    ///   - vector: The vector to add
    ///   - id: The ID to associate with the vector
    /// - Throws: An error if the vector could not be added
    public func addVector(_ vector: [Float], id: Int) throws {
        var error: NSError?
        guard LlamaMobileVDVectorStoreAddVector(objcStore, vector, Int32(vector.count), Int32(id), &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add vector"])
        }
    }
    
    /// Search for the nearest neighbors of a query vector
    /// - Parameters:
    ///   - queryVector: The query vector
    ///   - k: The number of nearest neighbors to return
    /// - Returns: An array of search results sorted by distance
    /// - Throws: An error if the search could not be performed
    public func search(_ queryVector: [Float], k: Int) throws -> [SearchResult] {
        var error: NSError?
        var results: UnsafeMutablePointer<LlamaMobileVDSearchResult>?
        var count: Int32 = 0
        
        guard LlamaMobileVDVectorStoreSearch(objcStore, queryVector, Int32(queryVector.count), Int32(k), &results, &count, &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to search vectors"])
        }
        
        defer {
            LlamaMobileVDVectorStoreFreeSearchResults(results)
        }
        
        var searchResults: [SearchResult] = []
        for i in 0..<Int(count) {
            let result = results![i]
            searchResults.append(SearchResult(id: Int(result.id), distance: result.distance))
        }
        
        return searchResults
    }
    
    /// Get the number of vectors in the store
    public var count: Int {
        return Int(LlamaMobileVDVectorStoreGetCount(objcStore))
    }
    
    /// Clear all vectors from the store
    /// - Throws: An error if the store could not be cleared
    public func clear() throws {
        var error: NSError?
        guard LlamaMobileVDVectorStoreClear(objcStore, &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to clear vector store"])
        }
    }
}

/// A high-performance approximate nearest neighbor search index using the HNSW algorithm
public class HNSWIndex {
    private var objcIndex: LlamaMobileVDHNSWIndex
    
    /// Initialize a new HNSW index
    /// - Parameters:
    ///   - dimension: The dimension of the vectors
    ///   - metric: The distance metric to use
    ///   - m: The maximum number of connections per node
    ///   - efConstruction: The size of the dynamic list for candidate selection during construction
    /// - Throws: An error if the index could not be created
    public init(dimension: Int, metric: DistanceMetric, m: Int = 16, efConstruction: Int = 200) throws {
        var error: NSError?
        guard let index = LlamaMobileVDHNSWIndexCreate(Int32(dimension), metric.objcValue, Int32(m), Int32(efConstruction), &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create HNSW index"])
        }
        objcIndex = index
    }
    
    deinit {
        LlamaMobileVDHNSWIndexDestroy(objcIndex)
    }
    
    /// Add a vector to the index
    /// - Parameters:
    ///   - vector: The vector to add
    ///   - id: The ID to associate with the vector
    /// - Throws: An error if the vector could not be added
    public func addVector(_ vector: [Float], id: Int) throws {
        var error: NSError?
        guard LlamaMobileVDHNSWIndexAddVector(objcIndex, vector, Int32(vector.count), Int32(id), &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add vector to HNSW index"])
        }
    }
    
    /// Search for the nearest neighbors of a query vector
    /// - Parameters:
    ///   - queryVector: The query vector
    ///   - k: The number of nearest neighbors to return
    ///   - efSearch: The size of the dynamic list for candidate selection during search
    /// - Returns: An array of search results sorted by distance
    /// - Throws: An error if the search could not be performed
    public func search(_ queryVector: [Float], k: Int, efSearch: Int = 50) throws -> [SearchResult] {
        var error: NSError?
        var results: UnsafeMutablePointer<LlamaMobileVDSearchResult>?
        var count: Int32 = 0
        
        guard LlamaMobileVDHNSWIndexSearch(objcIndex, queryVector, Int32(queryVector.count), Int32(k), Int32(efSearch), &results, &count, &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to search HNSW index"])
        }
        
        defer {
            LlamaMobileVDHNSWIndexFreeSearchResults(results)
        }
        
        var searchResults: [SearchResult] = []
        for i in 0..<Int(count) {
            let result = results![i]
            searchResults.append(SearchResult(id: Int(result.id), distance: result.distance))
        }
        
        return searchResults
    }
    
    /// Get the number of vectors in the index
    public var count: Int {
        return Int(LlamaMobileVDHNSWIndexGetCount(objcIndex))
    }
    
    /// Clear all vectors from the index
    /// - Throws: An error if the index could not be cleared
    public func clear() throws {
        var error: NSError?
        guard LlamaMobileVDHNSWIndexClear(objcIndex, &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to clear HNSW index"])
        }
    }
}
