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
            metric = LlamaMobileVDDistanceMetricL2
        case 1:
            metric = LlamaMobileVDDistanceMetricCosine
        case 2:
            metric = LlamaMobileVDDistanceMetricDot
        default:
            result(FlutterError(code: "INVALID_METRIC", message: "Invalid distance metric", details: nil))
            return
        }
        
        var error: NSError?
        guard let store = LlamaMobileVDVectorStoreCreate(Int32(dimension), metric, &error) else {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create vector store", details: error?.localizedDescription))
            return
        }
        
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
        
        // Convert FlutterStandardTypedData to [Float]
        guard let vector = vectorData.float32List else {
            result(FlutterError(code: "INVALID_VECTOR", message: "Invalid vector data", details: nil))
            return
        }
        
        var error: NSError?
        guard LlamaMobileVDVectorStoreAddVector(store, vector, Int32(vector.count), Int32(id), &error) else {
            result(FlutterError(code: "ADD_FAILED", message: "Failed to add vector", details: error?.localizedDescription))
            return
        }
        
        result(nil)
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
        
        // Convert FlutterStandardTypedData to [Float]
        guard let queryVector = queryVectorData.float32List else {
            result(FlutterError(code: "INVALID_VECTOR", message: "Invalid query vector data", details: nil))
            return
        }
        
        var error: NSError?
        var results: UnsafeMutablePointer<LlamaMobileVDSearchResult>?
        var count: Int32 = 0
        
        guard LlamaMobileVDVectorStoreSearch(store, queryVector, Int32(queryVector.count), Int32(k), &results, &count, &error) else {
            result(FlutterError(code: "SEARCH_FAILED", message: "Failed to search vectors", details: error?.localizedDescription))
            return
        }
        
        defer {
            LlamaMobileVDVectorStoreFreeSearchResults(results)
        }
        
        // Convert results to Flutter-compatible format
        var flutterResults: [[String: Any]] = []
        for i in 0..<Int(count) {
            let result = results![i]
            flutterResults.append([
                "id": Int(result.id),
                "distance": result.distance
            ])
        }
        
        result(flutterResults)
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
        
        let count = LlamaMobileVDVectorStoreGetCount(store)
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
        
        var error: NSError?
        guard LlamaMobileVDVectorStoreClear(store, &error) else {
            result(FlutterError(code: "CLEAR_FAILED", message: "Failed to clear vector store", details: error?.localizedDescription))
            return
        }
        
        result(nil)
    }
    
    /// Handles vectorStoreDestroy method call
    private func handleVectorStoreDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let store = SwiftLlamaMobileVDPlugin.vectorStores.removeValue(forKey: storeId) else {
            result(FlutterError(code: "STORE_NOT_FOUND", message: "Vector store not found", details: nil))
            return
        }
        
        LlamaMobileVDVectorStoreDestroy(store)
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
        
        var removed: Int32 = 0
        var error: NSError?
        guard LlamaMobileVDVectorStoreRemove(store, Int32(id), &removed, &error) else {
            result(FlutterError(code: "REMOVE_FAILED", message: "Failed to remove vector", details: error?.localizedDescription))
            return
        }
        
        result(removed != 0)
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
        
        let dimension = LlamaMobileVDVectorStoreDimension(store)
        var vector = [Float](repeating: 0.0, count: Int(dimension))
        var error: NSError?
        
        guard LlamaMobileVDVectorStoreGet(store, Int32(id), &vector, Int32(vector.count), &error) else {
            // If the vector doesn't exist, return nil
            result(nil)
            return
        }
        
        // Convert [Float] to FlutterStandardTypedData.float32List
        let vectorData = FlutterStandardTypedData(float32: vector)
        result(vectorData)
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
        
        // Convert FlutterStandardTypedData to [Float]
        guard let vector = vectorData.float32List else {
            result(FlutterError(code: "INVALID_VECTOR", message: "Invalid vector data", details: nil))
            return
        }
        
        var error: NSError?
        guard LlamaMobileVDVectorStoreUpdate(store, Int32(id), vector, Int32(vector.count), &error) else {
            result(FlutterError(code: "UPDATE_FAILED", message: "Failed to update vector", details: error?.localizedDescription))
            return
        }
        
        result(true)
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
        
        let dimension = LlamaMobileVDVectorStoreDimension(store)
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
        
        let metric = LlamaMobileVDVectorStoreMetric(store)
        result(Int(metric))
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
        
        var contains: Int32 = 0
        var error: NSError?
        guard LlamaMobileVDVectorStoreContains(store, Int32(id), &contains, &error) else {
            result(FlutterError(code: "CONTAINS_FAILED", message: "Failed to check if vector exists", details: error?.localizedDescription))
            return
        }
        
        result(contains != 0)
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
        
        var error: NSError?
        guard LlamaMobileVDVectorStoreReserve(store, Int32(capacity), &error) else {
            result(FlutterError(code: "RESERVE_FAILED", message: "Failed to reserve capacity", details: error?.localizedDescription))
            return
        }
        
        result(nil)
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
            metric = LlamaMobileVDDistanceMetricL2
        case 1:
            metric = LlamaMobileVDDistanceMetricCosine
        case 2:
            metric = LlamaMobileVDDistanceMetricDot
        default:
            result(FlutterError(code: "INVALID_METRIC", message: "Invalid distance metric", details: nil))
            return
        }
        
        var error: NSError?
        guard let index = LlamaMobileVDHNSWIndexCreate(
            Int32(dimension),
            metric,
            Int32(m),
            Int32(efConstruction),
            &error
        ) else {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index", details: error?.localizedDescription))
            return
        }
        
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
        
        // Convert FlutterStandardTypedData to [Float]
        guard let vector = vectorData.float32List else {
            result(FlutterError(code: "INVALID_VECTOR", message: "Invalid vector data", details: nil))
            return
        }
        
        var error: NSError?
        guard LlamaMobileVDHNSWIndexAddVector(index, vector, Int32(vector.count), Int32(id), &error) else {
            result(FlutterError(code: "ADD_FAILED", message: "Failed to add vector to HNSW index", details: error?.localizedDescription))
            return
        }
        
        result(nil)
    }
    
    /// Handles hnswIndexSearch method call
    private func handleHNSWIndexSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let queryVectorData = args["queryVector"] as? FlutterStandardTypedData,
              let k = args["k"] as? Int,
              let efSearch = args["efSearch"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let index = SwiftLlamaMobileVDPlugin.hnswIndexes[indexId] else {
            result(FlutterError(code: "INDEX_NOT_FOUND", message: "HNSW index not found", details: nil))
            return
        }
        
        // Convert FlutterStandardTypedData to [Float]
        guard let queryVector = queryVectorData.float32List else {
            result(FlutterError(code: "INVALID_VECTOR", message: "Invalid query vector data", details: nil))
            return
        }
        
        var error: NSError?
        var results: UnsafeMutablePointer<LlamaMobileVDSearchResult>?
        var count: Int32 = 0
        
        guard LlamaMobileVDHNSWIndexSearch(
            index,
            queryVector,
            Int32(queryVector.count),
            Int32(k),
            Int32(efSearch),
            &results,
            &count,
            &error
        ) else {
            result(FlutterError(code: "SEARCH_FAILED", message: "Failed to search HNSW index", details: error?.localizedDescription))
            return
        }
        
        defer {
            LlamaMobileVDHNSWIndexFreeSearchResults(results)
        }
        
        // Convert results to Flutter-compatible format
        var flutterResults: [[String: Any]] = []
        for i in 0..<Int(count) {
            let result = results![i]
            flutterResults.append([
                "id": Int(result.id),
                "distance": result.distance
            ])
        }
        
        result(flutterResults)
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
        
        let count = LlamaMobileVDHNSWIndexGetCount(index)
        result(Int(count))
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
        
        var error: NSError?
        guard LlamaMobileVDHNSWIndexClear(index, &error) else {
            result(FlutterError(code: "CLEAR_FAILED", message: "Failed to clear HNSW index", details: error?.localizedDescription))
            return
        }
        
        result(nil)
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
        
        LlamaMobileVDHNSWIndexDestroy(index)
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
        
        var error: NSError?
        guard LlamaMobileVDHNSWIndexSetEfSearch(index, Int32(efSearch), &error) else {
            result(FlutterError(code: "SET_EF_SEARCH_FAILED", message: "Failed to set efSearch", details: error?.localizedDescription))
            return
        }
        
        result(nil)
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
        
        let efSearch = LlamaMobileVDHNSWIndexGetEfSearch(index)
        result(Int(efSearch))
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
        
        let dimension = LlamaMobileVDHNSWIndexDimension(index)
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
        
        let capacity = LlamaMobileVDHNSWIndexCapacity(index)
        result(Int(capacity))
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
        
        var contains: Int32 = 0
        var error: NSError?
        guard LlamaMobileVDHNSWIndexContains(index, Int32(id), &contains, &error) else {
            result(FlutterError(code: "CONTAINS_FAILED", message: "Failed to check if vector exists", details: error?.localizedDescription))
            return
        }
        
        result(contains != 0)
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
        
        let dimension = LlamaMobileVDHNSWIndexDimension(index)
        var vector = [Float](repeating: 0.0, count: Int(dimension))
        var error: NSError?
        
        guard LlamaMobileVDHNSWIndexGetVector(index, Int32(id), &vector, Int32(vector.count), &error) else {
            // If the vector doesn't exist, return nil
            result(nil)
            return
        }
        
        // Convert [Float] to FlutterStandardTypedData.float32List
        let vectorData = FlutterStandardTypedData(float32: vector)
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
        guard LlamaMobileVDHNSWIndexSave(index, path, &error) else {
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
        guard let index = LlamaMobileVDHNSWIndexLoad(path, &error) else {
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
        let version = LlamaMobileVDGetVersion()
        result(version)
    }
}
