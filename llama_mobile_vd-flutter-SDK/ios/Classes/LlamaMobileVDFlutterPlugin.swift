import Flutter
import UIKit
import llama_mobile_vd

public class LlamaMobileVDFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "llama_mobile_vd_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = LlamaMobileVDFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS \(UIDevice.current.systemVersion)")
        // VectorStore methods
        case "vectorStoreCreate":
            handleVectorStoreCreate(call, result: result)
        case "vectorStoreAddVector":
            handleVectorStoreAddVector(call, result: result)
        case "vectorStoreSearch":
            handleVectorStoreSearch(call, result: result)
        case "vectorStoreGetVector":
            handleVectorStoreGetVector(call, result: result)
        case "vectorStoreRemoveVector":
            handleVectorStoreRemoveVector(call, result: result)
        case "vectorStoreContains":
            handleVectorStoreContains(call, result: result)
        case "vectorStoreGetSize":
            handleVectorStoreGetSize(call, result: result)
        case "vectorStoreGetDimension":
            handleVectorStoreGetDimension(call, result: result)
        case "vectorStoreGetMetric":
            handleVectorStoreGetMetric(call, result: result)
        case "vectorStoreUpdateVector":
            handleVectorStoreUpdateVector(call, result: result)
        case "vectorStoreReserve":
            handleVectorStoreReserve(call, result: result)
        case "vectorStoreClear":
            handleVectorStoreClear(call, result: result)
        case "vectorStoreDestroy":
            handleVectorStoreDestroy(call, result: result)
        // HNSWIndex methods
        case "hnswIndexCreate":
            handleHNSWIndexCreate(call, result: result)
        case "hnswIndexCreateWithParams":
            handleHNSWIndexCreateWithParams(call, result: result)
        case "hnswIndexAddVector":
            handleHNSWIndexAddVector(call, result: result)
        case "hnswIndexSearch":
            handleHNSWIndexSearch(call, result: result)
        case "hnswIndexSetEfSearch":
            handleHNSWIndexSetEfSearch(call, result: result)
        case "hnswIndexGetEfSearch":
            handleHNSWIndexGetEfSearch(call, result: result)
        case "hnswIndexGetSize":
            handleHNSWIndexGetSize(call, result: result)
        case "hnswIndexGetDimension":
            handleHNSWIndexGetDimension(call, result: result)
        case "hnswIndexGetCapacity":
            handleHNSWIndexGetCapacity(call, result: result)
        case "hnswIndexContains":
            handleHNSWIndexContains(call, result: result)
        case "hnswIndexGetVector":
            handleHNSWIndexGetVector(call, result: result)
        case "hnswIndexSave":
            handleHNSWIndexSave(call, result: result)
        case "hnswIndexLoad":
            handleHNSWIndexLoad(call, result: result)
        case "hnswIndexDestroy":
            handleHNSWIndexDestroy(call, result: result)
        // MMapVectorStoreBuilder methods
        case "mmapVectorStoreBuilderCreate":
            handleMMapVectorStoreBuilderCreate(call, result: result)
        case "mmapVectorStoreBuilderAddVector":
            handleMMapVectorStoreBuilderAddVector(call, result: result)
        case "mmapVectorStoreBuilderReserve":
            handleMMapVectorStoreBuilderReserve(call, result: result)
        case "mmapVectorStoreBuilderSave":
            handleMMapVectorStoreBuilderSave(call, result: result)
        case "mmapVectorStoreBuilderGetSize":
            handleMMapVectorStoreBuilderGetSize(call, result: result)
        case "mmapVectorStoreBuilderGetDimension":
            handleMMapVectorStoreBuilderGetDimension(call, result: result)
        case "mmapVectorStoreBuilderDestroy":
            handleMMapVectorStoreBuilderDestroy(call, result: result)
        // MMapVectorStore methods
        case "mmapVectorStoreOpen":
            handleMMapVectorStoreOpen(call, result: result)
        case "mmapVectorStoreGetVector":
            handleMMapVectorStoreGetVector(call, result: result)
        case "mmapVectorStoreContains":
            handleMMapVectorStoreContains(call, result: result)
        case "mmapVectorStoreSearch":
            handleMMapVectorStoreSearch(call, result: result)
        case "mmapVectorStoreGetSize":
            handleMMapVectorStoreGetSize(call, result: result)
        case "mmapVectorStoreGetDimension":
            handleMMapVectorStoreGetDimension(call, result: result)
        case "mmapVectorStoreGetMetric":
            handleMMapVectorStoreGetMetric(call, result: result)
        case "mmapVectorStoreClose":
            handleMMapVectorStoreClose(call, result: result)
        // Version methods
        case "getVersion":
            handleGetVersion(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - VectorStore methods
    private func handleVectorStoreCreate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        var storePtr: LLAMA_MOBILE_VD_VectorStore?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_vector_store_create(dimension, cMetric, &storePtr)
        
        if error != LLAMA_MOBILE_VD_OK || storePtr == nil {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create vector store", details: nil))
            return
        }

        // Store the pointer as an integer
        let storeId = Int(bitPattern: storePtr!)
        vectorStoreMap[storeId] = storePtr
        result(storeId)
    }

    private func handleVectorStoreAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Get the store pointer from the id
        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        let error = llama_mobile_vd_vector_store_add(store, id, vector)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleVectorStoreSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_vector_store_search(store, queryVector, k, &results, k)
        
        // Debug prints
        print("VectorStore search error: \(error)")
        print("Query vector: \(queryVector)")
        print("Search results: \(results)")
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SEARCH_FAILED", message: "Search failed", details: nil))
            return
        }

        // Convert results to Flutter-compatible format
        let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
        result(flutterResults)
    }

    private func handleVectorStoreGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_vector_store_dimension(store, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_vector_store_get(store, id, &vector, dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(nil) // Return nil if vector not found
            return
        }

        result(vector)
    }

    private func handleVectorStoreRemoveVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        var removed: Int32 = 0
        let error = llama_mobile_vd_vector_store_remove(store, id, &removed)
        
        result(error == LLAMA_MOBILE_VD_OK && removed != 0)
    }

    private func handleVectorStoreContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_vector_store_contains(store, id, &contains)
        
        result(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    private func handleVectorStoreGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_vector_store_size(store, &size)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size", details: nil))
            return
        }

        result(size)
    }

    private func handleVectorStoreGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_vector_store_dimension(store, &dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        result(dimension)
    }

    private func handleVectorStoreGetMetric(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        var metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
        let error = llama_mobile_vd_vector_store_metric(store, &metric)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "METRIC_ERROR", message: "Failed to get metric", details: nil))
            return
        }

        result(Int(metric.rawValue))
    }

    private func handleVectorStoreUpdateVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        let error = llama_mobile_vd_vector_store_update(store, id, vector)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleVectorStoreReserve(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        let error = llama_mobile_vd_vector_store_reserve(store, capacity)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleVectorStoreClear(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        let error = llama_mobile_vd_vector_store_clear(store)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleVectorStoreDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        llama_mobile_vd_vector_store_destroy(store)
        // Remove from our storage
        vectorStoreMap.removeValue(forKey: storeId)
        result(true)
    }

    // MARK: - HNSWIndex methods
    private func handleHNSWIndexCreate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int,
              let maxElements = args["maxElements"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_hnsw_index_create(
            dimension,
            cMetric,
            maxElements,
            &indexPtr
        )
        
        if error != LLAMA_MOBILE_VD_OK || indexPtr == nil {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index", details: nil))
            return
        }

        let indexId = Int(bitPattern: indexPtr!)
        hnswIndexMap[indexId] = indexPtr
        result(indexId)
    }

    private func handleHNSWIndexCreateWithParams(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int,
              let maxElements = args["maxElements"] as? Int,
              let M = args["M"] as? Int,
              let efConstruction = args["efConstruction"] as? Int,
              let seed = args["seed"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_hnsw_index_create_with_params(
            dimension,
            cMetric,
            maxElements,
            M,
            efConstruction,
            UInt32(seed),
            &indexPtr
        )
        
        if error != LLAMA_MOBILE_VD_OK || indexPtr == nil {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index", details: nil))
            return
        }

        let indexId = Int(bitPattern: indexPtr!)
        hnswIndexMap[indexId] = indexPtr
        result(indexId)
    }

    private func handleHNSWIndexAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        let error = llama_mobile_vd_hnsw_index_add(index, id, vector)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleHNSWIndexSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_hnsw_index_search(
            index,
            queryVector,
            k,
            &results,
            k
        )
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SEARCH_FAILED", message: "Search failed", details: nil))
            return
        }

        let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
        result(flutterResults)
    }

    private func handleHNSWIndexSetEfSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let efSearch = args["efSearch"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        let error = llama_mobile_vd_hnsw_index_set_ef_search(index, efSearch)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleHNSWIndexGetEfSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        var efSearch: Int = 0
        let error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "EF_SEARCH_ERROR", message: "Failed to get ef_search", details: nil))
            return
        }

        result(efSearch)
    }

    private func handleHNSWIndexGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_hnsw_index_size(index, &size)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size", details: nil))
            return
        }

        result(size)
    }

    private func handleHNSWIndexGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        result(dimension)
    }

    private func handleHNSWIndexGetCapacity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        var capacity: Int = 0
        let error = llama_mobile_vd_hnsw_index_capacity(index, &capacity)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "CAPACITY_ERROR", message: "Failed to get capacity", details: nil))
            return
        }

        result(capacity)
    }

    private func handleHNSWIndexContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_hnsw_index_contains(index, id, &contains)
        
        result(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    private func handleHNSWIndexGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_hnsw_index_get_vector(index, id, &vector, dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(nil) // Return nil if vector not found
            return
        }

        result(vector)
    }

    private func handleHNSWIndexSave(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        let error = llama_mobile_vd_hnsw_index_save(index, filename)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleHNSWIndexLoad(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let error = llama_mobile_vd_hnsw_index_load(filename, &indexPtr)
        
        if error != LLAMA_MOBILE_VD_OK || indexPtr == nil {
            result(FlutterError(code: "LOAD_FAILED", message: "Failed to load HNSW index", details: nil))
            return
        }

        let indexId = Int(bitPattern: indexPtr!)
        hnswIndexMap[indexId] = indexPtr
        result(indexId)
    }

    private func handleHNSWIndexDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = getHNSWIndex(from: indexId) else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        llama_mobile_vd_hnsw_index_destroy(index)
        hnswIndexMap.removeValue(forKey: indexId)
        result(true)
    }

    // MARK: - MMapVectorStoreBuilder methods
    private func handleMMapVectorStoreBuilderCreate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        var builderPtr: LLAMA_MOBILE_VD_MMapVectorStoreBuilder?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_mmap_vector_store_builder_create(
            dimension,
            cMetric,
            &builderPtr
        )
        
        if error != LLAMA_MOBILE_VD_OK || builderPtr == nil {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create MMapVectorStoreBuilder", details: nil))
            return
        }

        let builderId = Int(bitPattern: builderPtr!)
        mmapVectorStoreBuilderMap[builderId] = builderPtr
        result(builderId)
    }

    private func handleMMapVectorStoreBuilderAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = getMMapVectorStoreBuilder(from: builderId) else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        let error = llama_mobile_vd_mmap_vector_store_builder_add(builder, id, vector)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleMMapVectorStoreBuilderReserve(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = getMMapVectorStoreBuilder(from: builderId) else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, capacity)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleMMapVectorStoreBuilderSave(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = getMMapVectorStoreBuilder(from: builderId) else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filename)
        result(error == LLAMA_MOBILE_VD_OK)
    }

    private func handleMMapVectorStoreBuilderGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = getMMapVectorStoreBuilder(from: builderId) else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size", details: nil))
            return
        }

        result(size)
    }

    private func handleMMapVectorStoreBuilderGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = getMMapVectorStoreBuilder(from: builderId) else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        result(dimension)
    }

    private func handleMMapVectorStoreBuilderDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = getMMapVectorStoreBuilder(from: builderId) else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        llama_mobile_vd_mmap_vector_store_builder_destroy(builder)
        mmapVectorStoreBuilderMap.removeValue(forKey: builderId)
        result(true)
    }

    // MARK: - MMapVectorStore methods
    private func handleMMapVectorStoreOpen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        var storePtr: LLAMA_MOBILE_VD_MMapVectorStore?
        let error = llama_mobile_vd_mmap_vector_store_open(filename, &storePtr)
        
        if error != LLAMA_MOBILE_VD_OK || storePtr == nil {
            result(FlutterError(code: "OPEN_FAILED", message: "Failed to open MMapVectorStore", details: nil))
            return
        }

        let storeId = Int(bitPattern: storePtr!)
        mmapVectorStoreMap[storeId] = storePtr
        result(storeId)
    }

    private func handleMMapVectorStoreGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_mmap_vector_store_get(store, id, &vector, dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(nil) // Return nil if vector not found
            return
        }

        result(vector)
    }

    private func handleMMapVectorStoreContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_mmap_vector_store_contains(store, id, &contains)
        
        result(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    private func handleMMapVectorStoreSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_mmap_vector_store_search(
            store,
            queryVector,
            k,
            &results,
            k
        )
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SEARCH_FAILED", message: "Search failed", details: nil))
            return
        }

        let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
        result(flutterResults)
    }

    private func handleMMapVectorStoreGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_size(store, &size)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size", details: nil))
            return
        }

        result(size)
    }

    private func handleMMapVectorStoreGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension", details: nil))
            return
        }

        result(dimension)
    }

    private func handleMMapVectorStoreGetMetric(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        var metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
        let error = llama_mobile_vd_mmap_vector_store_metric(store, &metric)
        
        if error != LLAMA_MOBILE_VD_OK {
            result(FlutterError(code: "METRIC_ERROR", message: "Failed to get metric", details: nil))
            return
        }

        result(Int(metric.rawValue))
    }

    private func handleMMapVectorStoreClose(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = getMMapVectorStore(from: storeId) else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        llama_mobile_vd_mmap_vector_store_close(store)
        mmapVectorStoreMap.removeValue(forKey: storeId)
        result(true)
    }

    // MARK: - Version methods
    private func handleGetVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let version = llama_mobile_vd_version()
        if let versionStr = version {
            result(String(cString: versionStr))
        } else {
            result(FlutterError(code: "VERSION_ERROR", message: "Failed to get version", details: nil))
        }
    }

    // MARK: - Helper methods
    // Storage for our pointers
    private var vectorStoreMap: [Int: LLAMA_MOBILE_VD_VectorStore] = [:]
    private var hnswIndexMap: [Int: LLAMA_MOBILE_VD_HNSWIndex] = [:]
    private var mmapVectorStoreBuilderMap: [Int: LLAMA_MOBILE_VD_MMapVectorStoreBuilder] = [:]
    private var mmapVectorStoreMap: [Int: LLAMA_MOBILE_VD_MMapVectorStore] = [:]

    private func getVectorStore(from id: Int) -> LLAMA_MOBILE_VD_VectorStore? {
        return vectorStoreMap[id]
    }

    private func getHNSWIndex(from id: Int) -> LLAMA_MOBILE_VD_HNSWIndex? {
        return hnswIndexMap[id]
    }

    private func getMMapVectorStoreBuilder(from id: Int) -> LLAMA_MOBILE_VD_MMapVectorStoreBuilder? {
        return mmapVectorStoreBuilderMap[id]
    }

    private func getMMapVectorStore(from id: Int) -> LLAMA_MOBILE_VD_MMapVectorStore? {
        return mmapVectorStoreMap[id]
    }
}
