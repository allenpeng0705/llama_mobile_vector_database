import Capacitor
import llama_mobile_vd

@objc(LlamaMobileVDPlugin)
public class LlamaMobileVDPlugin: CAPPlugin {
    
    private var vectorStores: [Int: LlamaMobileVD.VectorStore] = [:]
    private var hnswIndexes: [Int: LlamaMobileVD.HNSWIndex] = [:]
    private var mmapBuilders: [Int: LlamaMobileVD.MMapVectorStoreBuilder] = [:]
    private var mmapStores: [Int: LlamaMobileVD.MMapVectorStore] = [:]
    private var nextId: Int = 1
    
    @objc public func getVersion(_ call: CAPPluginCall) {
        let version = LlamaMobileVD.Version.full
        call.resolve(["version": version])
    }
    
    @objc public func createVectorStore(_ call: CAPPluginCall) {
        guard let dimension = call.getInt("dimension") else {
            call.reject("Missing required parameter: dimension")
            return
        }
        
        let metricStr = call.getString("metric") ?? "cosine"
        let metric: LlamaMobileVD.DistanceMetric
        
        switch metricStr {
        case "l2":
            metric = .l2
        case "cosine":
            metric = .cosine
        case "dot":
            metric = .dot
        default:
            call.reject("Invalid metric: \(metricStr)")
            return
        }
        
        do {
            let store = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
            let storeId = nextId
            nextId += 1
            vectorStores[storeId] = store
            call.resolve(["storeId": storeId])
        } catch {
            call.reject("Failed to create vector store: \(error.localizedDescription)")
        }
    }
    
    @objc public func destroyVectorStore(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard vectorStores[storeId] != nil else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        vectorStores.removeValue(forKey: storeId)
        call.resolve()
    }
    
    @objc public func addVectors(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        guard let vectors = call.getArray("vectors") as? [[Double]] else {
            call.reject("Missing or invalid vectors parameter")
            return
        }
        
        let ids = call.getArray("ids") as? [Int]
        
        do {
            for (index, vector) in vectors.enumerated() {
                let floatVector = vector.map { Float($0) }
                let id = ids?[index] ?? index + 1
                try store.addVector(id: UInt64(id), vector: floatVector)
            }
            call.resolve()
        } catch {
            call.reject("Failed to add vectors: \(error.localizedDescription)")
        }
    }
    
    @objc public func getVector(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        guard let id = call.getInt("id") else {
            call.reject("Missing required parameter: id")
            return
        }
        
        do {
            let vector = try store.getVector(id: UInt64(id))
            let doubleVector = vector.map { Double($0) }
            call.resolve(["vector": doubleVector])
        } catch {
            call.reject("Failed to get vector: \(error.localizedDescription)")
        }
    }
    
    @objc public func search(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        guard let queryVector = call.getArray("queryVector") as? [Double] else {
            call.reject("Missing or invalid queryVector parameter")
            return
        }
        
        guard let k = call.getInt("k") else {
            call.reject("Missing required parameter: k")
            return
        }
        
        do {
            let floatQueryVector = queryVector.map { Float($0) }
            let result = try store.search(query: floatQueryVector, k: k)
            call.resolve([
                "ids": result.map { Int($0.id) },
                "distances": result.map { Double($0.distance) }
            ])
        } catch {
            call.reject("Failed to search: \(error.localizedDescription)")
        }
    }
    
    @objc public func removeVectors(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        guard let ids = call.getArray("ids") as? [Int] else {
            call.reject("Missing or invalid ids parameter")
            return
        }
        
        do {
            for id in ids {
                try store.removeVector(id: UInt64(id))
            }
            call.resolve()
        } catch {
            call.reject("Failed to remove vectors: \(error.localizedDescription)")
        }
    }
    
    @objc public func getVectorCount(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        do {
            let count = try store.count()
            call.resolve(["count": count])
        } catch {
            call.reject("Failed to get vector count: \(error.localizedDescription)")
        }
    }
    
    @objc public func clearVectors(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        do {
            try store.clear()
            call.resolve()
        } catch {
            call.reject("Failed to clear vectors: \(error.localizedDescription)")
        }
    }
    
    @objc public func createHNSWIndex(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let m = call.getInt("m") else {
            call.reject("Missing required parameter: m")
            return
        }
        
        guard let efConstruction = call.getInt("efConstruction") else {
            call.reject("Missing required parameter: efConstruction")
            return
        }
        
        do {
            var dimension: Int
            var metric: LlamaMobileVD.DistanceMetric
            var index: LlamaMobileVD.HNSWIndex
            
            // Check if it's a regular vector store
            if let store = vectorStores[storeId] {
                dimension = try store.dimension()
                metric = try store.metric()
                
                let maxElements = try store.count() + 1000 // Default max elements with buffer
                index = try LlamaMobileVD.HNSWIndex(
                    dimension: dimension,
                    metric: metric,
                    maxElements: maxElements,
                    m: m,
                    efConstruction: efConstruction
                )
            } else {
                call.reject("Invalid storeId: \(storeId)")
                return
            }
            
            let indexId = nextId
            nextId += 1
            hnswIndexes[indexId] = index
            call.resolve(["indexId": indexId])
        } catch {
            call.reject("Failed to create HNSW index: \(error.localizedDescription)")
        }
    }
    
    @objc public func destroyHNSWIndex(_ call: CAPPluginCall) {
        guard let indexId = call.getInt("indexId") else {
            call.reject("Missing required parameter: indexId")
            return
        }
        
        guard hnswIndexes[indexId] != nil else {
            call.reject("Invalid indexId: \(indexId)")
            return
        }
        
        hnswIndexes.removeValue(forKey: indexId)
        call.resolve()
    }
    
    @objc public func searchHNSW(_ call: CAPPluginCall) {
        guard let indexId = call.getInt("indexId") else {
            call.reject("Missing required parameter: indexId")
            return
        }
        
        guard let index = hnswIndexes[indexId] else {
            call.reject("Invalid indexId: \(indexId)")
            return
        }
        
        guard let queryVector = call.getArray("queryVector") as? [Double] else {
            call.reject("Missing or invalid queryVector parameter")
            return
        }
        
        guard let k = call.getInt("k") else {
            call.reject("Missing required parameter: k")
            return
        }
        
        let efSearch = call.getInt("efSearch")
        
        do {
            if let efSearch = efSearch {
                try index.setEfSearch(efSearch)
            }
            
            let floatQueryVector = queryVector.map { Float($0) }
            let result = try index.search(query: floatQueryVector, k: k)
            call.resolve([
                "ids": result.map { Int($0.id) },
                "distances": result.map { Double($0.distance) }
            ])
        } catch {
            call.reject("Failed to search HNSW: \(error.localizedDescription)")
        }
    }
    
    @objc public func addVectorsToHNSW(_ call: CAPPluginCall) {
        guard let indexId = call.getInt("indexId") else {
            call.reject("Missing required parameter: indexId")
            return
        }
        
        guard let index = hnswIndexes[indexId] else {
            call.reject("Invalid indexId: \(indexId)")
            return
        }
        
        guard let vectors = call.getArray("vectors") as? [[Double]] else {
            call.reject("Missing or invalid vectors parameter")
            return
        }
        
        let ids = call.getArray("ids") as? [Int]
        
        do {
            for (vectorIndex, vector) in vectors.enumerated() {
                let floatVector = vector.map { Float($0) }
                let id = ids?[vectorIndex] ?? vectorIndex + 1
                try index.addVector(id: UInt64(id), vector: floatVector)
            }
            call.resolve()
        } catch {
            call.reject("Failed to add vectors to HNSW: \(error.localizedDescription)")
        }
    }
    
    @objc public func createMMapVectorStoreBuilder(_ call: CAPPluginCall) {
        guard let dimension = call.getInt("dimension") else {
            call.reject("Missing required parameter: dimension")
            return
        }
        
        let metricStr = call.getString("metric") ?? "cosine"
        let metric: LlamaMobileVD.DistanceMetric
        
        switch metricStr {
        case "l2":
            metric = .l2
        case "cosine":
            metric = .cosine
        case "dot":
            metric = .dot
        default:
            call.reject("Invalid metric: \(metricStr)")
            return
        }
        
        do {
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            let builderId = nextId
            nextId += 1
            mmapBuilders[builderId] = builder
            call.resolve(["builderId": builderId])
        } catch {
            call.reject("Failed to create MMap vector store builder: \(error.localizedDescription)")
        }
    }
    
    @objc public func destroyMMapVectorStoreBuilder(_ call: CAPPluginCall) {
        guard let builderId = call.getInt("builderId") else {
            call.reject("Missing required parameter: builderId")
            return
        }
        
        guard mmapBuilders[builderId] != nil else {
            call.reject("Invalid builderId: \(builderId)")
            return
        }
        
        mmapBuilders.removeValue(forKey: builderId)
        call.resolve()
    }
    
    @objc public func addVectorsToMMapBuilder(_ call: CAPPluginCall) {
        guard let builderId = call.getInt("builderId") else {
            call.reject("Missing required parameter: builderId")
            return
        }
        
        guard let builder = mmapBuilders[builderId] else {
            call.reject("Invalid builderId: \(builderId)")
            return
        }
        
        guard let vectors = call.getArray("vectors") as? [[Double]] else {
            call.reject("Missing or invalid vectors parameter")
            return
        }
        
        let ids = call.getArray("ids") as? [Int]
        
        do {
            for (index, vector) in vectors.enumerated() {
                let floatVector = vector.map { Float($0) }
                let id = ids?[index] ?? index + 1
                try builder.addVector(id: UInt64(id), vector: floatVector)
            }
            call.resolve()
        } catch {
            call.reject("Failed to add vectors to MMap builder: \(error.localizedDescription)")
        }
    }
    
    @objc public func buildMMapVectorStore(_ call: CAPPluginCall) {
        guard let builderId = call.getInt("builderId") else {
            call.reject("Missing required parameter: builderId")
            return
        }
        
        guard let builder = mmapBuilders[builderId] else {
            call.reject("Invalid builderId: \(builderId)")
            return
        }
        
        // Get the path from the builder's context or from the call
        guard let path = call.getString("path") else {
            call.reject("Missing required parameter: path")
            return
        }
        
        do {
            try builder.save(to: path)
            call.resolve()
        } catch {
            call.reject("Failed to build MMap vector store: \(error.localizedDescription)")
        }
    }
    
    @objc public func openMMapVectorStore(_ call: CAPPluginCall) {
        guard let path = call.getString("path") else {
            call.reject("Missing required parameter: path")
            return
        }
        
        do {
            let store = try LlamaMobileVD.MMapVectorStore.open(from: path)
            let storeId = nextId
            nextId += 1
            mmapStores[storeId] = store
            call.resolve(["storeId": storeId])
        } catch {
            call.reject("Failed to open MMap vector store: \(error.localizedDescription)")
        }
    }
    
    @objc public func closeMMapVectorStore(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard mmapStores[storeId] != nil else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        mmapStores.removeValue(forKey: storeId)
        call.resolve()
    }
}
