import Capacitor
import llama_mobile_vd

@objc(LlamaMobileVDPlugin)
public class LlamaMobileVDPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "LlamaMobileVDPlugin"
    public let jsName = "LlamaMobileVD"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getVersion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVersionMajor", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVersionMinor", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVersionPatch", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "destroyVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectors", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVector", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "search", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "removeVectors", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getVectorCount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearVectors", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "destroyHNSWIndex", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchHNSW", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorsToHNSW", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createMMapVectorStoreBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "destroyMMapVectorStoreBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorsToMMapBuilder", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "buildMMapVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "openMMapVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "closeMMapVectorStore", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createVectorStoreAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorsAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "removeVectorsAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearVectorsAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createHNSWIndexAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "searchHNSWAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorsToHNSWAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "createMMapVectorStoreBuilderAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addVectorsToMMapBuilderAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "buildMMapVectorStoreAsync", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "openMMapVectorStoreAsync", returnType: CAPPluginReturnPromise)
    ]
    
    // Use static variables to persist across plugin instances
    static var vectorStores: [Int: LlamaMobileVD.VectorStore] = [:]
    static var hnswIndexes: [Int: LlamaMobileVD.HNSWIndex] = [:]
    static var mmapBuilders: [Int: LlamaMobileVD.MMapVectorStoreBuilder] = [:]
    static var mmapStores: [Int: LlamaMobileVD.MMapVectorStore] = [:]
    static var nextId: Int = 1
    
    override public func load() {
        print("LlamaMobileVDPlugin loaded successfully!")
        print("LlamaMobileVDPlugin instance: \(ObjectIdentifier(self))")
    }
    
    @objc public func getVersion(_ call: CAPPluginCall) {
        print("LlamaMobileVDPlugin: getVersion called - instance: \(ObjectIdentifier(self))")
        let version = LlamaMobileVD.Version.full
        print("LlamaMobileVDPlugin: getVersion returned: \(version)")
        // Add a prefix to make it clear this is from the native iOS plugin
        call.resolve(["version": version])
    }

    @objc public func getVersionMajor(_ call: CAPPluginCall) {
        print("LlamaMobileVDPlugin: getVersionMajor called - instance: \(ObjectIdentifier(self))")
        let major = LlamaMobileVD.Version.major
        print("LlamaMobileVDPlugin: getVersionMajor returned: \(major)")
        call.resolve(["major": major])
    }

    @objc public func getVersionMinor(_ call: CAPPluginCall) {
        print("LlamaMobileVDPlugin: getVersionMinor called - instance: \(ObjectIdentifier(self))")
        let minor = LlamaMobileVD.Version.minor
        print("LlamaMobileVDPlugin: getVersionMinor returned: \(minor)")
        call.resolve(["minor": minor])
    }

    @objc public func getVersionPatch(_ call: CAPPluginCall) {
        print("LlamaMobileVDPlugin: getVersionPatch called - instance: \(ObjectIdentifier(self))")
        let patch = LlamaMobileVD.Version.patch
        print("LlamaMobileVDPlugin: getVersionPatch returned: \(patch)")
        call.resolve(["patch": patch])
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
            let storeId = LlamaMobileVDPlugin.nextId
            LlamaMobileVDPlugin.nextId += 1
            LlamaMobileVDPlugin.vectorStores[storeId] = store
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
        
        guard LlamaMobileVDPlugin.vectorStores[storeId] != nil else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        LlamaMobileVDPlugin.vectorStores.removeValue(forKey: storeId)
        call.resolve()
    }
    
    @objc public func addVectors(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
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
        
        guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        guard let id = call.getInt("id") else {
            call.reject("Missing required parameter: id")
            return
        }
        
        do {
            let vector = try store.getVector(id: UInt64(id))
            call.resolve(["vector": vector])
        } catch {
            call.reject("Failed to get vector: \(error.localizedDescription)")
        }
    }
    
    @objc public func search(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let queryVector = call.getArray("queryVector") as? [Double] else {
            call.reject("Missing or invalid queryVector parameter")
            return
        }
        
        let k = call.getInt("k") ?? 5
        
        do {
            let floatQueryVector = queryVector.map { Float($0) }
            
            // Check if it's a regular vector store
            if let store = LlamaMobileVDPlugin.vectorStores[storeId] {
                let result = try store.search(query: floatQueryVector, k: k)
                // Convert to expected format with separate ids and distances arrays
                let ids = result.map { $0.id }
                let distances = result.map { $0.distance }
                call.resolve(["ids": ids, "distances": distances])
            }
            // Check if it's an MMap vector store
            else if let store = LlamaMobileVDPlugin.mmapStores[storeId] {
                let result = try store.search(query: floatQueryVector, k: k)
                // Convert to expected format with separate ids and distances arrays
                let ids = result.map { $0.id }
                let distances = result.map { $0.distance }
                call.resolve(["ids": ids, "distances": distances])
            }
            else {
                call.reject("Invalid storeId: \(storeId)")
            }
        } catch {
            call.reject("Failed to search: \(error.localizedDescription)")
        }
    }
    
    @objc public func removeVectors(_ call: CAPPluginCall) {
        guard let storeId = call.getInt("storeId") else {
            call.reject("Missing required parameter: storeId")
            return
        }
        
        guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
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
        
        guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
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
        
        guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
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
        
        let maxElements = call.getInt("maxElements") ?? 10000
        let m = call.getInt("m") ?? 16
        let efConstruction = call.getInt("efConstruction") ?? 200
        let seed = call.getInt("seed") ?? 42
        
        do {
            let index = try LlamaMobileVD.HNSWIndex(
                dimension: dimension,
                metric: metric,
                maxElements: maxElements,
                m: m,
                efConstruction: efConstruction,
                seed: UInt32(seed)
            )
            
            let indexId = LlamaMobileVDPlugin.nextId
            LlamaMobileVDPlugin.nextId += 1
            LlamaMobileVDPlugin.hnswIndexes[indexId] = index
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
        
        guard LlamaMobileVDPlugin.hnswIndexes[indexId] != nil else {
            call.reject("Invalid indexId: \(indexId)")
            return
        }
        
        LlamaMobileVDPlugin.hnswIndexes.removeValue(forKey: indexId)
        call.resolve()
    }
    
    @objc public func searchHNSW(_ call: CAPPluginCall) {
        guard let indexId = call.getInt("indexId") else {
            call.reject("Missing required parameter: indexId")
            return
        }
        
        guard let index = LlamaMobileVDPlugin.hnswIndexes[indexId] else {
            call.reject("Invalid indexId: \(indexId)")
            return
        }
        
        guard let queryVector = call.getArray("queryVector") as? [Double] else {
            call.reject("Missing or invalid queryVector parameter")
            return
        }
        
        let k = call.getInt("k") ?? 5
        
        do {
            let floatQueryVector = queryVector.map { Float($0) }
            let result = try index.search(query: floatQueryVector, k: k)
            // Convert to expected format with separate ids and distances arrays
            let ids = result.map { $0.id }
            let distances = result.map { $0.distance }
            call.resolve(["ids": ids, "distances": distances])
        } catch {
            call.reject("Failed to search HNSW index: \(error.localizedDescription)")
        }
    }
    
    @objc public func addVectorsToHNSW(_ call: CAPPluginCall) {
        guard let indexId = call.getInt("indexId") else {
            call.reject("Missing required parameter: indexId")
            return
        }
        
        guard let index = LlamaMobileVDPlugin.hnswIndexes[indexId] else {
            call.reject("Invalid indexId: \(indexId)")
            return
        }
        
        guard let vectors = call.getArray("vectors") as? [[Double]] else {
            call.reject("Missing or invalid vectors parameter")
            return
        }
        
        let ids = call.getArray("ids") as? [Int]
        
        do {
            for (i, vector) in vectors.enumerated() {
                let floatVector = vector.map { Float($0) }
                let id = ids?[i] ?? i + 1
                try index.addVector(id: UInt64(id), vector: floatVector)
            }
            call.resolve()
        } catch {
            call.reject("Failed to add vectors to HNSW index: \(error.localizedDescription)")
        }
    }
    
    @objc public func createMMapVectorStoreBuilder(_ call: CAPPluginCall) {
        print("LlamaMobileVDPlugin: createMMapVectorStoreBuilder called - instance: \(ObjectIdentifier(self))")
        
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
            print("LlamaMobileVDPlugin: About to create builder with dimension: \(dimension), metric: \(metric)")
            let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
            print("LlamaMobileVDPlugin: Builder created successfully: \(builder)")
            let builderId = LlamaMobileVDPlugin.nextId
            LlamaMobileVDPlugin.nextId += 1
            print("LlamaMobileVDPlugin: Storing builder with ID: \(builderId)")
            LlamaMobileVDPlugin.mmapBuilders[builderId] = builder
            print("LlamaMobileVDPlugin: Created builder with ID: \(builderId), total builders: \(LlamaMobileVDPlugin.mmapBuilders.count)")
            call.resolve(["builderId": builderId])
        } catch {
            print("LlamaMobileVDPlugin: Error creating builder: \(error.localizedDescription)")
            call.reject("Failed to create MMap vector store builder: \(error.localizedDescription)")
        }
    }
    
    @objc public func destroyMMapVectorStoreBuilder(_ call: CAPPluginCall) {
        guard let builderId = call.getInt("builderId") else {
            call.reject("Missing required parameter: builderId")
            return
        }
        
        guard LlamaMobileVDPlugin.mmapBuilders[builderId] != nil else {
            call.reject("Invalid builderId: \(builderId)")
            return
        }
        
        LlamaMobileVDPlugin.mmapBuilders.removeValue(forKey: builderId)
        call.resolve()
    }
    
    @objc public func addVectorsToMMapBuilder(_ call: CAPPluginCall) {
        guard let builderId = call.getInt("builderId") else {
            call.reject("Missing required parameter: builderId")
            return
        }
        
        guard let builder = LlamaMobileVDPlugin.mmapBuilders[builderId] else {
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
        print("LlamaMobileVDPlugin: buildMMapVectorStore called - instance: \(ObjectIdentifier(self))")
        
        guard let builderId = call.getInt("builderId") else {
            call.reject("Missing required parameter: builderId")
            return
        }
        
        print("LlamaMobileVDPlugin: builderId: \(builderId)")
        print("LlamaMobileVDPlugin: mmapBuilders keys: \(LlamaMobileVDPlugin.mmapBuilders.keys)")
        print("LlamaMobileVDPlugin: mmapBuilders count: \(LlamaMobileVDPlugin.mmapBuilders.count)")
        
        guard let builder = LlamaMobileVDPlugin.mmapBuilders[builderId] else {
            print("LlamaMobileVDPlugin: ERROR - Builder not found for ID: \(builderId)")
            call.reject("Invalid builderId: \(builderId)")
            return
        }
        
        print("LlamaMobileVDPlugin: builder found, type: \(type(of: builder))")
        
        guard let path = call.getString("path") else {
            call.reject("Missing required parameter: path")
            return
        }
        
        print("LlamaMobileVDPlugin: buildMMapVectorStore called with path: \(path)")
        
        do {
            let fullPath: String
            if path.hasPrefix("/") {
                fullPath = path
            } else {
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                fullPath = documentDirectory + "/" + path
            }
            
            print("LlamaMobileVDPlugin: Original path: \(path)")
            print("LlamaMobileVDPlugin: Full path: \(fullPath)")
            print("LlamaMobileVDPlugin: File exists: \(FileManager.default.fileExists(atPath: fullPath))")
            print("LlamaMobileVDPlugin: Directory exists: \(FileManager.default.fileExists(atPath: (fullPath as NSString).deletingLastPathComponent))")
            
            let directoryPath = (fullPath as NSString).deletingLastPathComponent
            if !FileManager.default.fileExists(atPath: directoryPath) {
                print("LlamaMobileVDPlugin: Creating directory: \(directoryPath)")
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            print("LlamaMobileVDPlugin: About to call builder.save()")
            try builder.save(to: fullPath)
            print("LlamaMobileVDPlugin: builder.save() completed successfully")
            call.resolve()
        } catch {
            print("LlamaMobileVDPlugin: Error in buildMMapVectorStore: \(error.localizedDescription)")
            print("LlamaMobileVDPlugin: Error type: \(type(of: error))")
            call.reject("Failed to build MMap vector store: \(error.localizedDescription)")
        }
    }
    
    @objc public func openMMapVectorStore(_ call: CAPPluginCall) {
        guard let path = call.getString("path") else {
            call.reject("Missing required parameter: path")
            return
        }
        
        do {
            let fullPath: String
            if path.hasPrefix("/") {
                fullPath = path
            } else {
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                fullPath = documentDirectory + "/" + path
            }
            
            print("LlamaMobileVDPlugin: Opening MMap vector store from: \(fullPath)")
            let store = try LlamaMobileVD.MMapVectorStore.open(from: fullPath)
            let storeId = LlamaMobileVDPlugin.nextId
            LlamaMobileVDPlugin.nextId += 1
            LlamaMobileVDPlugin.mmapStores[storeId] = store
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
        
        guard LlamaMobileVDPlugin.mmapStores[storeId] != nil else {
            call.reject("Invalid storeId: \(storeId)")
            return
        }
        
        LlamaMobileVDPlugin.mmapStores.removeValue(forKey: storeId)
        call.resolve()
    }

    // MARK: - VectorStore async methods
    @objc public func createVectorStoreAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let dimension = call.getInt("dimension") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: dimension")
                }
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
                DispatchQueue.main.async {
                    call.reject("Invalid metric: \(metricStr)")
                }
                return
            }
            
            do {
                let store = try LlamaMobileVD.VectorStore(dimension: dimension, metric: metric)
                let storeId = LlamaMobileVDPlugin.nextId
                LlamaMobileVDPlugin.nextId += 1
                LlamaMobileVDPlugin.vectorStores[storeId] = store
                DispatchQueue.main.async {
                    call.resolve(["storeId": storeId])
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to create vector store: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func addVectorsAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let storeId = call.getInt("storeId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: storeId")
                }
                return
            }
            
            guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid storeId: \(storeId)")
                }
                return
            }
            
            guard let vectors = call.getArray("vectors") as? [[Double]] else {
                DispatchQueue.main.async {
                    call.reject("Missing or invalid vectors parameter")
                }
                return
            }
            
            let ids = call.getArray("ids") as? [Int]
            
            do {
                for (index, vector) in vectors.enumerated() {
                    let floatVector = vector.map { Float($0) }
                    let id = ids?[index] ?? index + 1
                    try store.addVector(id: UInt64(id), vector: floatVector)
                }
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to add vectors: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func searchAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let storeId = call.getInt("storeId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: storeId")
                }
                return
            }
            
            guard let queryVector = call.getArray("queryVector") as? [Double] else {
                DispatchQueue.main.async {
                    call.reject("Missing or invalid queryVector parameter")
                }
                return
            }
            
            let k = call.getInt("k") ?? 5
            
            do {
                let floatQueryVector = queryVector.map { Float($0) }
                
                if let store = LlamaMobileVDPlugin.vectorStores[storeId] {
                    let result = try store.search(query: floatQueryVector, k: k)
                    let ids = result.map { $0.id }
                    let distances = result.map { $0.distance }
                    DispatchQueue.main.async {
                        call.resolve(["ids": ids, "distances": distances])
                    }
                } else if let store = LlamaMobileVDPlugin.mmapStores[storeId] {
                    let result = try store.search(query: floatQueryVector, k: k)
                    let ids = result.map { $0.id }
                    let distances = result.map { $0.distance }
                    DispatchQueue.main.async {
                        call.resolve(["ids": ids, "distances": distances])
                    }
                } else {
                    DispatchQueue.main.async {
                        call.reject("Invalid storeId: \(storeId)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to search: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func removeVectorsAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let storeId = call.getInt("storeId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: storeId")
                }
                return
            }
            
            guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid storeId: \(storeId)")
                }
                return
            }
            
            guard let ids = call.getArray("ids") as? [Int] else {
                DispatchQueue.main.async {
                    call.reject("Missing or invalid ids parameter")
                }
                return
            }
            
            do {
                for id in ids {
                    try store.removeVector(id: UInt64(id))
                }
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to remove vectors: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func clearVectorsAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let storeId = call.getInt("storeId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: storeId")
                }
                return
            }
            
            guard let store = LlamaMobileVDPlugin.vectorStores[storeId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid storeId: \(storeId)")
                }
                return
            }
            
            do {
                try store.clear()
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to clear vectors: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - HNSWIndex async methods
    @objc public func createHNSWIndexAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let dimension = call.getInt("dimension") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: dimension")
                }
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
                DispatchQueue.main.async {
                    call.reject("Invalid metric: \(metricStr)")
                }
                return
            }
            
            let maxElements = call.getInt("maxElements") ?? 10000
            let m = call.getInt("m") ?? 16
            let efConstruction = call.getInt("efConstruction") ?? 200
            let seed = call.getInt("seed") ?? 42
            
            do {
                let index = try LlamaMobileVD.HNSWIndex(
                    dimension: dimension,
                    metric: metric,
                    maxElements: maxElements,
                    m: m,
                    efConstruction: efConstruction,
                    seed: UInt32(seed)
                )
                
                let indexId = LlamaMobileVDPlugin.nextId
                LlamaMobileVDPlugin.nextId += 1
                LlamaMobileVDPlugin.hnswIndexes[indexId] = index
                DispatchQueue.main.async {
                    call.resolve(["indexId": indexId])
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to create HNSW index: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func searchHNSWAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let indexId = call.getInt("indexId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: indexId")
                }
                return
            }
            
            guard let index = LlamaMobileVDPlugin.hnswIndexes[indexId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid indexId: \(indexId)")
                }
                return
            }
            
            guard let queryVector = call.getArray("queryVector") as? [Double] else {
                DispatchQueue.main.async {
                    call.reject("Missing or invalid queryVector parameter")
                }
                return
            }
            
            let k = call.getInt("k") ?? 5
            
            do {
                let floatQueryVector = queryVector.map { Float($0) }
                let result = try index.search(query: floatQueryVector, k: k)
                let ids = result.map { $0.id }
                let distances = result.map { $0.distance }
                DispatchQueue.main.async {
                    call.resolve(["ids": ids, "distances": distances])
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to search HNSW index: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func addVectorsToHNSWAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let indexId = call.getInt("indexId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: indexId")
                }
                return
            }
            
            guard let index = LlamaMobileVDPlugin.hnswIndexes[indexId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid indexId: \(indexId)")
                }
                return
            }
            
            guard let vectors = call.getArray("vectors") as? [[Double]] else {
                DispatchQueue.main.async {
                    call.reject("Missing or invalid vectors parameter")
                }
                return
            }
            
            let ids = call.getArray("ids") as? [Int]
            
            do {
                for (i, vector) in vectors.enumerated() {
                    let floatVector = vector.map { Float($0) }
                    let id = ids?[i] ?? i + 1
                    try index.addVector(id: UInt64(id), vector: floatVector)
                }
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to add vectors to HNSW index: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - MMapVectorStoreBuilder async methods
    @objc public func createMMapVectorStoreBuilderAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let dimension = call.getInt("dimension") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: dimension")
                }
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
                DispatchQueue.main.async {
                    call.reject("Invalid metric: \(metricStr)")
                }
                return
            }
            
            do {
                let builder = try LlamaMobileVD.MMapVectorStoreBuilder(dimension: dimension, metric: metric)
                let builderId = LlamaMobileVDPlugin.nextId
                LlamaMobileVDPlugin.nextId += 1
                LlamaMobileVDPlugin.mmapBuilders[builderId] = builder
                DispatchQueue.main.async {
                    call.resolve(["builderId": builderId])
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to create MMap vector store builder: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func addVectorsToMMapBuilderAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let builderId = call.getInt("builderId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: builderId")
                }
                return
            }
            
            guard let builder = LlamaMobileVDPlugin.mmapBuilders[builderId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid builderId: \(builderId)")
                }
                return
            }
            
            guard let vectors = call.getArray("vectors") as? [[Double]] else {
                DispatchQueue.main.async {
                    call.reject("Missing or invalid vectors parameter")
                }
                return
            }
            
            let ids = call.getArray("ids") as? [Int]
            
            do {
                for (index, vector) in vectors.enumerated() {
                    let floatVector = vector.map { Float($0) }
                    let id = ids?[index] ?? index + 1
                    try builder.addVector(id: UInt64(id), vector: floatVector)
                }
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to add vectors to MMap builder: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func buildMMapVectorStoreAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let builderId = call.getInt("builderId") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: builderId")
                }
                return
            }
            
            guard let builder = LlamaMobileVDPlugin.mmapBuilders[builderId] else {
                DispatchQueue.main.async {
                    call.reject("Invalid builderId: \(builderId)")
                }
                return
            }
            
            guard let path = call.getString("path") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: path")
                }
                return
            }
            
            do {
                let fullPath: String
                if path.hasPrefix("/") {
                    fullPath = path
                } else {
                    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    fullPath = documentDirectory + "/" + path
                }
                
                let directoryPath = (fullPath as NSString).deletingLastPathComponent
                if !FileManager.default.fileExists(atPath: directoryPath) {
                    try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                }
                
                try builder.save(to: fullPath)
                LlamaMobileVDPlugin.mmapBuilders.removeValue(forKey: builderId)
                DispatchQueue.main.async {
                    call.resolve()
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to build MMap vector store: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc public func openMMapVectorStoreAsync(_ call: CAPPluginCall) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let path = call.getString("path") else {
                DispatchQueue.main.async {
                    call.reject("Missing required parameter: path")
                }
                return
            }
            
            do {
                let fullPath: String
                if path.hasPrefix("/") {
                    fullPath = path
                } else {
                    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    fullPath = documentDirectory + "/" + path
                }
                
                print("LlamaMobileVDPlugin: Opening MMap vector store from: \(fullPath)")
                let store = try LlamaMobileVD.MMapVectorStore.open(from: fullPath)
                let storeId = LlamaMobileVDPlugin.nextId
                LlamaMobileVDPlugin.nextId += 1
                LlamaMobileVDPlugin.mmapStores[storeId] = store
                DispatchQueue.main.async {
                    call.resolve(["storeId": storeId])
                }
            } catch {
                DispatchQueue.main.async {
                    call.reject("Failed to open MMap vector store: \(error.localizedDescription)")
                }
            }
        }
    }
}