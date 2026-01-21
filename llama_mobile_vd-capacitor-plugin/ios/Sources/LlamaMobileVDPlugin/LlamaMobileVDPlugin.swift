/**
 * iOS implementation of the LlamaMobileVD Capacitor Plugin
 * A high-performance vector database for mobile applications
 */

import Foundation
import Capacitor
import LlamaMobileVD

/**
 * LlamaMobileVD Capacitor Plugin for iOS
 */
@objc(LlamaMobileVDPlugin)
public class LlamaMobileVDPlugin: CAPPlugin, CAPBridgedPlugin {
    /**
     * Plugin identifier used internally by Capacitor
     */
    public let identifier = "LlamaMobileVDPlugin"
    
    /**
     * Plugin name exposed to JavaScript
     */
    public let jsName = "LlamaMobileVD"
    
    /**
     * List of plugin methods exposed to JavaScript
     */
    public let pluginMethods: [CAPPluginMethod] = [
        // VectorStore Methods
        CAPPluginMethod(name: "createVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorToStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "removeVectorFromStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorFromStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "updateVectorInStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "containsVectorInStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "reserveVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorStoreDimension", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorStoreMetric", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorStoreCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "releaseVectorStore", returnType: CAPPluginReturnPromise),
        
        // HNSWIndex Methods
        CAPPluginMethod(name: "createHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorToIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setHNSWEfSearch", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getHNSWEfSearch", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "containsVectorInHNSW", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorFromHNSW", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getHNSWDimension", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getHNSWCapacity", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "loadHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getHNSWIndexCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "releaseHNSWIndex", returnType: CAPPluginReturnPromise),
        
        // Version Methods
        CAPPluginMethod(name: "getVersion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVersionMajor", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVersionMinor", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVersionPatch", returnType: CAPPluginReturnPromise),
        
        // MMapVectorStoreBuilder Methods
        CAPPluginMethod(name: "createMMapVectorStoreBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorToMMapBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "reserveMMapBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveMMapBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getMMapBuilderCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getMMapBuilderDimension", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "releaseMMapBuilder", returnType: CAPPluginReturnPromise),
        
        // MMapVectorStore Methods
        CAPPluginMethod(name: "openMMapVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorFromMMapStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchMMapStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "containsVectorInMMap", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getMMapStoreDimension", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getMMapStoreMetric", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getMMapStoreCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "releaseMMapVectorStore", returnType: CAPPluginReturnPromise),
    ]
    
    /**
     * Dictionary to store VectorStore instances by ID
     */
    private var vectorStores: [String: VectorStore] = [:]
    
    /**
     * Dictionary to store HNSWIndex instances by ID
     */
    private var hnswIndexes: [String: HNSWIndex] = [:]
    
    /**
     * Dictionary to store MMapVectorStoreBuilder instances by ID
     */
    private var mmapVectorStoreBuilders: [String: MMapVectorStoreBuilder] = [:]
    
    /**
     * Dictionary to store MMapVectorStore instances by ID
     */
    private var mmapVectorStores: [String: MMapVectorStore] = [:]
    
    /**
     * Convert a string distance metric to the native iOS enum
     * 
     * @param metricStr String representation of the distance metric
     * @returns DistanceMetric enum value
     * @throws Error if the metric string is invalid
     */
    private func stringToDistanceMetric(_ metricStr: String) throws -> DistanceMetric {
        switch metricStr.uppercased() {
        case "L2":
            return .l2
        case "COSINE":
            return .cosine
        case "DOT":
            return .dot
        default:
            throw CAPPluginError.error("Invalid distance metric: \(metricStr)")
        }
    }
    
    /**
     * Generate a unique ID for a VectorStore or HNSWIndex
     * 
     * @returns A unique string ID
     */
    private func generateUniqueId() -> String {
        return UUID().uuidString
    }
    
    /**
     * Convert an array of numbers to an array of Float
     * 
     * @param numberArray Array of numbers
     * @returns Array of Float
     */
    private func convertToFloatArray(_ numberArray: [Any]) -> [Float] {
        return numberArray.compactMap { $0 as? Double }.map { Float($0) }
    }
    
    // MARK: VectorStore Methods
    
    /**
     * Create a new vector store
     * 
     * @param call Plugin call with options
     */
    @objc func createVectorStore(_ call: CAPPluginCall) {
        do {
            guard let dimension = call.getInt("dimension"),
                  let metricStr = call.getString("metric") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            let metric = try stringToDistanceMetric(metricStr)
            let store = try VectorStore(dimension: dimension, metric: metric)
            
            let id = generateUniqueId()
            vectorStores[id] = store
            
            call.resolve(["id": id])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Add a vector to a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func addVectorToStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorArray = call.getArray("vector"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let vector = convertToFloatArray(vectorArray)
            try store.addVector(vector, id: vectorId)
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Search for nearest neighbors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func searchVectorStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let queryVectorArray = call.getArray("queryVector"),
                  let k = call.getInt("k") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let queryVector = convertToFloatArray(queryVectorArray)
            let results = try store.search(queryVector, k: k)
            
            let mappedResults = results.map { ["id": $0.id, "distance": $0.distance] }
            call.resolve(["results": mappedResults])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the number of vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVectorStoreCount(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let count = store.count
            call.resolve(["count": count])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Clear all vectors from a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func clearVectorStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            try store.clear()
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Release a vector store and free resources
     * 
     * @param call Plugin call with parameters
     */
    @objc func releaseVectorStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard vectorStores.removeValue(forKey: id) != nil else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Remove a vector from a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @objc func removeVectorFromStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let removed = try store.remove(id: vectorId)
            call.resolve(["result": removed])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get a vector from a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVectorFromStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            if let vector = try store.get(id: vectorId) {
                call.resolve(["vector": vector.map { $0 as Any }])
            } else {
                call.resolve(nil)
            }
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Update a vector in a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @objc func updateVectorInStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorId = call.getInt("vectorId"),
                  let vectorArray = call.getArray("vector") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let vector = convertToFloatArray(vectorArray)
            let updated = try store.update(id: vectorId, vector: vector)
            call.resolve(["result": updated])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Check if a vector exists in a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @objc func containsVectorInStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let contains = try store.contains(id: vectorId)
            call.resolve(["result": contains])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Reserve space for vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func reserveVectorStore(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let capacity = call.getInt("capacity") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            try store.reserve(capacity: capacity)
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the dimension of vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVectorStoreDimension(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let dimension = store.dimension
            call.resolve(["dimension": dimension])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the distance metric used by a vector store
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVectorStoreMetric(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let store = vectorStores[id] else {
                throw CAPPluginError.error("VectorStore not found with id: \(id)")
            }
            
            let metric = store.metric
            let metricStr: String
            switch metric {
            case .l2:
                metricStr = "L2"
            case .cosine:
                metricStr = "COSINE"
            case .dot:
                metricStr = "DOT"
            }
            call.resolve(["metric": metricStr])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    // MARK: HNSWIndex Methods
    
    /**
     * Create a new HNSW index
     * 
     * @param call Plugin call with options
     */
    @objc func createHNSWIndex(_ call: CAPPluginCall) {
        do {
            guard let dimension = call.getInt("dimension"),
                  let metricStr = call.getString("metric") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            let metric = try stringToDistanceMetric(metricStr)
            let m = call.getInt("m") ?? 16
            let efConstruction = call.getInt("efConstruction") ?? 200
            
            let index = try HNSWIndex(dimension: dimension, metric: metric, m: m, efConstruction: efConstruction)
            
            let id = generateUniqueId()
            hnswIndexes[id] = index
            
            call.resolve(["id": id])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Add a vector to an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @objc func addVectorToIndex(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorArray = call.getArray("vector"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let vector = convertToFloatArray(vectorArray)
            try index.addVector(vector, id: vectorId)
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Search for nearest neighbors in an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @objc func searchHNSWIndex(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let queryVectorArray = call.getArray("queryVector"),
                  let k = call.getInt("k") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let queryVector = convertToFloatArray(queryVectorArray)
            let efSearch = call.getInt("efSearch") ?? 50
            
            let results = try index.search(queryVector, k: k, efSearch: efSearch)
            
            let mappedResults = results.map { ["id": $0.id, "distance": $0.distance] }
            call.resolve(["results": mappedResults])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the number of vectors in an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @objc func getHNSWIndexCount(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let count = index.count
            call.resolve(["count": count])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Clear all vectors from an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @objc func clearHNSWIndex(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            try index.clear()
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Release an HNSW index and free resources
     * 
     * @param call Plugin call with parameters
     */
    @objc func releaseHNSWIndex(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard hnswIndexes.removeValue(forKey: id) != nil else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Set the efSearch parameter for HNSW index search
     * 
     * @param call Plugin call with parameters
     */
    @objc func setHNSWEfSearch(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let efSearch = call.getInt("efSearch") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            index.efSearch = efSearch
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the efSearch parameter for HNSW index search
     * 
     * @param call Plugin call with parameters
     */
    @objc func getHNSWEfSearch(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let efSearch = index.efSearch
            call.resolve(["efSearch": efSearch])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Check if a vector exists in an HNSW index by ID
     * 
     * @param call Plugin call with parameters
     */
    @objc func containsVectorInHNSW(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let contains = try index.contains(id: vectorId)
            call.resolve(["result": contains])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get a vector from an HNSW index by ID
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVectorFromHNSW(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let vectorId = call.getInt("vectorId") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            if let vector = try index.get(id: vectorId) {
                call.resolve(["vector": vector.map { $0 as Any }])
            } else {
                call.resolve(nil)
            }
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the dimension of vectors in an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @objc func getHNSWDimension(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let dimension = index.dimension
            call.resolve(["dimension": dimension])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the capacity of an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @objc func getHNSWCapacity(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id") else {
                throw CAPPluginError.error("Missing required parameter: id")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            let capacity = index.capacity
            call.resolve(["capacity": capacity])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Save an HNSW index to a file
     * 
     * @param call Plugin call with parameters
     */
    @objc func saveHNSWIndex(_ call: CAPPluginCall) {
        do {
            guard let id = call.getString("id"),
                  let path = call.getString("path") else {
                throw CAPPluginError.error("Missing required parameters")
            }
            
            guard let index = hnswIndexes[id] else {
                throw CAPPluginError.error("HNSWIndex not found with id: \(id)")
            }
            
            try index.save(toFile: path)
            call.resolve(["result": true])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Load an HNSW index from a file
     * 
     * @param call Plugin call with parameters
     */
    @objc func loadHNSWIndex(_ call: CAPPluginCall) {
        do {
            guard let path = call.getString("path") else {
                throw CAPPluginError.error("Missing required parameter: path")
            }
            
            let index = try HNSWIndex(loadFromFile: path)
            let id = generateUniqueId()
            hnswIndexes[id] = index
            
            call.resolve(["id": id])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    // MARK: Version Methods
    
    /**
     * Get the full version string of the SDK
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVersion(_ call: CAPPluginCall) {
        do {
            let version = LlamaMobileVD.version()
            call.resolve(["version": version])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the major version number
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVersionMajor(_ call: CAPPluginCall) {
        do {
            let major = LlamaMobileVD.versionMajor()
            call.resolve(["major": major])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the minor version number
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVersionMinor(_ call: CAPPluginCall) {
        do {
            let minor = LlamaMobileVD.versionMinor()
            call.resolve(["minor": minor])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the patch version number
     * 
     * @param call Plugin call with parameters
     */
    @objc func getVersionPatch(_ call: CAPPluginCall) {
        do {
            let patch = LlamaMobileVD.versionPatch()
            call.resolve(["patch": patch])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    // MARK: - MMapVectorStoreBuilder Methods
    
    /**
     * Create a new MMapVectorStoreBuilder
     * 
     * @param call Plugin call with parameters:
     * - dimension: The dimension of the vectors
     * - metric: The distance metric to use (L2, COSINE, DOT)
     */
    @objc func createMMapVectorStoreBuilder(_ call: CAPPluginCall) {
        do {
            guard let dimension = call.getInt("dimension") else {
                throw CAPPluginError.error("Missing dimension parameter")
            }
            guard let metricStr = call.getString("metric") else {
                throw CAPPluginError.error("Missing metric parameter")
            }
            
            let metric = try stringToDistanceMetric(metricStr)
            let builder = MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            
            let id = UUID().uuidString
            mmapVectorStoreBuilders[id] = builder
            
            call.resolve(["builderId": id])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Add a vector to the MMapVectorStoreBuilder
     * 
     * @param call Plugin call with parameters:
     * - builderId: The ID of the builder to add the vector to
     * - vector: The vector to add
     * - id: The ID to associate with the vector
     */
    @objc func addVectorToMMapBuilder(_ call: CAPPluginCall) {
        do {
            guard let builderId = call.getString("builderId") else {
                throw CAPPluginError.error("Missing builderId parameter")
            }
            guard let builder = mmapVectorStoreBuilders[builderId] else {
                throw CAPPluginError.error("Builder not found")
            }
            guard let vectorArray = call.getArray("vector", Float.self) else {
                throw CAPPluginError.error("Missing vector parameter or invalid format")
            }
            guard let id = call.getInt("id") else {
                throw CAPPluginError.error("Missing id parameter")
            }
            
            builder.addVector(vectorArray, id: id)
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Reserve capacity for vectors in the MMapVectorStoreBuilder
     * 
     * @param call Plugin call with parameters:
     * - builderId: The ID of the builder to reserve capacity for
     * - capacity: The number of vectors to reserve capacity for
     */
    @objc func reserveMMapBuilder(_ call: CAPPluginCall) {
        do {
            guard let builderId = call.getString("builderId") else {
                throw CAPPluginError.error("Missing builderId parameter")
            }
            guard let builder = mmapVectorStoreBuilders[builderId] else {
                throw CAPPluginError.error("Builder not found")
            }
            guard let capacity = call.getInt("capacity") else {
                throw CAPPluginError.error("Missing capacity parameter")
            }
            
            builder.reserve(capacity)
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Save the MMapVectorStoreBuilder to a file
     * 
     * @param call Plugin call with parameters:
     * - builderId: The ID of the builder to save
     * - filename: The name of the file to save the builder to
     */
    @objc func saveMMapBuilder(_ call: CAPPluginCall) {
        do {
            guard let builderId = call.getString("builderId") else {
                throw CAPPluginError.error("Missing builderId parameter")
            }
            guard let builder = mmapVectorStoreBuilders[builderId] else {
                throw CAPPluginError.error("Builder not found")
            }
            guard let filename = call.getString("filename") else {
                throw CAPPluginError.error("Missing filename parameter")
            }
            
            builder.save(filename)
            
            // Release the builder after saving
            mmapVectorStoreBuilders.removeValue(forKey: builderId)
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the number of vectors in the MMapVectorStoreBuilder
     * 
     * @param call Plugin call with parameters:
     * - builderId: The ID of the builder to get the count for
     */
    @objc func getMMapBuilderCount(_ call: CAPPluginCall) {
        do {
            guard let builderId = call.getString("builderId") else {
                throw CAPPluginError.error("Missing builderId parameter")
            }
            guard let builder = mmapVectorStoreBuilders[builderId] else {
                throw CAPPluginError.error("Builder not found")
            }
            
            let count = builder.count()
            call.resolve(["count": count])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the dimension of vectors in the MMapVectorStoreBuilder
     * 
     * @param call Plugin call with parameters:
     * - builderId: The ID of the builder to get the dimension for
     */
    @objc func getMMapBuilderDimension(_ call: CAPPluginCall) {
        do {
            guard let builderId = call.getString("builderId") else {
                throw CAPPluginError.error("Missing builderId parameter")
            }
            guard let builder = mmapVectorStoreBuilders[builderId] else {
                throw CAPPluginError.error("Builder not found")
            }
            
            let dimension = builder.dimension()
            call.resolve(["dimension": dimension])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Release the MMapVectorStoreBuilder
     * 
     * @param call Plugin call with parameters:
     * - builderId: The ID of the builder to release
     */
    @objc func releaseMMapBuilder(_ call: CAPPluginCall) {
        do {
            guard let builderId = call.getString("builderId") else {
                throw CAPPluginError.error("Missing builderId parameter")
            }
            
            if let builder = mmapVectorStoreBuilders.removeValue(forKey: builderId) {
                builder.close()
            }
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    // MARK: - MMapVectorStore Methods
    
    /**
     * Open an existing MMapVectorStore from a file
     * 
     * @param call Plugin call with parameters:
     * - filename: The name of the file containing the vector store
     */
    @objc func openMMapVectorStore(_ call: CAPPluginCall) {
        do {
            guard let filename = call.getString("filename") else {
                throw CAPPluginError.error("Missing filename parameter")
            }
            
            let store = try MMapVectorStore.open(filename)
            
            let id = UUID().uuidString
            mmapVectorStores[id] = store
            
            call.resolve(["storeId": id])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get a vector by ID from the MMapVectorStore
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to get the vector from
     * - id: The ID of the vector to retrieve
     */
    @objc func getVectorFromMMapStore(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            guard let store = mmapVectorStores[storeId] else {
                throw CAPPluginError.error("Store not found")
            }
            guard let id = call.getInt("id") else {
                throw CAPPluginError.error("Missing id parameter")
            }
            
            if let vector = store.get(id) {
                call.resolve(["vector": vector])
            } else {
                call.resolve(["vector": NSNull()])
            }
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Search for the nearest neighbors of a query vector in the MMapVectorStore
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to search
     * - queryVector: The query vector
     * - k: The number of nearest neighbors to return
     */
    @objc func searchMMapStore(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            guard let store = mmapVectorStores[storeId] else {
                throw CAPPluginError.error("Store not found")
            }
            guard let vectorArray = call.getArray("queryVector", Float.self) else {
                throw CAPPluginError.error("Missing queryVector parameter or invalid format")
            }
            guard let k = call.getInt("k") else {
                throw CAPPluginError.error("Missing k parameter")
            }
            
            let results = store.search(vectorArray, k: k)
            let formattedResults = results.map { ["id": $0.id, "distance": $0.distance] }
            
            call.resolve(["results": formattedResults])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Check if the MMapVectorStore contains a vector with the specified ID
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to check
     * - id: The ID to check
     */
    @objc func containsVectorInMMap(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            guard let store = mmapVectorStores[storeId] else {
                throw CAPPluginError.error("Store not found")
            }
            guard let id = call.getInt("id") else {
                throw CAPPluginError.error("Missing id parameter")
            }
            
            let contains = store.contains(id)
            call.resolve(["contains": contains])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the dimension of vectors in the MMapVectorStore
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to get the dimension for
     */
    @objc func getMMapStoreDimension(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            guard let store = mmapVectorStores[storeId] else {
                throw CAPPluginError.error("Store not found")
            }
            
            let dimension = store.dimension()
            call.resolve(["dimension": dimension])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the distance metric used by the MMapVectorStore
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to get the metric for
     */
    @objc func getMMapStoreMetric(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            guard let store = mmapVectorStores[storeId] else {
                throw CAPPluginError.error("Store not found")
            }
            
            let metric = store.metric()
            let metricStr = metricToString(metric)
            
            call.resolve(["metric": metricStr])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Get the number of vectors in the MMapVectorStore
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to get the count for
     */
    @objc func getMMapStoreCount(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            guard let store = mmapVectorStores[storeId] else {
                throw CAPPluginError.error("Store not found")
            }
            
            let count = store.count()
            call.resolve(["count": count])
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    /**
     * Release the MMapVectorStore
     * 
     * @param call Plugin call with parameters:
     * - storeId: The ID of the store to release
     */
    @objc func releaseMMapVectorStore(_ call: CAPPluginCall) {
        do {
            guard let storeId = call.getString("storeId") else {
                throw CAPPluginError.error("Missing storeId parameter")
            }
            
            if let store = mmapVectorStores.removeValue(forKey: storeId) {
                store.close()
            }
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
}