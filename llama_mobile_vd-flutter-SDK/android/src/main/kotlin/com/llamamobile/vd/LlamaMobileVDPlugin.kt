// LlamaMobileVD Flutter Plugin for Android
package com.llamamobile.vd

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * LlamaMobileVDPlugin
 * A Flutter plugin that provides access to the LlamaMobileVD vector database functionality
 */
class LlamaMobileVDPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    
    // Dictionary to keep track of vector stores
    private val vectorStores = mutableMapOf<Int, VectorStore>()
    private var vectorStoreIdCounter = 0
    
    // Dictionary to keep track of HNSW indexes
    private val hnswIndexes = mutableMapOf<Int, HNSWIndex>()
    private var hnswIndexIdCounter = 0
    
    // Dictionary to keep track of MMap vector stores
    private val mmapVectorStores = mutableMapOf<Int, MMapVectorStore>()
    private var mmapVectorStoreIdCounter = 0
    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "llama_mobile_vd")
        channel.setMethodCallHandler(this)
    }
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
        // VectorStore methods
            "vectorStoreCreate" -> handleVectorStoreCreate(call, result)
            "vectorStoreAddVector" -> handleVectorStoreAddVector(call, result)
            "vectorStoreSearch" -> handleVectorStoreSearch(call, result)
            "vectorStoreCount" -> handleVectorStoreCount(call, result)
            "vectorStoreClear" -> handleVectorStoreClear(call, result)
            "vectorStoreDestroy" -> handleVectorStoreDestroy(call, result)
            "vectorStoreRemove" -> handleVectorStoreRemove(call, result)
            "vectorStoreGet" -> handleVectorStoreGet(call, result)
            "vectorStoreUpdate" -> handleVectorStoreUpdate(call, result)
            "vectorStoreDimension" -> handleVectorStoreDimension(call, result)
            "vectorStoreMetric" -> handleVectorStoreMetric(call, result)
            "vectorStoreContains" -> handleVectorStoreContains(call, result)
            "vectorStoreReserve" -> handleVectorStoreReserve(call, result)
            
        // HNSWIndex methods
            "hnswIndexCreate" -> handleHNSWIndexCreate(call, result)
            "hnswIndexAddVector" -> handleHNSWIndexAddVector(call, result)
            "hnswIndexSearch" -> handleHNSWIndexSearch(call, result)
            "hnswIndexCount" -> handleHNSWIndexCount(call, result)
            "hnswIndexClear" -> handleHNSWIndexClear(call, result)
            "hnswIndexDestroy" -> handleHNSWIndexDestroy(call, result)
            "hnswIndexSetEfSearch" -> handleHNSWIndexSetEfSearch(call, result)
            "hnswIndexGetEfSearch" -> handleHNSWIndexGetEfSearch(call, result)
            "hnswIndexDimension" -> handleHNSWIndexDimension(call, result)
            "hnswIndexCapacity" -> handleHNSWIndexCapacity(call, result)
            "hnswIndexContains" -> handleHNSWIndexContains(call, result)
            "hnswIndexGetVector" -> handleHNSWIndexGetVector(call, result)
            "hnswIndexSave" -> handleHNSWIndexSave(call, result)
            "hnswIndexLoad" -> handleHNSWIndexLoad(call, result)
            
            // Version information methods
            "getVersion" -> handleGetVersion(call, result)
            
            // MMapVectorStore methods
            "mmapVectorStoreOpen" -> handleMMapVectorStoreOpen(call, result)
            "mmapVectorStoreSearch" -> handleMMapVectorStoreSearch(call, result)
            "mmapVectorStoreCount" -> handleMMapVectorStoreCount(call, result)
            "mmapVectorStoreDimension" -> handleMMapVectorStoreDimension(call, result)
            "mmapVectorStoreMetric" -> handleMMapVectorStoreMetric(call, result)
            "mmapVectorStoreDestroy" -> handleMMapVectorStoreDestroy(call, result)
            
            else -> result.notImplemented()
        }
    }
    
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        
        // Clean up all resources
        vectorStores.values.forEach { it.close() }
        vectorStores.clear()
        
        hnswIndexes.values.forEach { it.close() }
        hnswIndexes.clear()
        
        mmapVectorStores.values.forEach { it.close() }
        mmapVectorStores.clear()
    }
    
    // MARK: - VectorStore Methods
    
    /**
     * Handles vectorStoreCreate method call
     */
    private fun handleVectorStoreCreate(call: MethodCall, result: Result) {
        try {
            val dimension = call.argument<Int>("dimension") ?: throw IllegalArgumentException("Dimension is required")
            val metricValue = call.argument<Int>("metric") ?: throw IllegalArgumentException("Metric is required")
            
            val metric = when (metricValue) {
                0 -> DistanceMetric.L2
                1 -> DistanceMetric.COSINE
                2 -> DistanceMetric.DOT
                else -> throw IllegalArgumentException("Invalid metric value: $metricValue")
            }
            
            val store = VectorStore(dimension, metric)
            val storeId = vectorStoreIdCounter++
            vectorStores[storeId] = store
            
            result.success(storeId)
        } catch (e: Exception) {
            result.error("CREATE_FAILED", "Failed to create vector store: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreAddVector method call
     */
    private fun handleVectorStoreAddVector(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val vectorData = call.argument<List<Double>>("vector") ?: throw IllegalArgumentException("Vector is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            // Convert List<Double> to FloatArray
            val vector = vectorData.map { it.toFloat() }.toFloatArray()
            
            store.addVector(vector, id)
            result.success(null)
        } catch (e: Exception) {
            result.error("ADD_FAILED", "Failed to add vector: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreSearch method call
     */
    private fun handleVectorStoreSearch(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val queryVectorData = call.argument<List<Double>>("queryVector") ?: throw IllegalArgumentException("Query vector is required")
            val k = call.argument<Int>("k") ?: throw IllegalArgumentException("k is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            // Convert List<Double> to FloatArray
            val queryVector = queryVectorData.map { it.toFloat() }.toFloatArray()
            
            val searchResults = store.search(queryVector, k)
            
            // Convert SearchResult array to Flutter-compatible format
            val flutterResults = searchResults.map { mapOf(
                "id" to it.id,
                "distance" to it.distance
            ) }
            
            result.success(flutterResults)
        } catch (e: Exception) {
            result.error("SEARCH_FAILED", "Failed to search vectors: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreCount method call
     */
    private fun handleVectorStoreCount(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            val count = store.getCount()
            result.success(count)
        } catch (e: Exception) {
            result.error("COUNT_FAILED", "Failed to get count: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreClear method call
     */
    private fun handleVectorStoreClear(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            store.clear()
            result.success(null)
        } catch (e: Exception) {
            result.error("CLEAR_FAILED", "Failed to clear vector store: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreDestroy method call
     */
    private fun handleVectorStoreDestroy(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = vectorStores.remove(storeId) ?: throw IllegalArgumentException("Vector store not found")
            
            store.close()
            result.success(null)
        } catch (e: Exception) {
            result.error("DESTROY_FAILED", "Failed to destroy vector store: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreRemove method call
     */
    private fun handleVectorStoreRemove(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            val removed = store.remove(id)
            result.success(removed)
        } catch (e: Exception) {
            result.error("REMOVE_FAILED", "Failed to remove vector: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreGet method call
     */
    private fun handleVectorStoreGet(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            val vector = store.get(id)
            result.success(vector?.toList())
        } catch (e: Exception) {
            result.error("GET_FAILED", "Failed to get vector: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreUpdate method call
     */
    private fun handleVectorStoreUpdate(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val vectorData = call.argument<List<Double>>("vector") ?: throw IllegalArgumentException("Vector is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            // Convert List<Double> to FloatArray
            val vector = vectorData.map { it.toFloat() }.toFloatArray()
            
            store.update(id, vector)
            result.success(true)
        } catch (e: Exception) {
            result.error("UPDATE_FAILED", "Failed to update vector: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreDimension method call
     */
    private fun handleVectorStoreDimension(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            val dimension = store.dimension
            result.success(dimension)
        } catch (e: Exception) {
            result.error("DIMENSION_FAILED", "Failed to get dimension: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreMetric method call
     */
    private fun handleVectorStoreMetric(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            val metric = store.metric
            // Convert metric to integer value matching the Dart enum
            val metricValue = when (metric) {
                DistanceMetric.L2 -> 0
                DistanceMetric.COSINE -> 1
                DistanceMetric.DOT -> 2
            }
            result.success(metricValue)
        } catch (e: Exception) {
            result.error("METRIC_FAILED", "Failed to get metric: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreContains method call
     */
    private fun handleVectorStoreContains(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            val contains = store.contains(id)
            result.success(contains)
        } catch (e: Exception) {
            result.error("CONTAINS_FAILED", "Failed to check if vector exists: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles vectorStoreReserve method call
     */
    private fun handleVectorStoreReserve(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val capacity = call.argument<Int>("capacity") ?: throw IllegalArgumentException("Capacity is required")
            
            val store = vectorStores[storeId] ?: throw IllegalArgumentException("Vector store not found")
            
            store.reserve(capacity)
            result.success(null)
        } catch (e: Exception) {
            result.error("RESERVE_FAILED", "Failed to reserve capacity: ${e.message}", e.stackTraceToString())
        }
    }
    
    // MARK: - HNSWIndex Methods
    
    /**
     * Handles hnswIndexCreate method call
     */
    private fun handleHNSWIndexCreate(call: MethodCall, result: Result) {
        try {
            val dimension = call.argument<Int>("dimension") ?: throw IllegalArgumentException("Dimension is required")
            val metricValue = call.argument<Int>("metric") ?: throw IllegalArgumentException("Metric is required")
            val m = call.argument<Int>("m") ?: 16
            val efConstruction = call.argument<Int>("efConstruction") ?: 200
            
            val metric = when (metricValue) {
                0 -> DistanceMetric.L2
                1 -> DistanceMetric.COSINE
                2 -> DistanceMetric.DOT
                else -> throw IllegalArgumentException("Invalid metric value: $metricValue")
            }
            
            val index = HNSWIndex(dimension, metric, m, efConstruction)
            val indexId = hnswIndexIdCounter++
            hnswIndexes[indexId] = index
            
            result.success(indexId)
        } catch (e: Exception) {
            result.error("CREATE_FAILED", "Failed to create HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexAddVector method call
     */
    private fun handleHNSWIndexAddVector(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            val vectorData = call.argument<List<Double>>("vector") ?: throw IllegalArgumentException("Vector is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            // Convert List<Double> to FloatArray
            val vector = vectorData.map { it.toFloat() }.toFloatArray()
            
            index.addVector(vector, id)
            result.success(null)
        } catch (e: Exception) {
            result.error("ADD_FAILED", "Failed to add vector to HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexSearch method call
     */
    private fun handleHNSWIndexSearch(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            val queryVectorData = call.argument<List<Double>>("queryVector") ?: throw IllegalArgumentException("Query vector is required")
            val k = call.argument<Int>("k") ?: throw IllegalArgumentException("k is required")
            val efSearch = call.argument<Int>("efSearch") ?: 50
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            // Convert List<Double> to FloatArray
            val queryVector = queryVectorData.map { it.toFloat() }.toFloatArray()
            
            val searchResults = index.search(queryVector, k, efSearch)
            
            // Convert SearchResult array to Flutter-compatible format
            val flutterResults = searchResults.map { mapOf(
                "id" to it.id,
                "distance" to it.distance
            ) }
            
            result.success(flutterResults)
        } catch (e: Exception) {
            result.error("SEARCH_FAILED", "Failed to search HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexCount method call
     */
    private fun handleHNSWIndexCount(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            val count = index.getCount()
            result.success(count)
        } catch (e: Exception) {
            result.error("COUNT_FAILED", "Failed to get count: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexClear method call
     */
    private fun handleHNSWIndexClear(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            index.clear()
            result.success(null)
        } catch (e: Exception) {
            result.error("CLEAR_FAILED", "Failed to clear HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexDestroy method call
     */
    private fun handleHNSWIndexDestroy(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            
            val index = hnswIndexes.remove(indexId) ?: throw IllegalArgumentException("HNSW index not found")
            
            index.close()
            result.success(null)
        } catch (e: Exception) {
            result.error("DESTROY_FAILED", "Failed to destroy HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexSetEfSearch method call
     */
    private fun handleHNSWIndexSetEfSearch(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            val efSearch = call.argument<Int>("efSearch") ?: throw IllegalArgumentException("efSearch is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            index.setEfSearch(efSearch)
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_EF_SEARCH_FAILED", "Failed to set efSearch: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexGetEfSearch method call
     */
    private fun handleHNSWIndexGetEfSearch(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            val efSearch = index.getEfSearch()
            result.success(efSearch)
        } catch (e: Exception) {
            result.error("GET_EF_SEARCH_FAILED", "Failed to get efSearch: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexDimension method call
     */
    private fun handleHNSWIndexDimension(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            val dimension = index.dimension
            result.success(dimension)
        } catch (e: Exception) {
            result.error("DIMENSION_FAILED", "Failed to get dimension: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexCapacity method call
     */
    private fun handleHNSWIndexCapacity(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            val capacity = index.capacity
            result.success(capacity)
        } catch (e: Exception) {
            result.error("CAPACITY_FAILED", "Failed to get capacity: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexContains method call
     */
    private fun handleHNSWIndexContains(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            val contains = index.contains(id)
            result.success(contains)
        } catch (e: Exception) {
            result.error("CONTAINS_FAILED", "Failed to check if vector exists: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexGetVector method call
     */
    private fun handleHNSWIndexGetVector(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            val id = call.argument<Int>("id") ?: throw IllegalArgumentException("ID is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            val vector = index.getVector(id)
            result.success(vector?.toList())
        } catch (e: Exception) {
            result.error("GET_VECTOR_FAILED", "Failed to get vector: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexSave method call
     */
    private fun handleHNSWIndexSave(call: MethodCall, result: Result) {
        try {
            val indexId = call.argument<Int>("indexId") ?: throw IllegalArgumentException("Index ID is required")
            val path = call.argument<String>("path") ?: throw IllegalArgumentException("Path is required")
            
            val index = hnswIndexes[indexId] ?: throw IllegalArgumentException("HNSW index not found")
            
            index.save(path)
            result.success(null)
        } catch (e: Exception) {
            result.error("SAVE_FAILED", "Failed to save HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles hnswIndexLoad method call
     */
    private fun handleHNSWIndexLoad(call: MethodCall, result: Result) {
        try {
            val path = call.argument<String>("path") ?: throw IllegalArgumentException("Path is required")
            
            val index = HNSWIndex.load(path)
            val indexId = hnswIndexIdCounter++
            hnswIndexes[indexId] = index
            
            result.success(indexId)
        } catch (e: Exception) {
            result.error("LOAD_FAILED", "Failed to load HNSW index: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles getVersion method call
     */
    private fun handleGetVersion(call: MethodCall, result: Result) {
        try {
            val version = LlamaMobileVD.getVersion()
            result.success(version)
        } catch (e: Exception) {
            result.error("VERSION_FAILED", "Failed to get version: ${e.message}", e.stackTraceToString())
        }
    }
    
    // MARK: - MMapVectorStore Methods
    
    /**
     * Handles mmapVectorStoreOpen method call
     */
    private fun handleMMapVectorStoreOpen(call: MethodCall, result: Result) {
        try {
            val path = call.argument<String>("path") ?: throw IllegalArgumentException("Path is required")
            
            val store = MMapVectorStore.open(path)
            val storeId = mmapVectorStoreIdCounter++
            mmapVectorStores[storeId] = store
            
            result.success(storeId)
        } catch (e: Exception) {
            result.error("OPEN_FAILED", "Failed to open MMapVectorStore: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles mmapVectorStoreSearch method call
     */
    private fun handleMMapVectorStoreSearch(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            val queryVectorData = call.argument<List<Double>>("queryVector") ?: throw IllegalArgumentException("Query vector is required")
            val k = call.argument<Int>("k") ?: throw IllegalArgumentException("k is required")
            
            val store = mmapVectorStores[storeId] ?: throw IllegalArgumentException("MMapVectorStore not found")
            
            // Convert List<Double> to FloatArray
            val queryVector = queryVectorData.map { it.toFloat() }.toFloatArray()
            
            val searchResults = store.search(queryVector, k)
            
            // Convert SearchResult array to Flutter-compatible format
            val flutterResults = searchResults.map { mapOf(
                "id" to it.id,
                "distance" to it.distance
            ) }
            
            result.success(flutterResults)
        } catch (e: Exception) {
            result.error("SEARCH_FAILED", "Failed to search MMapVectorStore: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles mmapVectorStoreCount method call
     */
    private fun handleMMapVectorStoreCount(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = mmapVectorStores[storeId] ?: throw IllegalArgumentException("MMapVectorStore not found")
            
            val count = store.getCount()
            result.success(count)
        } catch (e: Exception) {
            result.error("COUNT_FAILED", "Failed to get count: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles mmapVectorStoreDimension method call
     */
    private fun handleMMapVectorStoreDimension(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = mmapVectorStores[storeId] ?: throw IllegalArgumentException("MMapVectorStore not found")
            
            val dimension = store.dimension
            result.success(dimension)
        } catch (e: Exception) {
            result.error("DIMENSION_FAILED", "Failed to get dimension: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles mmapVectorStoreMetric method call
     */
    private fun handleMMapVectorStoreMetric(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = mmapVectorStores[storeId] ?: throw IllegalArgumentException("MMapVectorStore not found")
            
            val metric = store.metric
            // Convert metric to integer value matching the Dart enum
            val metricValue = when (metric) {
                DistanceMetric.L2 -> 0
                DistanceMetric.COSINE -> 1
                DistanceMetric.DOT -> 2
            }
            result.success(metricValue)
        } catch (e: Exception) {
            result.error("METRIC_FAILED", "Failed to get metric: ${e.message}", e.stackTraceToString())
        }
    }
    
    /**
     * Handles mmapVectorStoreDestroy method call
     */
    private fun handleMMapVectorStoreDestroy(call: MethodCall, result: Result) {
        try {
            val storeId = call.argument<Int>("storeId") ?: throw IllegalArgumentException("Store ID is required")
            
            val store = mmapVectorStores.remove(storeId) ?: throw IllegalArgumentException("MMapVectorStore not found")
            
            store.close()
            result.success(null)
        } catch (e: Exception) {
            result.error("DESTROY_FAILED", "Failed to destroy MMapVectorStore: ${e.message}", e.stackTraceToString())
        }
    }
}