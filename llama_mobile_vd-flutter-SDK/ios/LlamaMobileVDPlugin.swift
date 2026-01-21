// LlamaMobileVD Flutter Plugin for iOS
import Flutter
import UIKit
import LlamaMobileVD

/// A factory for creating FlutterMethodChannel instances
public class SwiftLlamaMobileVDPlugin: NSObject, FlutterPlugin {
    // Dictionary to keep track of vector stores
    private static var vectorStores: [Int: LlamaMobileVDVectorStore] = [:]
    private static var vectorStoreIdCounter = 0
    
    // Dictionary to keep track of HNSW indexes
    private static var hnswIndexes: [Int: LlamaMobileVDHNSWIndex] = [:]
    private static var hnswIndexIdCounter = 0
    
    // Dictionary to keep track of MMap vector stores
    private static var mmapVectorStores: [Int: LlamaMobileVDMMapVectorStore] = [:]
    private static var mmapVectorStoreIdCounter = 0
    
    // Dictionary to keep track of MMap vector store builders
    private static var mmapVectorStoreBuilders: [Int: LlamaMobileVDMMapVectorStoreBuilder] = [:]
    private static var mmapVectorStoreBuilderIdCounter = 0
    
    /// Registers the plugin with Flutter
    /// - Parameter registrar: The FlutterPluginRegistrar
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "llama_mobile_vd", binaryMessenger: registrar.messenger())
        let instance = SwiftLlamaMobileVDPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register the Flutter framework loader
        registrar.addApplicationDelegate(instance)
    }
    
    /// Handles method calls from Flutter
    /// - Parameters:
    ///   - call: The method call
    ///   - result: The result callback
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        // VectorStore methods
        case "vectorStoreCreate":
            handleVectorStoreCreate(call, result: result)
        case "vectorStoreAddVector":
            handleVectorStoreAddVector(call, result: result)
        case "vectorStoreSearch":
            handleVectorStoreSearch(call, result: result)
        case "vectorStoreCount":
            handleVectorStoreCount(call, result: result)
        case "vectorStoreClear":
            handleVectorStoreClear(call, result: result)
        case "vectorStoreDestroy":
            handleVectorStoreDestroy(call, result: result)
        case "vectorStoreRemove":
            handleVectorStoreRemove(call, result: result)
        case "vectorStoreGet":
            handleVectorStoreGet(call, result: result)
        case "vectorStoreUpdate":
            handleVectorStoreUpdate(call, result: result)
        case "vectorStoreDimension":
            handleVectorStoreDimension(call, result: result)
        case "vectorStoreMetric":
            handleVectorStoreMetric(call, result: result)
        case "vectorStoreContains":
            handleVectorStoreContains(call, result: result)
        case "vectorStoreReserve":
            handleVectorStoreReserve(call, result: result)
            
        // HNSWIndex methods
        case "hnswIndexCreate":
            handleHNSWIndexCreate(call, result: result)
        case "hnswIndexAddVector":
            handleHNSWIndexAddVector(call, result: result)
        case "hnswIndexSearch":
            handleHNSWIndexSearch(call, result: result)
        case "hnswIndexCount":
            handleHNSWIndexCount(call, result: result)
        case "hnswIndexClear":
            handleHNSWIndexClear(call, result: result)
        case "hnswIndexDestroy":
            handleHNSWIndexDestroy(call, result: result)
        case "hnswIndexSetEfSearch":
            handleHNSWIndexSetEfSearch(call, result: result)
        case "hnswIndexGetEfSearch":
            handleHNSWIndexGetEfSearch(call, result: result)
        case "hnswIndexDimension":
            handleHNSWIndexDimension(call, result: result)
        case "hnswIndexCapacity":
            handleHNSWIndexCapacity(call, result: result)
        case "hnswIndexContains":
            handleHNSWIndexContains(call, result: result)
        case "hnswIndexGetVector":
            handleHNSWIndexGetVector(call, result: result)
        case "hnswIndexSave":
            handleHNSWIndexSave(call, result: result)
        case "hnswIndexLoad":
            handleHNSWIndexLoad(call, result: result)
            
        // MMapVectorStoreBuilder methods
        case "mmapVectorStoreBuilderCreate":
            handleMMapVectorStoreBuilderCreate(call, result: result)
        case "mmapVectorStoreBuilderAddVector":
            handleMMapVectorStoreBuilderAddVector(call, result: result)
        case "mmapVectorStoreBuilderReserveCapacity":
            handleMMapVectorStoreBuilderReserveCapacity(call, result: result)
        case "mmapVectorStoreBuilderSave":
            handleMMapVectorStoreBuilderSave(call, result: result)
        case "mmapVectorStoreBuilderSize":
            handleMMapVectorStoreBuilderSize(call, result: result)
        case "mmapVectorStoreBuilderDimension":
            handleMMapVectorStoreBuilderDimension(call, result: result)
        case "mmapVectorStoreBuilderDestroy":
            handleMMapVectorStoreBuilderDestroy(call, result: result)
            
        // MMapVectorStore methods
        case "mmapVectorStoreOpen":
            handleMMapVectorStoreOpen(call, result: result)
        case "mmapVectorStoreSearch":
            handleMMapVectorStoreSearch(call, result: result)
        case "mmapVectorStoreCount":
            handleMMapVectorStoreCount(call, result: result)
        case "mmapVectorStoreDimension":
            handleMMapVectorStoreDimension(call, result: result)
        case "mmapVectorStoreMetric":
            handleMMapVectorStoreMetric(call, result: result)
        case "mmapVectorStoreDestroy":
            handleMMapVectorStoreDestroy(call, result: result)
            
        // Version information methods
        case "getVersion":
            handleGetVersion(call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - VectorStore Methods
    
    /// Handles vectorStoreCreate method call
    private func handleVectorStoreCreate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metricValue = args["metric"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let metric: LlamaMobileVDDistanceMetric
        switch metricValue {
        case 0:
            metric = .l2
        case 1:
            metric = .cosine
        case 2:
            metric = .dot
        default:
            result(FlutterError(code: "INVALID_METRIC", message: "Invalid distance metric", details: nil))
            return
        }
        
        // Use the Objective-C initializer with proper UInt conversion
        let store = LlamaMobileVDVectorStore(dimension: UInt(dimension), metric: metric)
        
        let storeId = SwiftLlamaMobileVDPlugin.vectorStoreIdCounter
        SwiftLlamaMobileVDPlugin.vectorStoreIdCounter += 1
        SwiftLlamaMobileVDPlugin.vectorStores[storeId] = store
        
        result(storeId)
    }
    
    /// Handles vectorStoreAddVector method call
    private func handleVectorStoreAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let vectorData = args["vector"] as? FlutterStandardTypedData,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let vector: [Float] = vectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        // Use the Swift throwing syntax (Objective-C methods with error parameters become throwing functions in Swift)
        do {
            try store.addIdentifier(UInt64(id), vector: vector)
            result(nil)
        } catch {
            result(FlutterError(code: "ADD_FAILED", message: "Failed to add vector", details: error.localizedDescription))
        }
    }
    
    /// Handles vectorStoreSearch method call
    private func handleVectorStoreSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorData = args["queryVector"] as? FlutterStandardTypedData,
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let queryVector: [Float] = queryVectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        // Use the Swift throwing syntax
        do {
            let searchResults = try store.searchVector(queryVector, k: UInt(k))
            let results = searchResults.map { ["id": Int($0.identifier), "distance": $0.distance] }
            result(results)
        } catch {
            result(FlutterError(code: "SEARCH_FAILED", message: "Failed to search vector store", details: error.localizedDescription))
        }
        

    }
    
    /// Handles vectorStoreCount method call
    private func handleVectorStoreCount(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Objective-C method with proper error handling
        var error: NSError?
        let count = store.size(&error)
        
        if error != nil {
            result(FlutterError(code: "COUNT_FAILED", message: "Failed to get count", details: error?.localizedDescription))
            return
        }
        
        result(Int(count))
    }
    
    /// Handles vectorStoreClear method call
    private func handleVectorStoreClear(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            try store.clear()
            result(nil)
        } catch {
            result(FlutterError(code: "CLEAR_FAILED", message: "Failed to clear vector store", details: error.localizedDescription))
        }
    }
    
    /// Handles vectorStoreDestroy method call
    private func handleVectorStoreDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard SwiftLlamaMobileVDPlugin.vectorStores.removeValue(forKey: storeId) != nil else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        result(nil)
    }
    
    /// Handles vectorStoreRemove method call
    private func handleVectorStoreRemove(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            var removed: ObjCBool = false
            try store.removeIdentifier(UInt64(id), removed: &removed)
            result(removed.boolValue)
        } catch {
            result(FlutterError(code: "REMOVE_FAILED", message: "Failed to remove vector", details: error.localizedDescription))
        }
    }
    
    /// Handles vectorStoreGet method call
    private func handleVectorStoreGet(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            let dimension = try store.dimension()
            
            var vector = [Float](repeating: 0.0, count: Int(dimension))
            try store.getVectorForIdentifier(UInt64(id), vector: &vector, vectorSize: UInt(vector.count))
            
            // Convert [Float] to FlutterStandardTypedData
            let vectorData = FlutterStandardTypedData(floats: vector)
            result(vectorData)
        } catch {
            // If the vector doesn't exist or an error occurred, return nil
            result(nil)
        }
        

    }
    
    /// Handles vectorStoreUpdate method call
    private func handleVectorStoreUpdate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let vectorData = args["vector"] as? FlutterStandardTypedData,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let vector: [Float] = vectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        // Use the Objective-C method with proper error handling
        var error: NSError?
        let success = store.updateIdentifier(UInt64(id), vector: vector, error: &error)
        
        if success {
            result(true)
        } else {
            result(FlutterError(code: "UPDATE_FAILED", message: "Failed to update vector", details: error?.localizedDescription))
        }
    }
    
    /// Handles vectorStoreDimension method call
    private func handleVectorStoreDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Objective-C method with proper error handling
        var error: NSError?
        let dimension = store.dimension(&error)
        
        if error != nil {
            result(FlutterError(code: "DIMENSION_FAILED", message: "Failed to get dimension", details: error?.localizedDescription))
            return
        }
        
        result(Int(dimension))
    }
    
    /// Handles vectorStoreMetric method call
    private func handleVectorStoreMetric(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Objective-C method with proper error handling
        var error: NSError?
        let metric = store.metric(&error)
        
        if error != nil {
            result(FlutterError(code: "METRIC_FAILED", message: "Failed to get metric", details: error?.localizedDescription))
            return
        }
        
        // Convert Objective-C metric to integer value
        switch metric {
        case .l2:
            result(0)
        case .cosine:
            result(1)
        case .dot:
            result(2)
        default:
            result(0) // Default to L2
        }
    }
    
    /// Handles vectorStoreContains method call
    private func handleVectorStoreContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            var contains: ObjCBool = false
            try store.containsIdentifier(UInt64(id), contains: &contains)
            result(contains.boolValue)
        } catch {
            result(FlutterError(code: "CONTAINS_FAILED", message: "Failed to check if vector exists", details: error.localizedDescription))
        }
    }
    
    /// Handles vectorStoreReserve method call
    private func handleVectorStoreReserve(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            try store.reserveCapacity(UInt(capacity))
            result(nil)
        } catch {
            result(FlutterError(code: "RESERVE_FAILED", message: "Failed to reserve capacity", details: error.localizedDescription))
        }
    }
    
    // MARK: - HNSWIndex Methods
    
    /// Handles hnswIndexCreate method call
    private func handleHNSWIndexCreate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metricValue = args["metric"] as? Int,
              let m = args["m"] as? Int,
              let efConstruction = args["efConstruction"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let metric: LlamaMobileVDDistanceMetric
        switch metricValue {
        case 0:
            metric = .l2
        case 1:
            metric = .cosine
        case 2:
            metric = .dot
        default:
            result(FlutterError(code: "INVALID_METRIC", message: "Invalid distance metric", details: nil))
            return
        }
        
        // Use a reasonable default for maxElements if not provided
        let maxElements = 100000
        
        // Create the HNSW index using the Objective-C initializer
        let index = LlamaMobileVDHNSWIndex(
            dimension: UInt(dimension),
            metric: metric,
            maxElements: UInt(maxElements),
            m: UInt(m),
            efConstruction: UInt(efConstruction),
            seed: 0
        )
        
        let indexId = SwiftLlamaMobileVDPlugin.hnswIndexIdCounter
        SwiftLlamaMobileVDPlugin.hnswIndexIdCounter += 1
        SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] = index
        
        result(indexId)
    }
    
    /// Handles hnswIndexAddVector method call
    private func handleHNSWIndexAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let vectorData = args["vector"] as? FlutterStandardTypedData,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let vector: [Float] = vectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        // Use the Swift throwing syntax
        do {
            try index.addIdentifier(UInt64(id), vector: vector)
            result(nil)
        } catch {
            result(FlutterError(code: "ADD_FAILED", message: "Failed to add vector to HNSW index", details: error.localizedDescription))
        }
    }
    
    /// Handles hnswIndexSearch method call
    private func handleHNSWIndexSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let queryVectorData = args["queryVector"] as? FlutterStandardTypedData,
              let k = args["k"] as? Int,
              let efSearch = args["efSearch"] as? Int? else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float]
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let queryVector: [Float] = queryVectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        // Use the Swift throwing syntax
        do {
            // First set the efSearch parameter if provided
            if let efSearchValue = efSearch {
                try index.setEfSearch(UInt(efSearchValue))
            }
            
            // Then perform the search
            let searchResults = try index.searchVector(queryVector, k: UInt(k))
            let results = searchResults.map { ["id": Int($0.identifier), "distance": $0.distance] }
            result(results)
        } catch {
            result(FlutterError(code: "SEARCH_FAILED", message: "Failed to search HNSW index", details: error.localizedDescription))
        }
    }
    
    /// Handles hnswIndexCount method call
    private func handleHNSWIndexCount(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            let count = try index.size()
            result(Int(count))
        } catch {
            result(FlutterError(code: "COUNT_FAILED", message: "Failed to get count", details: error.localizedDescription))
        }
    }
    
    /// Handles hnswIndexClear method call
    private func handleHNSWIndexClear(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // HNSWIndex doesn't have a clear method in the Objective-C API
        // We'll need to destroy and recreate the index if we want this functionality
        result(FlutterError(code: "METHOD_NOT_AVAILABLE", message: "HNSW index clear is not available", details: nil))
    }
    
    /// Handles hnswIndexDestroy method call
    private func handleHNSWIndexDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes.removeValue(forKey: indexId) else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // No need to explicitly destroy, ARC will handle it
        result(nil)
    }
    
    /// Handles hnswIndexSetEfSearch method call
    private func handleHNSWIndexSetEfSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let efSearch = args["efSearch"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            try index.setEfSearch(UInt(efSearch))
            result(nil)
        } catch {
            result(FlutterError(code: "SET_EF_SEARCH_FAILED", message: "Failed to set efSearch", details: error.localizedDescription))
        }
    }
    
    /// Handles hnswIndexGetEfSearch method call
    private func handleHNSWIndexGetEfSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Use the Swift throwing syntax
        do {
            let efSearch = try index.efSearch()
            result(Int(efSearch))
        } catch {
            result(FlutterError(code: "EFSEARCH_FAILED", message: "Failed to get efSearch", details: error.localizedDescription))
        }
    }
    
    /// Handles hnswIndexDimension method call
    private func handleHNSWIndexDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Use the Objective-C method with proper error handling
        var error: NSError?
        let dimension = index.dimension(&error)
        
        if error != nil {
            result(FlutterError(code: "DIMENSION_FAILED", message: "Failed to get dimension", details: error?.localizedDescription))
            return
        }
        
        result(Int(dimension))
    }
    
    /// Handles hnswIndexCapacity method call
    private func handleHNSWIndexCapacity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Use the Objective-C method with Swift error handling
        do {
            let capacity = try index.capacity()
            result(Int(capacity))
        } catch {
            result(FlutterError(code: "CAPACITY_FAILED", message: "Failed to get capacity", details: error.localizedDescription))
        }
    }
    
    /// Handles hnswIndexContains method call
    private func handleHNSWIndexContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        var containsBool: ObjCBool = false
        var error: NSError?
        guard index.containsIdentifier(UInt64(id), contains: &containsBool, error: &error) else {
            result(FlutterError(code: "CONTAINS_FAILED", message: "Failed to check if vector exists", details: error?.localizedDescription))
            return
        }
        
        result(containsBool.boolValue)
    }
    
    /// Handles hnswIndexGetVector method call
    private func handleHNSWIndexGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        var vector = [Float]()
        var error: NSError?
        
        // Get the dimension first
        let dimension = index.dimension()
        if error != nil {
            result(FlutterError(code: "DIMENSION_FAILED", message: "Failed to get dimension", details: error?.localizedDescription))
            return
        }
        
        // Allocate buffer for vector
        var vectorBuffer = [Float](repeating: 0.0, count: Int(dimension))
        
        guard index.getVectorForIdentifier(UInt64(id), vector: &vectorBuffer, vectorSize: dimension, error: &error) else {
            // If the vector doesn't exist, return nil
            result(nil)
            return
        }
        vector = vectorBuffer
        
        // Convert [Float] to FlutterStandardTypedData
        let vectorData = FlutterStandardTypedData(floats: vector)
        result(vectorData)
    }
    
    /// Handles hnswIndexSave method call
    private func handleHNSWIndexSave(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        var error: NSError?
        guard index.saveToFile(path, error: &error) else {
            result(FlutterError(code: "SAVE_FAILED", message: "Failed to save HNSW index", details: error?.localizedDescription))
            return
        }
        
        result(nil)
    }
    
    /// Handles hnswIndexLoad method call
    private func handleHNSWIndexLoad(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        var error: NSError?
        guard let index = LlamaMobileVDHNSWIndex.loadFromFile(path, error: &error) else {
            result(FlutterError(code: "LOAD_FAILED", message: "Failed to load HNSW index", details: error?.localizedDescription))
            return
        }
        
        let indexId = SwiftLlamaMobileVDPlugin.hnswIndexIdCounter
        SwiftLlamaMobileVDPlugin.hnswIndexIdCounter += 1
        SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] = index
        
        result(indexId)
    }
    
    /// Handles getVersion method call
    private func handleGetVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let version = LlamaMobileVD.version()
        result(version)
    }
    
    // MARK: - MMapVectorStore Methods
    
    /// Handles mmapVectorStoreOpen method call
    private func handleMMapVectorStoreOpen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        var error: NSError?
        guard let store = LlamaMobileVDMMapVectorStore.openFromFile(path, error: &error) else {
            result(FlutterError(code: "OPEN_FAILED", message: "Failed to open MMap vector store", details: error?.localizedDescription))
            return
        }
        
        let storeId = SwiftLlamaMobileVDPlugin.mmapVectorStoreIdCounter
        SwiftLlamaMobileVDPlugin.mmapVectorStoreIdCounter += 1
        SwiftLlamaMobileVDPlugin.mmapVectorStores[storeId] = store
        
        result(storeId)
    }
    
    /// Handles mmapVectorStoreSearch method call
    private func handleMMapVectorStoreSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorData = args["queryVector"] as? FlutterStandardTypedData,
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.mmapVectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "MMap vector store not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let queryVector: [Float] = queryVectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        var error: NSError?
        guard let searchResults = store.searchVector(queryVector, k: k, error: &error) else {
            result(FlutterError(code: "SEARCH_FAILED", message: "Failed to search vectors", details: error?.localizedDescription))
            return
        }
        
        // Convert results to Flutter-compatible format
        var flutterResults: [[String: Any]] = []
        for searchResult in searchResults {
            flutterResults.append([
                "id": Int(searchResult.identifier),
                "distance": searchResult.distance
            ])
        }
        
        result(flutterResults)
    }
    
    /// Handles mmapVectorStoreCount method call
    private func handleMMapVectorStoreCount(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.mmapVectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "MMap vector store not found", details: nil))
            return
        }
        
        var error: NSError?
        let count = store.size()
        if error != nil {
            result(FlutterError(code: "COUNT_FAILED", message: "Failed to get count", details: error?.localizedDescription))
            return
        }
        
        result(Int(count))
    }
    
    /// Handles mmapVectorStoreDimension method call
    private func handleMMapVectorStoreDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.mmapVectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "MMap vector store not found", details: nil))
            return
        }
        
        var error: NSError?
        let dimension = store.dimension()
        if error != nil {
            result(FlutterError(code: "DIMENSION_FAILED", message: "Failed to get dimension", details: error?.localizedDescription))
            return
        }
        
        result(Int(dimension))
    }
    
    /// Handles mmapVectorStoreMetric method call
    private func handleMMapVectorStoreMetric(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.mmapVectorStores[storeId] else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "MMap vector store not found", details: nil))
            return
        }
        
        var error: NSError?
        let metric = store.metric()
        if error != nil {
            result(FlutterError(code: "METRIC_FAILED", message: "Failed to get metric", details: error?.localizedDescription))
            return
        }
        
        result(Int(metric.rawValue))
    }
    
    /// Handles mmapVectorStoreDestroy method call
    private func handleMMapVectorStoreDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let _ = SwiftLlamaMobileVDPlugin.mmapVectorStores.removeValue(forKey: storeId) else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "MMap vector store not found", details: nil))
            return
        }
        
        // No need to explicitly destroy, ARC will handle it
        result(nil)
    }
    
    // MARK: - MMapVectorStoreBuilder Methods
    
    /// Handles mmapVectorStoreBuilderCreate method call
    private func handleMMapVectorStoreBuilderCreate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metricValue = args["metric"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let metric: LlamaMobileVDDistanceMetric
        switch metricValue {
        case 0:
            metric = .l2
        case 1:
            metric = .cosine
        case 2:
            metric = .dot
        default:
            result(FlutterError(code: "INVALID_METRIC", message: "Invalid distance metric", details: nil))
            return
        }
        
        guard let builder = LlamaMobileVDMMapVectorStoreBuilder(dimension: dimension, metric: metric) else {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create MMap vector store builder", details: nil))
            return
        }
        
        let builderId = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilderIdCounter
        SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilderIdCounter += 1
        SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders[builderId] = builder
        
        result(builderId)
    }
    
    /// Handles mmapVectorStoreBuilderAddVector method call
    private func handleMMapVectorStoreBuilderAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let vectorData = args["vector"] as? FlutterStandardTypedData,
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let builder = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders[builderId] else {
            result(FlutterError(code: "BUILDER_NOT_FOUND", message: "MMap vector store builder not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float] using safe buffer access
        let vector: [Float] = vectorData.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let buffer = pointer.bindMemory(to: Float.self)
            return Array<Float>(buffer)
        }
        
        var error: NSError?
        guard builder.addIdentifier(UInt64(id), vector: vector, error: &error) else {
            result(FlutterError(code: "ADD_FAILED", message: "Failed to add vector to MMap vector store builder", details: error?.localizedDescription))
            return
        }
        
        result(nil)
    }
    
    /// Handles mmapVectorStoreBuilderReserveCapacity method call
    private func handleMMapVectorStoreBuilderReserveCapacity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let builder = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders[builderId] else {
            result(FlutterError(code: "BUILDER_NOT_FOUND", message: "MMap vector store builder not found", details: nil))
            return
        }
        
        var error: NSError?
        guard builder.reserveCapacity(UInt64(capacity), error: &error) else {
            result(FlutterError(code: "RESERVE_FAILED", message: "Failed to reserve capacity in MMap vector store builder", details: error?.localizedDescription))
            return
        }
        
        result(nil)
    }
    
    /// Handles mmapVectorStoreBuilderSave method call
    private func handleMMapVectorStoreBuilderSave(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let builder = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders[builderId] else {
            result(FlutterError(code: "BUILDER_NOT_FOUND", message: "MMap vector store builder not found", details: nil))
            return
        }
        
        var error: NSError?
        guard builder.saveToFile(path, error: &error) else {
            result(FlutterError(code: "SAVE_FAILED", message: "Failed to save MMap vector store builder", details: error?.localizedDescription))
            return
        }
        
        result(nil)
    }
    
    /// Handles mmapVectorStoreBuilderSize method call
    private func handleMMapVectorStoreBuilderSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let builder = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders[builderId] else {
            result(FlutterError(code: "BUILDER_NOT_FOUND", message: "MMap vector store builder not found", details: nil))
            return
        }
        
        // Use the Swift API
        result(builder.count)
    }
    
    /// Handles mmapVectorStoreBuilderDimension method call
    private func handleMMapVectorStoreBuilderDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let builder = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders[builderId] else {
            result(FlutterError(code: "BUILDER_NOT_FOUND", message: "MMap vector store builder not found", details: nil))
            return
        }
        
        // Use the Swift API
        result(builder.dimension)
    }
    
    /// Handles mmapVectorStoreBuilderDestroy method call
    private func handleMMapVectorStoreBuilderDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let _ = SwiftLlamaMobileVDPlugin.mmapVectorStoreBuilders.removeValue(forKey: builderId) else {
            result(FlutterError(code: "BUILDER_NOT_FOUND", message: "MMap vector store builder not found", details: nil))
            return
        }
        
        // No need to explicitly destroy, ARC will handle it
        result(nil)
    }
}
