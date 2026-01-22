import Foundation
import React
import llama_mobile_vd

@objc(LlamaMobileVD)
class LlamaMobileVD: NSObject, RCTBridgeModule {

    static func moduleName() -> String!
    {
        return "LlamaMobileVD"
    }

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    private var vectorStoreMap: [Int: LLAMA_MOBILE_VD_VectorStore] = [:]
    private var hnswIndexMap: [Int: LLAMA_MOBILE_VD_HNSWIndex] = [:]
    private var mmapVectorStoreBuilderMap: [Int: LLAMA_MOBILE_VD_MMapVectorStoreBuilder] = [:]
    private var mmapVectorStoreMap: [Int: LLAMA_MOBILE_VD_MMapVectorStore] = [:]

    // VectorStore methods
    @objc func vectorStoreCreate(_ dimension: Int, metric: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var storePtr: LLAMA_MOBILE_VD_VectorStore?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_vector_store_create(dimension, cMetric, &storePtr)
        
        if error == LLAMA_MOBILE_VD_OK && storePtr != nil {
            let storeId = Int(bitPattern: storePtr!)
            vectorStoreMap[storeId] = storePtr
            resolver(storeId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create vector store", nil)
        }
    }

    @objc func vectorStoreAddVector(_ storeId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_vector_store_add(store, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreSearch(_ storeId: Int, queryVector: [Double], k: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let queryVectorFloat = queryVector.map { Float($0) }
        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_vector_store_search(store, queryVectorFloat, k, &results, k)
        
        if error == LLAMA_MOBILE_VD_OK {
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            resolver(flutterResults)
        } else {
            rejecter("SEARCH_FAILED", "Search failed", nil)
        }
    }

    @objc func vectorStoreGetVector(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_vector_store_dimension(store, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_vector_store_get(store, id, &vector, dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            let doubleVector = vector.map { Double($0) }
            resolver(doubleVector)
        } else {
            resolver(nil)
        }
    }

    @objc func vectorStoreRemoveVector(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var removed: Int32 = 0
        let error = llama_mobile_vd_vector_store_remove(store, id, &removed)
        resolver(error == LLAMA_MOBILE_VD_OK && removed != 0)
    }

    @objc func vectorStoreContains(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_vector_store_contains(store, id, &contains)
        resolver(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    @objc func vectorStoreGetSize(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_vector_store_size(store, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func vectorStoreGetDimension(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_vector_store_dimension(store, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func vectorStoreGetMetric(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
        let error = llama_mobile_vd_vector_store_metric(store, &metric)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(Int(metric.rawValue))
        } else {
            rejecter("METRIC_ERROR", "Failed to get metric", nil)
        }
    }

    @objc func vectorStoreUpdateVector(_ storeId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_vector_store_update(store, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreReserve(_ storeId: Int, capacity: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let error = llama_mobile_vd_vector_store_reserve(store, capacity)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreClear(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let error = llama_mobile_vd_vector_store_clear(store)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreDestroy(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        llama_mobile_vd_vector_store_destroy(store)
        vectorStoreMap.removeValue(forKey: storeId)
        resolver(true)
    }

    // HNSWIndex methods
    @objc func hnswIndexCreate(_ dimension: Int, metric: Int, maxElements: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_hnsw_index_create(
            dimension,
            cMetric,
            maxElements,
            &indexPtr
        )
        
        if error == LLAMA_MOBILE_VD_OK && indexPtr != nil {
            let indexId = Int(bitPattern: indexPtr!)
            hnswIndexMap[indexId] = indexPtr
            resolver(indexId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create HNSW index", nil)
        }
    }

    @objc func hnswIndexCreateWithParams(_ dimension: Int, metric: Int, maxElements: Int, M: Int, efConstruction: Int, seed: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
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
        
        if error == LLAMA_MOBILE_VD_OK && indexPtr != nil {
            let indexId = Int(bitPattern: indexPtr!)
            hnswIndexMap[indexId] = indexPtr
            resolver(indexId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create HNSW index", nil)
        }
    }

    @objc func hnswIndexAddVector(_ indexId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_hnsw_index_add(index, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func hnswIndexSearch(_ indexId: Int, queryVector: [Double], k: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let queryVectorFloat = queryVector.map { Float($0) }
        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_hnsw_index_search(
            index,
            queryVectorFloat,
            k,
            &results,
            k
        )
        
        if error == LLAMA_MOBILE_VD_OK {
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            resolver(flutterResults)
        } else {
            rejecter("SEARCH_FAILED", "Search failed", nil)
        }
    }

    @objc func hnswIndexSetEfSearch(_ indexId: Int, efSearch: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let error = llama_mobile_vd_hnsw_index_set_ef_search(index, efSearch)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func hnswIndexGetEfSearch(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var efSearch: Int = 0
        let error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(efSearch)
        } else {
            rejecter("EF_SEARCH_ERROR", "Failed to get ef_search", nil)
        }
    }

    @objc func hnswIndexGetSize(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_hnsw_index_size(index, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func hnswIndexGetDimension(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func hnswIndexGetCapacity(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var capacity: Int = 0
        let error = llama_mobile_vd_hnsw_index_capacity(index, &capacity)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(capacity)
        } else {
            rejecter("CAPACITY_ERROR", "Failed to get capacity", nil)
        }
    }

    @objc func hnswIndexContains(_ indexId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_hnsw_index_contains(index, id, &contains)
        resolver(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    @objc func hnswIndexGetVector(_ indexId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_hnsw_index_get_vector(index, id, &vector, dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            let doubleVector = vector.map { Double($0) }
            resolver(doubleVector)
        } else {
            resolver(nil)
        }
    }

    @objc func hnswIndexSave(_ indexId: Int, filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let error = llama_mobile_vd_hnsw_index_save(index, filename)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func hnswIndexLoad(_ filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let error = llama_mobile_vd_hnsw_index_load(filename, &indexPtr)
        
        if error == LLAMA_MOBILE_VD_OK && indexPtr != nil {
            let indexId = Int(bitPattern: indexPtr!)
            hnswIndexMap[indexId] = indexPtr
            resolver(indexId)
        } else {
            rejecter("LOAD_FAILED", "Failed to load HNSW index", nil)
        }
    }

    @objc func hnswIndexDestroy(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        llama_mobile_vd_hnsw_index_destroy(index)
        hnswIndexMap.removeValue(forKey: indexId)
        resolver(true)
    }

    // MMapVectorStoreBuilder methods
    @objc func mmapVectorStoreBuilderCreate(_ dimension: Int, metric: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var builderPtr: LLAMA_MOBILE_VD_MMapVectorStoreBuilder?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_mmap_vector_store_builder_create(
            dimension,
            cMetric,
            &builderPtr
        )
        
        if error == LLAMA_MOBILE_VD_OK && builderPtr != nil {
            let builderId = Int(bitPattern: builderPtr!)
            mmapVectorStoreBuilderMap[builderId] = builderPtr
            resolver(builderId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder", nil)
        }
    }

    @objc func mmapVectorStoreBuilderAddVector(_ builderId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_mmap_vector_store_builder_add(builder, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func mmapVectorStoreBuilderReserve(_ builderId: Int, capacity: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, capacity)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func mmapVectorStoreBuilderSave(_ builderId: Int, filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filename)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func mmapVectorStoreBuilderGetSize(_ builderId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func mmapVectorStoreBuilderGetDimension(_ builderId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func mmapVectorStoreBuilderDestroy(_ builderId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        llama_mobile_vd_mmap_vector_store_builder_destroy(builder)
        mmapVectorStoreBuilderMap.removeValue(forKey: builderId)
        resolver(true)
    }

    // MMapVectorStore methods
    @objc func mmapVectorStoreOpen(_ filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var storePtr: LLAMA_MOBILE_VD_MMapVectorStore?
        let error = llama_mobile_vd_mmap_vector_store_open(filename, &storePtr)
        
        if error == LLAMA_MOBILE_VD_OK && storePtr != nil {
            let storeId = Int(bitPattern: storePtr!)
            mmapVectorStoreMap[storeId] = storePtr
            resolver(storeId)
        } else {
            rejecter("OPEN_FAILED", "Failed to open MMapVectorStore", nil)
        }
    }

    @objc func mmapVectorStoreGetVector(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_mmap_vector_store_get(store, id, &vector, dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            let doubleVector = vector.map { Double($0) }
            resolver(doubleVector)
        } else {
            resolver(nil)
        }
    }

    @objc func mmapVectorStoreContains(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_mmap_vector_store_contains(store, id, &contains)
        resolver(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    @objc func mmapVectorStoreSearch(_ storeId: Int, queryVector: [Double], k: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        let queryVectorFloat = queryVector.map { Float($0) }
        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_mmap_vector_store_search(
            store,
            queryVectorFloat,
            k,
            &results,
            k
        )
        
        if error == LLAMA_MOBILE_VD_OK {
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            resolver(flutterResults)
        } else {
            rejecter("SEARCH_FAILED", "Search failed", nil)
        }
    }

    @objc func mmapVectorStoreGetSize(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_size(store, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func mmapVectorStoreGetDimension(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func mmapVectorStoreGetMetric(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
        let error = llama_mobile_vd_mmap_vector_store_metric(store, &metric)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(Int(metric.rawValue))
        } else {
            rejecter("METRIC_ERROR", "Failed to get metric", nil)
        }
    }

    @objc func mmapVectorStoreClose(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_close(store)
        mmapVectorStoreMap.removeValue(forKey: storeId)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }
}
