/// LlamaMobileVD iOS Swift SDK
/// A high-performance vector database for mobile applications
import Foundation

// Import the Objective-C framework
@_exported import LlamaMobileVD

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
    
    /// Initialize from an Objective-C search result
    internal init(objcResult: LlamaMobileVDSearchResult) {
        self.id = Int(objcResult.identifier)
        self.distance = objcResult.distance
    }
}

/// A vector store for efficiently storing and searching vectors
public class VectorStore {
    private let objcStore: LlamaMobileVDVectorStore
    
    /// Initialize a new vector store
    /// - Parameters:
    ///   - dimension: The dimension of the vectors
    ///   - metric: The distance metric to use for similarity search
    /// - Throws: An error if the vector store could not be created
    public init(dimension: Int, metric: DistanceMetric) throws {
        objcStore = LlamaMobileVDVectorStore(dimension: UInt(dimension), metric: metric.objcValue)
    }
    
    /// Add a vector to the store
    /// - Parameters:
    ///   - vector: The vector to add
    ///   - id: The ID to associate with the vector
    /// - Throws: An error if the vector could not be added
    public func addVector(_ vector: [Float], id: Int) throws {
        var error: NSError?
        guard objcStore.addIdentifier(UInt64(id), vector: vector, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add vector"])
        }
    }
    
    /// Remove a vector from the store by ID
    /// - Parameter id: The ID of the vector to remove
    /// - Returns: true if the vector was removed, false otherwise
    /// - Throws: An error if the operation fails
    public func remove(id: Int) throws -> Bool {
        var removed: ObjCBool = false
        var error: NSError?
        guard objcStore.removeIdentifier(UInt64(id), removed: &removed, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to remove vector"])
        }
        return Bool(removed)
    }
    
    /// Get a vector from the store by ID
    /// - Parameter id: The ID of the vector to get
    /// - Returns: The vector if found, nil otherwise
    /// - Throws: An error if the operation fails
    public func get(id: Int) throws -> [Float]? {
        let dimension = try self.dimension
        var vector = [Float](repeating: 0.0, count: dimension)
        var error: NSError?
        guard objcStore.getVector(forIdentifier: UInt64(id), vector: &vector, vectorSize: UInt(dimension), error: &error) else {
            return nil
        }
        return vector
    }
    
    /// Update a vector in the store by ID
    /// - Parameters:
    ///   - id: The ID of the vector to update
    ///   - vector: The new vector data
    /// - Returns: true if the vector was updated, false otherwise
    /// - Throws: An error if the operation fails
    public func update(id: Int, vector: [Float]) throws -> Bool {
        var error: NSError?
        guard objcStore.updateIdentifier(UInt64(id), vector: vector, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update vector"])
        }
        return true
    }
    
    /// Search for the nearest neighbors of a query vector
    /// - Parameters:
    ///   - queryVector: The query vector
    ///   - k: The number of nearest neighbors to return
    /// - Returns: An array of search results sorted by distance
    /// - Throws: An error if the search could not be performed
    public func search(_ queryVector: [Float], k: Int) throws -> [SearchResult] {
        var error: NSError?
        guard let objcResults = objcStore.searchVector(queryVector, k: UInt(k), error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to search vectors"])
        }
        return objcResults.map { SearchResult(objcResult: $0) }
    }
    
    /// Get the number of vectors in the store
    public var count: Int {
        var error: NSError?
        return Int(objcStore.size(&error) ?? 0)
    }
    
    /// Get the dimension of the vectors in the store
    public var dimension: Int {
        var error: NSError?
        return Int(objcStore.dimension(&error) ?? 0)
    }
    
    /// Get the distance metric used by the store
    public var metric: DistanceMetric {
        var error: NSError?
        let objcMetric = objcStore.metric(&error)
        switch objcMetric {
        case LlamaMobileVDDistanceMetricL2:
            return .l2
        case LlamaMobileVDDistanceMetricCosine:
            return .cosine
        case LlamaMobileVDDistanceMetricDot:
            return .dot
        default:
            return .l2
        }
    }
    
    /// Check if the store contains a vector with the given ID
    /// - Parameter id: The ID to check
    /// - Returns: true if the vector exists, false otherwise
    /// - Throws: An error if the operation fails
    public func contains(id: Int) throws -> Bool {
        var contains: ObjCBool = false
        var error: NSError?
        guard objcStore.containsIdentifier(UInt64(id), contains: &contains, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to check if vector exists"])
        }
        return Bool(contains)
    }
    
    /// Reserve space for the specified number of vectors
    /// - Parameter capacity: The number of vectors to reserve space for
    /// - Throws: An error if the operation fails
    public func reserve(capacity: Int) throws {
        var error: NSError?
        guard objcStore.reserveCapacity(UInt(capacity), error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to reserve capacity"])
        }
    }
    
    /// Clear all vectors from the store
    /// - Throws: An error if the store could not be cleared
    public func clear() throws {
        var error: NSError?
        guard objcStore.clear(&error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to clear vector store"])
        }
    }
}

/// A high-performance approximate nearest neighbor search index using the HNSW algorithm
public class HNSWIndex {
    private let objcIndex: LlamaMobileVDHNSWIndex
    
    /// Initialize a new HNSW index
    /// - Parameters:
    ///   - dimension: The dimension of the vectors
    ///   - metric: The distance metric to use
    ///   - m: The maximum number of connections per node
    ///   - efConstruction: The size of the dynamic list for candidate selection during construction
    /// - Throws: An error if the index could not be created
    public init(dimension: Int, metric: DistanceMetric, m: Int = 16, efConstruction: Int = 200) throws {
        // Note: The Objective-C framework uses maxElements parameter, which we'll set to a large value
        // since the C++ wrapper doesn't have this parameter explicitly
        objcIndex = LlamaMobileVDHNSWIndex(
            dimension: UInt(dimension),
            metric: metric.objcValue,
            maxElements: UInt(dimension * 1000),  // Default to 1000x dimension as a reasonable capacity
            M: UInt(m),
            efConstruction: UInt(efConstruction),
            seed: 42
        )
    }
    
    /// Add a vector to the index
    /// - Parameters:
    ///   - vector: The vector to add
    ///   - id: The ID to associate with the vector
    /// - Throws: An error if the vector could not be added
    public func addVector(_ vector: [Float], id: Int) throws {
        var error: NSError?
        guard objcIndex.addIdentifier(UInt64(id), vector: vector, error: &error) else {
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
        // Set efSearch before searching
        try setEfSearch(efSearch)
        
        var error: NSError?
        guard let objcResults = objcIndex.searchVector(queryVector, k: UInt(k), error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to search HNSW index"])
        }
        return objcResults.map { SearchResult(objcResult: $0) }
    }
    
    /// Set the efSearch parameter for search operations
    /// - Parameter efSearch: The new efSearch value
    /// - Throws: An error if the operation fails
    public func setEfSearch(_ efSearch: Int) throws {
        var error: NSError?
        guard objcIndex.setEfSearch(UInt(efSearch), error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to set efSearch"])
        }
    }
    
    /// Get the current efSearch parameter
    /// - Returns: The current efSearch value
    /// - Throws: An error if the operation fails
    public func getEfSearch() throws -> Int {
        var error: NSError?
        guard let efSearch = objcIndex.efSearch(&error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get efSearch"])
        }
        return Int(efSearch)
    }
    
    /// Get the number of vectors in the index
    public var count: Int {
        var error: NSError?
        return Int(objcIndex.size(&error) ?? 0)
    }
    
    /// Get the dimension of the vectors in the index
    public var dimension: Int {
        var error: NSError?
        return Int(objcIndex.dimension(&error) ?? 0)
    }
    
    /// Get the maximum capacity of the index
    public var capacity: Int {
        var error: NSError?
        return Int(objcIndex.capacity(&error) ?? 0)
    }
    
    /// Check if the index contains a vector with the given ID
    /// - Parameter id: The ID to check
    /// - Returns: true if the vector exists, false otherwise
    /// - Throws: An error if the operation fails
    public func contains(id: Int) throws -> Bool {
        var contains: ObjCBool = false
        var error: NSError?
        guard objcIndex.containsIdentifier(UInt64(id), contains: &contains, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to check if vector exists"])
        }
        return Bool(contains)
    }
    
    /// Get a vector from the index by ID
    /// - Parameter id: The ID of the vector to get
    /// - Returns: The vector if found, nil otherwise
    /// - Throws: An error if the operation fails
    public func getVector(id: Int) throws -> [Float]? {
        let dimension = self.dimension
        var vector = [Float](repeating: 0.0, count: dimension)
        var error: NSError?
        guard objcIndex.getVector(forIdentifier: UInt64(id), vector: &vector, vectorSize: UInt(dimension), error: &error) else {
            return nil
        }
        return vector
    }
    
    /// Save the index to a file
    /// - Parameter filename: The path to the file where the index should be saved
    /// - Returns: true if the index was saved successfully, false otherwise
    /// - Throws: An error if the operation fails
    public func save(filename: String) throws -> Bool {
        var error: NSError?
        guard objcIndex.save(toFile: filename, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save HNSW index"])
        }
        return true
    }
    
    /// Load an HNSW index from a file
    /// - Parameter filename: The path to the file containing the saved index
    /// - Returns: The loaded HNSW index
    /// - Throws: An error if the index could not be loaded
    public static func load(filename: String) throws -> HNSWIndex {
        var error: NSError?
        guard let objcIndex = LlamaMobileVDHNSWIndex.load(fromFile: filename, error: &error) else {
            throw error ?? NSError(domain: "LlamaMobileVD", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load HNSW index from file: \(filename)"])
        }
        return HNSWIndex(objcIndex: objcIndex)
    }
    
    /// Private initializer for loading an existing index
    private init(objcIndex: LlamaMobileVDHNSWIndex) {
        self.objcIndex = objcIndex
    }
    
    /// Clear all vectors from the index
    /// - Throws: An error if the index could not be cleared
    public func clear() throws {
        // Note: The Objective-C framework doesn't have a clear method explicitly,
        // but we can recreate the index with the same parameters
        let dimension = self.dimension
        let currentEfSearch = try self.getEfSearch()
        
        // Create a new index with the same parameters
        let newIndex = LlamaMobileVDHNSWIndex(
            dimension: UInt(dimension),
            metric: objcIndex.metric(nil),
            maxElements: UInt(capacity),
            M: 16,  // Default value, we don't have access to the current M value
            efConstruction: 200,  // Default value, we don't have access to the current efConstruction value
            seed: 42
        )
        
        // Replace the current index
        objcIndex = newIndex
        
        // Restore the efSearch value
        try setEfSearch(currentEfSearch)
    }
}

/// Version information for LlamaMobileVD SDK
public class LlamaMobileVDVersion {
    /// Get the full version string
    public static func getVersion() -> String {
        return LlamaMobileVD.version()
    }
    
    /// Get the major version component
    public static func getVersionMajor() -> Int {
        return Int(LlamaMobileVD.versionMajor())
    }
    
    /// Get the minor version component
    public static func getVersionMinor() -> Int {
        return Int(LlamaMobileVD.versionMinor())
    }
    
    /// Get the patch version component
    public static func getVersionPatch() -> Int {
        return Int(LlamaMobileVD.versionPatch())
    }
}
