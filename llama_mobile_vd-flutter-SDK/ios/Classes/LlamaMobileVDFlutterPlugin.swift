import Flutter
import UIKit

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
        case "vectorStoreCreateAsync":
            handleVectorStoreCreateAsync(call, result: result)
        case "vectorStoreAddVector":
            handleVectorStoreAddVector(call, result: result)
        case "vectorStoreAddVectorAsync":
            handleVectorStoreAddVectorAsync(call, result: result)
        case "vectorStoreSearch":
            handleVectorStoreSearch(call, result: result)
        case "vectorStoreSearchAsync":
            handleVectorStoreSearchAsync(call, result: result)
        case "vectorStoreGetVector":
            handleVectorStoreGetVector(call, result: result)
        case "vectorStoreRemoveVector":
            handleVectorStoreRemoveVector(call, result: result)
        case "vectorStoreRemoveVectorAsync":
            handleVectorStoreRemoveVectorAsync(call, result: result)
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
        case "vectorStoreUpdateVectorAsync":
            handleVectorStoreUpdateVectorAsync(call, result: result)
        case "vectorStoreReserve":
            handleVectorStoreReserve(call, result: result)
        case "vectorStoreReserveAsync":
            handleVectorStoreReserveAsync(call, result: result)
        case "vectorStoreClear":
            handleVectorStoreClear(call, result: result)
        case "vectorStoreClearAsync":
            handleVectorStoreClearAsync(call, result: result)
        case "vectorStoreDestroy":
            handleVectorStoreDestroy(call, result: result)
        // HNSWIndex methods
        case "hnswIndexCreate":
            handleHNSWIndexCreate(call, result: result)
        case "hnswIndexCreateAsync":
            handleHNSWIndexCreateAsync(call, result: result)
        case "hnswIndexCreateWithParams":
            handleHNSWIndexCreateWithParams(call, result: result)
        case "hnswIndexCreateWithParamsAsync":
            handleHNSWIndexCreateWithParamsAsync(call, result: result)
        case "hnswIndexAddVector":
            handleHNSWIndexAddVector(call, result: result)
        case "hnswIndexAddVectorAsync":
            handleHNSWIndexAddVectorAsync(call, result: result)
        case "hnswIndexSearch":
            handleHNSWIndexSearch(call, result: result)
        case "hnswIndexSearchAsync":
            handleHNSWIndexSearchAsync(call, result: result)
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
        case "hnswIndexSaveAsync":
            handleHNSWIndexSaveAsync(call, result: result)
        case "hnswIndexLoad":
            handleHNSWIndexLoad(call, result: result)
        case "hnswIndexLoadAsync":
            handleHNSWIndexLoadAsync(call, result: result)
        case "hnswIndexDestroy":
            handleHNSWIndexDestroy(call, result: result)
        // MMapVectorStoreBuilder methods
        case "mmapVectorStoreBuilderCreate":
            handleMMapVectorStoreBuilderCreate(call, result: result)
        case "mmapVectorStoreBuilderCreateAsync":
            handleMMapVectorStoreBuilderCreateAsync(call, result: result)
        case "mmapVectorStoreBuilderAddVector":
            handleMMapVectorStoreBuilderAddVector(call, result: result)
        case "mmapVectorStoreBuilderAddVectorAsync":
            handleMMapVectorStoreBuilderAddVectorAsync(call, result: result)
        case "mmapVectorStoreBuilderReserve":
            handleMMapVectorStoreBuilderReserve(call, result: result)
        case "mmapVectorStoreBuilderReserveAsync":
            handleMMapVectorStoreBuilderReserveAsync(call, result: result)
        case "mmapVectorStoreBuilderSave":
            handleMMapVectorStoreBuilderSave(call, result: result)
        case "mmapVectorStoreBuilderSaveAsync":
            handleMMapVectorStoreBuilderSaveAsync(call, result: result)
        case "mmapVectorStoreBuilderGetSize":
            handleMMapVectorStoreBuilderGetSize(call, result: result)
        case "mmapVectorStoreBuilderGetDimension":
            handleMMapVectorStoreBuilderGetDimension(call, result: result)
        case "mmapVectorStoreBuilderDestroy":
            handleMMapVectorStoreBuilderDestroy(call, result: result)
        // MMapVectorStore methods
        case "mmapVectorStoreOpen":
            handleMMapVectorStoreOpen(call, result: result)
        case "mmapVectorStoreOpenAsync":
            handleMMapVectorStoreOpenAsync(call, result: result)
        case "mmapVectorStoreGetVector":
            handleMMapVectorStoreGetVector(call, result: result)
        case "mmapVectorStoreContains":
            handleMMapVectorStoreContains(call, result: result)
        case "mmapVectorStoreSearch":
            handleMMapVectorStoreSearch(call, result: result)
        case "mmapVectorStoreSearchAsync":
            handleMMapVectorStoreSearchAsync(call, result: result)
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
        case "getVersionMajor":
            handleGetVersionMajor(call, result: result)
        case "getVersionMinor":
            handleGetVersionMinor(call, result: result)
        case "getVersionPatch":
            handleGetVersionPatch(call, result: result)
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

        do {
            let distanceMetric = mapMetric(metric)
            let store = try LlamaMobileVD.VectorStore(dimension: dimension, metric: distanceMetric)
            let storeId = generateId()
            vectorStoreMap[storeId] = store
            result(storeId)
        } catch {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create vector store: \(error)", details: nil))
        }
    }

    private func handleVectorStoreCreateAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let distanceMetric = self.mapMetric(metric)
                let store = try LlamaMobileVD.VectorStore(dimension: dimension, metric: distanceMetric)
                let storeId = self.generateId()
                self.vectorStoreMap[storeId] = store
                DispatchQueue.main.async {
                    result(storeId)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CREATE_FAILED", message: "Failed to create vector store: \(error)", details: nil))
                }
            }
        }
    }

    private func handleVectorStoreAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.addVector(id: id, vector: vector)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleVectorStoreAddVectorAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.addVector(id: id, vector: vector)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleVectorStoreSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        do {
            let results = try store.search(query: queryVector, k: k)
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            result(flutterResults)
        } catch {
            result(FlutterError(code: "SEARCH_FAILED", message: "Search failed: \(error)", details: nil))
        }
    }

    private func handleVectorStoreSearchAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let results = try store.search(query: queryVector, k: k)
                let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
                // Call result on main thread
                DispatchQueue.main.async {
                    result(flutterResults)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "SEARCH_FAILED", message: "Search failed: \(error)", details: nil))
                }
            }
        }
    }

    private func handleVectorStoreGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            let vector = try store.getVector(id: id)
            result(vector)
        } catch {
            result(nil) // Return nil if vector not found
        }
    }

    private func handleVectorStoreRemoveVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            let removed = try store.removeVector(id: id)
            result(removed)
        } catch {
            result(false)
        }
    }

    private func handleVectorStoreRemoveVectorAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let removed = try store.removeVector(id: id)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(removed)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleVectorStoreContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            let contains = try store.containsVector(id: id)
            result(contains)
        } catch {
            result(false)
        }
    }

    private func handleVectorStoreGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            let size = try store.count()
            result(size)
        } catch {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size: \(error)", details: nil))
        }
    }

    private func handleVectorStoreGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            let dimension = try store.dimension()
            result(dimension)
        } catch {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension: \(error)", details: nil))
        }
    }

    private func handleVectorStoreGetMetric(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            let metric = try store.metric()
            result(mapMetric(metric))
        } catch {
            result(FlutterError(code: "METRIC_ERROR", message: "Failed to get metric: \(error)", details: nil))
        }
    }

    private func handleVectorStoreUpdateVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        do {
            try store.updateVector(id: id, vector: vector)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleVectorStoreUpdateVectorAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.updateVector(id: id, vector: vector)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleVectorStoreReserve(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            try store.reserveCapacity(capacity: capacity)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleVectorStoreReserveAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.reserveCapacity(capacity: capacity)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleVectorStoreClear(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        do {
            try store.clear()
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleVectorStoreClearAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.clear()
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleVectorStoreDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let _ = vectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid vector store", details: nil))
            return
        }

        // Remove from map - Swift will handle deallocation
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

        do {
            let distanceMetric = mapMetric(metric)
            let index = try LlamaMobileVD.HNSWIndex(
                dimension: dimension,
                metric: distanceMetric,
                maxElements: maxElements
            )
            let indexId = generateId()
            hnswIndexMap[indexId] = index
            result(indexId)
        } catch {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexCreateAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int,
              let maxElements = args["maxElements"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let distanceMetric = self.mapMetric(metric)
                let index = try LlamaMobileVD.HNSWIndex(
                    dimension: dimension,
                    metric: distanceMetric,
                    maxElements: maxElements
                )
                let indexId = self.generateId()
                self.hnswIndexMap[indexId] = index
                // Call result on main thread
                DispatchQueue.main.async {
                    result(indexId)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index: \(error)", details: nil))
                }
            }
        }
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

        do {
            let distanceMetric = mapMetric(metric)
            let index = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: distanceMetric, maxElements: maxElements, m: M, efConstruction: efConstruction, seed: UInt32(seed))
            let indexId = generateId()
            hnswIndexMap[indexId] = index
            result(indexId)
        } catch {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexCreateWithParamsAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let distanceMetric = self.mapMetric(metric)
                let index = try LlamaMobileVD.HNSWIndex(dimension: dimension, metric: distanceMetric, maxElements: maxElements, m: M, efConstruction: efConstruction, seed: UInt32(seed))
                let indexId = self.generateId()
                self.hnswIndexMap[indexId] = index
                // Call result on main thread
                DispatchQueue.main.async {
                    result(indexId)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "CREATE_FAILED", message: "Failed to create HNSW index: \(error)", details: nil))
                }
            }
        }
    }

    private func handleHNSWIndexAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try index.addVector(id: id, vector: vector)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleHNSWIndexAddVectorAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try index.addVector(id: id, vector: vector)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleHNSWIndexSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        do {
            let results = try index.search(query: queryVector, k: k)
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            result(flutterResults)
        } catch {
            result(FlutterError(code: "SEARCH_FAILED", message: "Search failed: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexSearchAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let results = try index.search(query: queryVector, k: k)
                let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
                // Call result on main thread
                DispatchQueue.main.async {
                    result(flutterResults)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "SEARCH_FAILED", message: "Search failed: \(error)", details: nil))
                }
            }
        }
    }

    private func handleHNSWIndexSetEfSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let efSearch = args["efSearch"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            try index.setEfSearch(efSearch)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleHNSWIndexGetEfSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            let efSearch = try index.getEfSearch()
            result(efSearch)
        } catch {
            result(FlutterError(code: "EF_SEARCH_ERROR", message: "Failed to get ef_search: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            let size = try index.count()
            result(size)
        } catch {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            let dimension = try index.dimension()
            result(dimension)
        } catch {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexGetCapacity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            let capacity = try index.capacity()
            result(capacity)
        } catch {
            result(FlutterError(code: "CAPACITY_ERROR", message: "Failed to get capacity: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            let contains = try index.contains(id: id)
            result(contains)
        } catch {
            result(false)
        }
    }

    private func handleHNSWIndexGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            let vector = try index.getVector(id: id)
            result(vector)
        } catch {
            result(nil) // Return nil if vector not found
        }
    }

    private func handleHNSWIndexSave(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        do {
            try index.save(to: filename)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleHNSWIndexSaveAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int,
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let index = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try index.save(to: filename)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleHNSWIndexLoad(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        do {
            let index = try LlamaMobileVD.HNSWIndex.load(from: filename)
            let indexId = generateId()
            hnswIndexMap[indexId] = index
            result(indexId)
        } catch {
            result(FlutterError(code: "LOAD_FAILED", message: "Failed to load HNSW index: \(error)", details: nil))
        }
    }

    private func handleHNSWIndexLoadAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let index = try LlamaMobileVD.HNSWIndex.load(from: filename)
                let indexId = self.generateId()
                self.hnswIndexMap[indexId] = index
                // Call result on main thread
                DispatchQueue.main.async {
                    result(indexId)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "LOAD_FAILED", message: "Failed to load HNSW index: \(error)", details: nil))
                }
            }
        }
    }

    private func handleHNSWIndexDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let indexId = args["indexId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let _ = hnswIndexMap[indexId] else {
            result(FlutterError(code: "INVALID_INDEX", message: "Invalid HNSW index", details: nil))
            return
        }

        // Remove from map - Swift will handle deallocation
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

        do {
            let distanceMetric = mapMetric(metric)
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: distanceMetric)
            let builderId = generateId()
            mmapVectorStoreBuilderMap[builderId] = builder
            result(builderId)
        } catch {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create MMapVectorStoreBuilder: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreBuilderCreateAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dimension = args["dimension"] as? Int,
              let metric = args["metric"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let distanceMetric = self.mapMetric(metric)
                let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: distanceMetric)
                let builderId = self.generateId()
                self.mmapVectorStoreBuilderMap[builderId] = builder
                // Call result on main thread
                DispatchQueue.main.async {
                    result(builderId)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "CREATE_FAILED", message: "Failed to create MMapVectorStoreBuilder: \(error)", details: nil))
                }
            }
        }
    }

    private func handleMMapVectorStoreBuilderAddVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        do {
            try builder.addVector(id: id, vector: vector)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleMMapVectorStoreBuilderAddVectorAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let id = args["id"] as? UInt64,
              let vectorDouble = args["vector"] as? [Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let vector = vectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try builder.addVector(id: id, vector: vector)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleMMapVectorStoreBuilderReserve(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        do {
            try builder.reserve(capacity: capacity)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleMMapVectorStoreBuilderReserveAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let capacity = args["capacity"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try builder.reserve(capacity: capacity)
                // Call result on main thread
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleMMapVectorStoreBuilderSave(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        do {
            try builder.save(to: filename)
            // Remove builder after save
            mmapVectorStoreBuilderMap.removeValue(forKey: builderId)
            result(true)
        } catch {
            result(false)
        }
    }

    private func handleMMapVectorStoreBuilderSaveAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int,
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try builder.save(to: filename)
                // Remove builder after save on main thread
                DispatchQueue.main.async {
                    self.mmapVectorStoreBuilderMap.removeValue(forKey: builderId)
                    result(true)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(false)
                }
            }
        }
    }

    private func handleMMapVectorStoreBuilderGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        do {
            let size = try builder.count()
            result(size)
        } catch {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreBuilderGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        do {
            let dimension = try builder.dimension()
            result(dimension)
        } catch {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreBuilderDestroy(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let builderId = args["builderId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let _ = mmapVectorStoreBuilderMap[builderId] else {
            result(FlutterError(code: "INVALID_BUILDER", message: "Invalid MMapVectorStoreBuilder", details: nil))
            return
        }

        // Remove from map - Swift will handle deallocation
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

        do {
            let store = try LlamaMobileVD.MMapVectorStore.open(from: filename)
            let storeId = generateId()
            mmapVectorStoreMap[storeId] = store
            result(storeId)
        } catch {
            result(FlutterError(code: "OPEN_FAILED", message: "Failed to open MMapVectorStore: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreOpenAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filename = args["filename"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let store = try LlamaMobileVD.MMapVectorStore.open(from: filename)
                let storeId = self.generateId()
                // Store on main thread
                DispatchQueue.main.async {
                    self.mmapVectorStoreMap[storeId] = store
                    result(storeId)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "OPEN_FAILED", message: "Failed to open MMapVectorStore: \(error)", details: nil))
                }
            }
        }
    }

    private func handleMMapVectorStoreGetVector(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        do {
            let vector = try store.getVector(id: id)
            result(vector)
        } catch {
            result(nil) // Return nil if vector not found
        }
    }

    private func handleMMapVectorStoreContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let id = args["id"] as? UInt64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        do {
            let contains = try store.contains(id: id)
            result(contains)
        } catch {
            result(false)
        }
    }

    private func handleMMapVectorStoreSearch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        do {
            let results = try store.search(query: queryVector, k: k)
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            result(flutterResults)
        } catch {
            result(FlutterError(code: "SEARCH_FAILED", message: "Search failed: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreSearchAsync(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int,
              let queryVectorDouble = args["queryVector"] as? [Double],
              let k = args["k"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        // Convert [Double] to [Float]
        let queryVector = queryVectorDouble.map { Float($0) }

        // Execute on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let results = try store.search(query: queryVector, k: k)
                let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
                // Call result on main thread
                DispatchQueue.main.async {
                    result(flutterResults)
                }
            } catch {
                // Call result on main thread
                DispatchQueue.main.async {
                    result(FlutterError(code: "SEARCH_FAILED", message: "Search failed: \(error)", details: nil))
                }
            }
        }
    }

    private func handleMMapVectorStoreGetSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        do {
            let size = try store.count()
            result(size)
        } catch {
            result(FlutterError(code: "SIZE_ERROR", message: "Failed to get size: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreGetDimension(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        do {
            let dimension = try store.dimension()
            result(dimension)
        } catch {
            result(FlutterError(code: "DIMENSION_ERROR", message: "Failed to get dimension: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreGetMetric(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let store = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        do {
            let metric = try store.metric()
            result(mapMetric(metric))
        } catch {
            result(FlutterError(code: "METRIC_ERROR", message: "Failed to get metric: \(error)", details: nil))
        }
    }

    private func handleMMapVectorStoreClose(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let storeId = args["storeId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let _ = mmapVectorStoreMap[storeId] else {
            result(FlutterError(code: "INVALID_STORE", message: "Invalid MMapVectorStore", details: nil))
            return
        }

        // Remove from map - Swift will handle deallocation
        mmapVectorStoreMap.removeValue(forKey: storeId)
        result(true)
    }

    // MARK: - Version methods
    private func handleGetVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let version = LlamaMobileVD.Version.full
        result(version)
    }

    private func handleGetVersionMajor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let major = LlamaMobileVD.Version.major
        result(major)
    }

    private func handleGetVersionMinor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let minor = LlamaMobileVD.Version.minor
        result(minor)
    }

    private func handleGetVersionPatch(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let patch = LlamaMobileVD.Version.patch
        result(patch)
    }

    // MARK: - Helper methods
    // Storage for our objects
    private var vectorStoreMap: [Int: LlamaMobileVD.VectorStore] = [:]
    private var hnswIndexMap: [Int: LlamaMobileVD.HNSWIndex] = [:]
    private var mmapVectorStoreBuilderMap: [Int: LlamaMobileVD.MMapVectorStoreBuilder] = [:]
    private var mmapVectorStoreMap: [Int: LlamaMobileVD.MMapVectorStore] = [:]
    private var nextId = 1

    // Helper method to generate unique IDs
    private func generateId() -> Int {
        let id = nextId
        nextId += 1
        return id
    }

    // Helper method to map metric integers to enum
    private func mapMetric(_ metric: Int) -> LlamaMobileVD.DistanceMetric {
        switch metric {
        case 0:
            return .l2
        case 1:
            return .cosine
        case 2:
            return .dot
        default:
            return .l2
        }
    }

    // Helper method to map metric enum to integer
    private func mapMetric(_ metric: LlamaMobileVD.DistanceMetric) -> Int {
        switch metric {
        case .l2:
            return 0
        case .cosine:
            return 1
        case .dot:
            return 2
        }
    }


}
