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
            
        // HNSWIndex methods
            "hnswIndexCreate" -> handleHNSWIndexCreate(call, result)
            "hnswIndexAddVector" -> handleHNSWIndexAddVector(call, result)
            "hnswIndexSearch" -> handleHNSWIndexSearch(call, result)
            "hnswIndexCount" -> handleHNSWIndexCount(call, result)
            "hnswIndexClear" -> handleHNSWIndexClear(call, result)
            "hnswIndexDestroy" -> handleHNSWIndexDestroy(call, result)
            
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
}