//
//  llama_mobile_vd.swift
//  llama_mobile_vd
//
//  Created by llama_mobile_vd team
//

import Foundation

// Import the C framework
import llama_mobile_vd

/// Swift wrapper for the llama_mobile_vd vector database
public class LlamaMobileVD {
    
    /// Error types for vector database operations
    public enum Error: Swift.Error {
        case operationFailed(String)
        case invalidParameter(String)
        case idNotFound
        case duplicateId
        case indexFull
    }
    
    /// Distance metrics for vector similarity
    public enum DistanceMetric {
        case l2
        case cosine
        case dot
        
        internal func toCEnum() -> LLAMA_MOBILE_VD_DistanceMetric {
            switch self {
            case .l2:
                return LLAMA_MOBILE_VD_DISTANCE_L2
            case .cosine:
                return LLAMA_MOBILE_VD_DISTANCE_COSINE
            case .dot:
                return LLAMA_MOBILE_VD_DISTANCE_DOT
            }
        }
    }
    
    /// Vector store class for managing vectors
    public class VectorStore {
        private var store: LLAMA_MOBILE_VD_VectorStore?
        
        /// Create a new vector store
        /// - Parameters:
        ///   - dimension: The dimension of vectors to store
        ///   - metric: The distance metric to use for similarity search
        public init(dimension: Int, metric: DistanceMetric = .l2) throws {
            var storePtr: LLAMA_MOBILE_VD_VectorStore?
            let error = llama_mobile_vd_vector_store_create(dimension, metric.toCEnum(), &storePtr)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to create vector store")
            }
            
            self.store = storePtr
        }
        
        /// Add a vector to the store
        /// - Parameters:
        ///   - id: Unique identifier for the vector
        ///   - vector: Array of float values representing the vector
        public func addVector(id: UInt64, vector: [Float]) throws {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            guard vector.count > 0 else { throw Error.invalidParameter("Empty vector") }
            
            let error = llama_mobile_vd_vector_store_add(store, id, vector)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to add vector")
            }
        }
        
        /// Search for similar vectors
        /// - Parameters:
        ///   - query: Query vector to search for
        ///   - k: Number of results to return
        /// - Returns: Array of (id, distance) tuples sorted by distance
        public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)] {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            guard k > 0 else { throw Error.invalidParameter("Invalid k value") }
            
            var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: Int(k))
            let error = llama_mobile_vd_vector_store_search(store, query, k, &results, k)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Search failed")
            }
            
            return results.map { ($0.id, $0.distance) }
        }
        
        /// Remove a vector by ID
        /// - Parameter id: Unique identifier of the vector to remove
        /// - Returns: True if the vector was found and removed, false otherwise
        public func removeVector(id: UInt64) throws -> Bool {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var removed: Int32 = 0
            let error = llama_mobile_vd_vector_store_remove(store, id, &removed)
            
            if error != LLAMA_MOBILE_VD_OK && error != LLAMA_MOBILE_VD_ID_NOT_FOUND {
                throw mapError(error, message: "Failed to remove vector")
            }
            
            return removed != 0
        }
        
        /// Get a vector by ID
        /// - Parameter id: Unique identifier of the vector
        /// - Returns: Array of float values representing the vector
        public func getVector(id: UInt64) throws -> [Float] {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var dimension: Int = 0
            let dimError = llama_mobile_vd_vector_store_dimension(store, &dimension)
            if dimError != LLAMA_MOBILE_VD_OK {
                throw mapError(dimError, message: "Failed to get dimension")
            }
            
            var vector = [Float](repeating: 0, count: Int(dimension))
            let error = llama_mobile_vd_vector_store_get(store, id, &vector, dimension)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get vector")
            }
            
            return vector
        }
        
        /// Clear all vectors from the store
        public func clear() throws {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            let error = llama_mobile_vd_vector_store_clear(store)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to clear store")
            }
        }
        
        /// Get the number of vectors in the store
        public func count() throws -> Int {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var count: Int = 0
            let error = llama_mobile_vd_vector_store_size(store, &count)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get count")
            }
            
            return count
        }
        
        /// Get the dimension of vectors in the store
        public func dimension() throws -> Int {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var dimension: Int = 0
            let error = llama_mobile_vd_vector_store_dimension(store, &dimension)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get dimension")
            }
            
            return dimension
        }
        
        /// Update an existing vector in the store
        /// - Parameters:
        ///   - id: Unique identifier for the vector
        ///   - vector: Array of float values representing the new vector data
        public func updateVector(id: UInt64, vector: [Float]) throws {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            guard vector.count > 0 else { throw Error.invalidParameter("Empty vector") }
            
            let error = llama_mobile_vd_vector_store_update(store, id, vector)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to update vector")
            }
        }
        
        /// Get the distance metric used by the vector store
        public func metric() throws -> DistanceMetric {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var metricValue: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
            let error = llama_mobile_vd_vector_store_metric(store, &metricValue)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get metric")
            }
            
            switch metricValue {
            case LLAMA_MOBILE_VD_DISTANCE_L2:
                return .l2
            case LLAMA_MOBILE_VD_DISTANCE_COSINE:
                return .cosine
            case LLAMA_MOBILE_VD_DISTANCE_DOT:
                return .dot
            default:
                return .l2
            }
        }
        
        /// Check if a vector with the specified ID exists in the store
        /// - Parameter id: Unique identifier to check
        /// - Returns: True if the vector exists, false otherwise
        public func containsVector(id: UInt64) throws -> Bool {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var containsValue: Int32 = 0
            let error = llama_mobile_vd_vector_store_contains(store, id, &containsValue)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to check if vector exists")
            }
            
            return containsValue != 0
        }
        
        /// Reserve capacity for a specific number of vectors
        /// - Parameter capacity: The number of vectors to reserve space for
        public func reserveCapacity(capacity: Int) throws {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            let error = llama_mobile_vd_vector_store_reserve(store, capacity)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to reserve capacity")
            }
        }
        
        /// Deinitialize the vector store
        deinit {
            if let store = store {
                llama_mobile_vd_vector_store_destroy(store)
            }
        }
    }
    
    /// HNSWIndex class for high-performance approximate nearest neighbor search
    public class HNSWIndex {
        private var index: LLAMA_MOBILE_VD_HNSWIndex?
        
        /// Create a new HNSW index with default parameters
        /// - Parameters:
        ///   - dimension: The dimension of vectors to store
        ///   - metric: The distance metric to use for similarity search
        ///   - maxElements: The maximum number of elements the index can hold
        public init(dimension: Int, metric: DistanceMetric, maxElements: Int) throws {
            var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
            let error = llama_mobile_vd_hnsw_index_create(
                dimension,
                metric.toCEnum(),
                maxElements,
                &indexPtr
            )
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to create HNSW index")
            }
            
            self.index = indexPtr
        }
        
        /// Create a new HNSW index with custom parameters
        /// - Parameters:
        ///   - dimension: The dimension of vectors to store
        ///   - metric: The distance metric to use for similarity search
        ///   - maxElements: The maximum number of elements the index can hold
        ///   - m: The number of connections per node
        ///   - efConstruction: The size of the dynamic list for construction
        ///   - seed: Random seed for index construction
        public init(
            dimension: Int,
            metric: DistanceMetric,
            maxElements: Int,
            m: Int,
            efConstruction: Int,
            seed: UInt32 = 0
        ) throws {
            var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
            let error = llama_mobile_vd_hnsw_index_create_with_params(
                dimension,
                metric.toCEnum(),
                maxElements,
                m,
                efConstruction,
                seed,
                &indexPtr
            )
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to create HNSW index with custom parameters")
            }
            
            self.index = indexPtr
        }
        
        /// Add a vector to the HNSW index
        /// - Parameters:
        ///   - id: Unique identifier for the vector
        ///   - vector: Array of float values representing the vector
        public func addVector(id: UInt64, vector: [Float]) throws {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            let error = llama_mobile_vd_hnsw_index_add(index, id, vector)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to add vector to HNSW index")
            }
        }
        
        /// Search for similar vectors in the HNSW index
        /// - Parameters:
        ///   - query: Query vector to search for
        ///   - k: Number of results to return
        /// - Returns: Array of (id, distance) tuples sorted by distance
        public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)] {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            guard k > 0 else { throw Error.invalidParameter("Invalid k value") }
            
            var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: Int(k))
            let error = llama_mobile_vd_hnsw_index_search(
                index,
                query,
                k,
                &results,
                results.count
            )
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Search failed")
            }
            
            return results.map { ($0.id, $0.distance) }
        }
        
        /// Set the ef_search parameter for the HNSW index
        /// - Parameter efSearch: The size of the dynamic list for search
        public func setEfSearch(_ efSearch: Int) throws {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            let error = llama_mobile_vd_hnsw_index_set_ef_search(index, efSearch)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to set ef_search")
            }
        }
        
        /// Get the current ef_search parameter
        public func getEfSearch() throws -> Int {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            var efSearch: Int = 0
            let error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get ef_search")
            }
            
            return efSearch
        }
        
        /// Get the number of vectors in the index
        public func count() throws -> Int {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            var count: Int = 0
            let error = llama_mobile_vd_hnsw_index_size(index, &count)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get count")
            }
            
            return count
        }
        
        /// Get the dimension of vectors in the index
        public func dimension() throws -> Int {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            var dimension: Int = 0
            let error = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get dimension")
            }
            
            return dimension
        }
        
        /// Get the maximum capacity of the index
        public func capacity() throws -> Int {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            var capacity: Int = 0
            let error = llama_mobile_vd_hnsw_index_capacity(index, &capacity)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get capacity")
            }
            
            return capacity
        }
        
        /// Check if a vector with the specified ID exists in the index
        /// - Parameter id: Unique identifier to check
        /// - Returns: True if the vector exists, false otherwise
        public func contains(id: UInt64) throws -> Bool {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            var containsValue: Int32 = 0
            let error = llama_mobile_vd_hnsw_index_contains(index, id, &containsValue)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to check if vector exists")
            }
            
            return containsValue != 0
        }
        
        /// Get a vector by ID from the index
        /// - Parameter id: Unique identifier of the vector
        /// - Returns: Array of float values representing the vector
        public func getVector(id: UInt64) throws -> [Float] {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            var dimension: Int = 0
            let dimError = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
            if dimError != LLAMA_MOBILE_VD_OK {
                throw mapError(dimError, message: "Failed to get dimension")
            }
            
            var vector = [Float](repeating: 0, count: Int(dimension))
            let error = llama_mobile_vd_hnsw_index_get_vector(index, id, &vector, dimension)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get vector")
            }
            
            return vector
        }
        
        /// Save the HNSW index to a file
        /// - Parameter filename: Path to the file where the index should be saved
        public func save(to filename: String) throws {
            guard let index = index else { throw Error.operationFailed("Index not initialized") }
            
            let error = llama_mobile_vd_hnsw_index_save(index, filename)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to save index")
            }
        }
        
        /// Load an HNSW index from a file
        /// - Parameter filename: Path to the file containing the saved index
        /// - Returns: An instance of HNSWIndex loaded from the file
        public static func load(from filename: String) throws -> HNSWIndex {
            var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
            let error = llama_mobile_vd_hnsw_index_load(filename, &indexPtr)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to load index")
            }
            
            let index = HNSWIndex()
            index.index = indexPtr
            return index
        }
        
        /// Private initializer for loading from file
        private init() {}
        
        /// Deinitialize the HNSW index
        deinit {
            if let index = index {
                llama_mobile_vd_hnsw_index_destroy(index)
            }
        }
    }
    
    /// MMapVectorStoreBuilder class for creating memory-mapped vector stores
    public class MMapVectorStoreBuilder {
        private var builder: LLAMA_MOBILE_VD_MMapVectorStoreBuilder?
        
        /// Create a new MMapVectorStoreBuilder
        /// - Parameters:
        ///   - dimension: The dimension of vectors to store
        ///   - metric: The distance metric to use for similarity search
        public init(dimension: Int, metric: DistanceMetric) throws {
            var builderPtr: LLAMA_MOBILE_VD_MMapVectorStoreBuilder?
            let error = llama_mobile_vd_mmap_vector_store_builder_create(
                dimension,
                metric.toCEnum(),
                &builderPtr
            )
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to create MMapVectorStoreBuilder")
            }
            
            self.builder = builderPtr
        }
        
        /// Add a vector to the builder
        /// - Parameters:
        ///   - id: Unique identifier for the vector
        ///   - vector: Array of float values representing the vector
        public func addVector(id: UInt64, vector: [Float]) throws {
            guard let builder = builder else { throw Error.operationFailed("Builder not initialized") }
            
            let error = llama_mobile_vd_mmap_vector_store_builder_add(builder, id, vector)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to add vector to builder")
            }
        }
        
        /// Reserve capacity for a specific number of vectors
        /// - Parameter capacity: The number of vectors to reserve space for
        public func reserve(capacity: Int) throws {
            guard let builder = builder else { throw Error.operationFailed("Builder not initialized") }
            
            let error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, capacity)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to reserve capacity")
            }
        }
        
        /// Save the builder to a file, creating an MMapVectorStore
        /// - Parameter filename: Path to the file where the vector store should be saved
        public func save(to filename: String) throws {
            guard let builder = builder else { throw Error.operationFailed("Builder not initialized") }
            
            let error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filename)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to save vector store")
            }
        }
        
        /// Get the number of vectors in the builder
        public func count() throws -> Int {
            guard let builder = builder else { throw Error.operationFailed("Builder not initialized") }
            
            var count: Int = 0
            let error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &count)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get count")
            }
            
            return count
        }
        
        /// Get the dimension of vectors in the builder
        public func dimension() throws -> Int {
            guard let builder = builder else { throw Error.operationFailed("Builder not initialized") }
            
            var dimension: Int = 0
            let error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get dimension")
            }
            
            return dimension
        }
        
        /// Deinitialize the builder
        deinit {
            if let builder = builder {
                llama_mobile_vd_mmap_vector_store_builder_destroy(builder)
            }
        }
    }
    
    /// MMapVectorStore class for memory-mapped vector storage
    public class MMapVectorStore {
        private var store: LLAMA_MOBILE_VD_MMapVectorStore?
        
        /// Open an MMapVectorStore from a file
        /// - Parameter filename: Path to the file containing the vector store
        /// - Returns: An instance of MMapVectorStore opened from the file
        public static func open(from filename: String) throws -> MMapVectorStore {
            var storePtr: LLAMA_MOBILE_VD_MMapVectorStore?
            let error = llama_mobile_vd_mmap_vector_store_open(filename, &storePtr)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to open vector store")
            }
            
            let store = MMapVectorStore()
            store.store = storePtr
            return store
        }
        
        /// Get a vector by ID from the store
        /// - Parameter id: Unique identifier of the vector
        /// - Returns: Array of float values representing the vector
        public func getVector(id: UInt64) throws -> [Float] {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var dimension: Int = 0
            let dimError = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
            if dimError != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to get dimension")
            }
            
            var vector = [Float](repeating: 0, count: Int(dimension))
            let error = llama_mobile_vd_mmap_vector_store_get(store, id, &vector, dimension)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to get vector")
            }
            
            return vector
        }
        
        /// Search for similar vectors in the store
        /// - Parameters:
        ///   - query: Query vector to search for
        ///   - k: Number of results to return
        /// - Returns: Array of (id, distance) tuples sorted by distance
        public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)] {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            guard k > 0 else { throw Error.invalidParameter("Invalid k value") }
            
            var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: Int(k))
            let error = llama_mobile_vd_mmap_vector_store_search(
                store,
                query,
                k,
                &results,
                k
            )
            
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Search failed")
            }
            
            return results.map { ($0.id, $0.distance) }
        }
        
        /// Check if a vector with the specified ID exists in the store
        /// - Parameter id: Unique identifier to check
        /// - Returns: True if the vector exists, false otherwise
        public func contains(id: UInt64) throws -> Bool {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var containsValue: Int32 = 0
            let error = llama_mobile_vd_mmap_vector_store_contains(store, id, &containsValue)
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to check if vector exists")
            }
            
            return containsValue != 0
        }
        
        /// Get the number of vectors in the store
        public func count() throws -> Int {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var count: Int = 0
            let error = llama_mobile_vd_mmap_vector_store_size(store, &count)
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to get count")
            }
            
            return count
        }
        
        /// Get the dimension of vectors in the store
        public func dimension() throws -> Int {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var dimension: Int = 0
            let error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to get dimension")
            }
            
            return dimension
        }
        
        /// Get the distance metric used by the vector store
        public func metric() throws -> DistanceMetric {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var metricValue: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
            let error = llama_mobile_vd_mmap_vector_store_metric(store, &metricValue)
            if error != LLAMA_MOBILE_VD_OK {
                throw Error.operationFailed("Failed to get metric")
            }
            
            switch metricValue {
            case LLAMA_MOBILE_VD_DISTANCE_L2:
                return .l2
            case LLAMA_MOBILE_VD_DISTANCE_COSINE:
                return .cosine
            case LLAMA_MOBILE_VD_DISTANCE_DOT:
                return .dot
            default:
                return .l2
            }
        }
        
        /// Private initializer for opening from file
        private init() {}
        
        /// Deinitialize the vector store
        deinit {
            if let store = store {
                llama_mobile_vd_mmap_vector_store_close(store)
            }
        }
    }
    
    /// Map C error codes to Swift errors
    private static func mapError(_ error: LLAMA_MOBILE_VD_Error, message: String) -> Error {
        switch error {
        case LLAMA_MOBILE_VD_OK:
            // This should never be reached as we check for OK before calling this function
            fatalError("Success code passed to error mapper: \(message)")
        case LLAMA_MOBILE_VD_INVALID_ARGUMENT:
            return Error.invalidParameter(message)
        case LLAMA_MOBILE_VD_DUPLICATE_ID:
            return Error.duplicateId
        case LLAMA_MOBILE_VD_ID_NOT_FOUND:
            return Error.idNotFound
        case LLAMA_MOBILE_VD_INDEX_FULL:
            return Error.indexFull
        default:
            return Error.operationFailed(message)
        }
    }
    
    /// Version information for the llama_mobile_vd library
    public struct Version {
        /// Full version string (e.g., "1.0.0")
        public static var full: String {
            String(cString: llama_mobile_vd_version())
        }
        
        /// Major version number
        public static var major: Int {
            Int(llama_mobile_vd_version_major())
        }
        
        /// Minor version number
        public static var minor: Int {
            Int(llama_mobile_vd_version_minor())
        }
        
        /// Patch version number
        public static var patch: Int {
            Int(llama_mobile_vd_version_patch())
        }
    }
}
