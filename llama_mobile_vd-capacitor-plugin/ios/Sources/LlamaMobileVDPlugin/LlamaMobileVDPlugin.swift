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
        CAPPluginMethod(name: "createVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorToStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorToIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorStoreCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getHNSWIndexCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "releaseVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "releaseHNSWIndex", returnType: CAPPluginReturnPromise),
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
}