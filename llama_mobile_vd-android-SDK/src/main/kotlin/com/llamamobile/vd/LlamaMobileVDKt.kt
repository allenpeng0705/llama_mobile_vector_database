package com.llamamobile.vd

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Kotlin extensions and DSL for LlamaMobileVD Java API
 *
 * This file provides Kotlin-friendly APIs, DSL builders, and coroutine support
 * that work with the Java LlamaMobileVD class.
 */

/**
 * Kotlin-friendly DistanceMetric enum that maps to Java enum
 */
enum class DistanceMetric(val value: Int) {
    L2(0),
    COSINE(1),
    DOT(2);
    
    fun toJava(): LlamaMobileVD.DistanceMetric {
        return when (this) {
            L2 -> LlamaMobileVD.DistanceMetric.L2
            COSINE -> LlamaMobileVD.DistanceMetric.COSINE
            DOT -> LlamaMobileVD.DistanceMetric.DOT
        }
    }
}

/**
 * Kotlin-friendly SearchResult class that maps to Java class
 */
data class SearchResult(val id: Long, val distance: Float)

/**
 * Extension function to convert Java SearchResult to Kotlin SearchResult
 */
fun LlamaMobileVD.SearchResult.toKotlin(): SearchResult {
    return SearchResult(id, distance)
}

/**
 * Extension function to convert Java SearchResult array to Kotlin List
 */
fun Array<LlamaMobileVD.SearchResult>.toKotlinList(): List<SearchResult> {
    return this.map { it.toKotlin() }
}

/**
 * Coroutine-based vector store creation
 */
suspend fun createVectorStoreAsync(dimension: Int, metric: DistanceMetric): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.createVectorStore(dimension, metric.toJava())
    }

/**
 * Coroutine-based vector store creation with default metric
 */
suspend fun createVectorStoreAsync(dimension: Int): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.createVectorStore(dimension)
    }

/**
 * Coroutine-based vector addition
 */
suspend fun addVectorAsync(storeId: Long, id: Long, vector: FloatArray) = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeVectorStoreAddVector(storeId, id, vector)
    }

/**
 * Coroutine-based vector search
 */
suspend fun searchVectorStoreAsync(storeId: Long, queryVector: FloatArray, k: Int): List<SearchResult> = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, k).toKotlinList()
    }

/**
 * Coroutine-based vector retrieval
 */
suspend fun getVectorAsync(storeId: Long, id: Long): FloatArray? = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeVectorStoreGetVector(storeId, id)
    }

/**
 * Coroutine-based vector removal
 */
suspend fun removeVectorAsync(storeId: Long, id: Long): Boolean = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, id)
    }

/**
 * Coroutine-based vector existence check
 */
suspend fun containsVectorAsync(storeId: Long, id: Long): Boolean = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeVectorStoreContains(storeId, id)
    }

/**
 * Coroutine-based HNSW index creation
 */
suspend fun createHNSWIndexAsync(dimension: Int, metric: DistanceMetric, maxElements: Long): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.createHNSWIndex(dimension, metric.toJava(), maxElements)
    }

/**
 * Coroutine-based HNSW index creation with parameters
 */
suspend fun createHNSWIndexAsync(
    dimension: Int, 
    metric: DistanceMetric, 
    maxElements: Long, 
    M: Int, 
    efConstruction: Int, 
    seed: Int = 42
): Long = withContext(Dispatchers.IO) {
    LlamaMobileVD.createHNSWIndex(dimension, metric.toJava(), maxElements, M, efConstruction, seed)
}

/**
 * Coroutine-based HNSW index creation with default metric
 */
suspend fun createHNSWIndexAsync(dimension: Int, maxElements: Long): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.createHNSWIndex(dimension, maxElements)
    }

/**
 * Coroutine-based HNSW vector addition
 */
suspend fun addVectorToHNSWAsync(indexId: Long, id: Long, vector: FloatArray): Boolean = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeHNSWIndexAddVector(indexId, id, vector)
    }

/**
 * Coroutine-based HNSW search
 */
suspend fun searchHNSWAsync(indexId: Long, queryVector: FloatArray, k: Int): List<SearchResult> = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, k).toKotlinList()
    }

/**
 * Coroutine-based MMap vector store builder creation
 */
suspend fun createMMapVectorStoreBuilderAsync(dimension: Int, metric: DistanceMetric): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.createMMapVectorStoreBuilder(dimension, metric.toJava())
    }

/**
 * Coroutine-based MMap vector store builder creation with default metric
 */
suspend fun createMMapVectorStoreBuilderAsync(dimension: Int): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.createMMapVectorStoreBuilder(dimension)
    }

/**
 * Coroutine-based MMap vector addition
 */
suspend fun addVectorToMMapBuilderAsync(builderId: Long, id: Long, vector: FloatArray): Boolean = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, id, vector)
    }

/**
 * Coroutine-based MMap vector store opening
 */
suspend fun openMMapVectorStoreAsync(filePath: String): Long = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.openMMapVectorStore(filePath)
    }

/**
 * Coroutine-based MMap vector search
 */
suspend fun searchMMapAsync(storeId: Long, queryVector: FloatArray, k: Int): List<SearchResult> = 
    withContext(Dispatchers.IO) {
        LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, k).toKotlinList()
    }

/**
 * LlamaMobileVDException class for error handling
 */
class LlamaMobileVDException(message: String, cause: Throwable? = null) : RuntimeException(message, cause)