package com.llamamobile.vd

class LlamaMobileVD {
    companion object {
        init {
            try {
                System.loadLibrary("llama_mobile_vd_jni")
                println("Library loaded successfully")
            } catch (e: Exception) {
                println("Error loading library: ${e.message}")
                e.printStackTrace()
            }
        }
        
        // Distance Metric enum
        enum class DistanceMetric(val value: Int) {
            L2(0),
            COSINE(1),
            DOT(2)
        }
        
        // VectorStore native methods
        @JvmStatic
        external fun nativeVectorStoreCreate(dimension: Int, metric: Int): Long
        
        @JvmStatic
        external fun nativeVectorStoreAddVector(storeId: Long, id: Long, vector: FloatArray)
        
        @JvmStatic
        external fun nativeVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Array<SearchResult>
        
        @JvmStatic
        external fun nativeVectorStoreGetVector(storeId: Long, id: Long): FloatArray?
        
        @JvmStatic
        external fun nativeVectorStoreRemoveVector(storeId: Long, id: Long): Boolean
        
        @JvmStatic
        external fun nativeVectorStoreContains(storeId: Long, id: Long): Boolean
        
        @JvmStatic
        external fun nativeVectorStoreGetSize(storeId: Long): Long
        
        @JvmStatic
        external fun nativeVectorStoreGetDimension(storeId: Long): Int
        
        @JvmStatic
        external fun nativeVectorStoreGetMetric(storeId: Long): Int
        
        @JvmStatic
        external fun nativeVectorStoreUpdateVector(storeId: Long, id: Long, vector: FloatArray): Boolean
        
        @JvmStatic
        external fun nativeVectorStoreReserve(storeId: Long, capacity: Long): Boolean
        
        @JvmStatic
        external fun nativeVectorStoreClear(storeId: Long)
        
        @JvmStatic
        external fun nativeVectorStoreDestroy(storeId: Long)
        
        // HNSWIndex native methods
        @JvmStatic
        external fun nativeHNSWIndexCreate(dimension: Int, metric: Int, maxElements: Long): Long
        
        @JvmStatic
        external fun nativeHNSWIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Long, M: Int, efConstruction: Int, seed: Int): Long
        
        @JvmStatic
        external fun nativeHNSWIndexAddVector(indexId: Long, id: Long, vector: FloatArray): Boolean
        
        @JvmStatic
        external fun nativeHNSWIndexSearch(indexId: Long, queryVector: FloatArray, k: Int): Array<SearchResult>
        
        @JvmStatic
        external fun nativeHNSWIndexSetEfSearch(indexId: Long, efSearch: Int): Boolean
        
        @JvmStatic
        external fun nativeHNSWIndexGetEfSearch(indexId: Long): Int
        
        @JvmStatic
        external fun nativeHNSWIndexGetSize(indexId: Long): Long
        
        @JvmStatic
        external fun nativeHNSWIndexGetDimension(indexId: Long): Int
        
        @JvmStatic
        external fun nativeHNSWIndexGetCapacity(indexId: Long): Long
        
        @JvmStatic
        external fun nativeHNSWIndexContains(indexId: Long, id: Long): Boolean
        
        @JvmStatic
        external fun nativeHNSWIndexGetVector(indexId: Long, id: Long): FloatArray?
        
        @JvmStatic
        external fun nativeHNSWIndexSave(indexId: Long, filename: String): Boolean
        
        @JvmStatic
        external fun nativeHNSWIndexLoad(filename: String): Long
        
        @JvmStatic
        external fun nativeHNSWIndexDestroy(indexId: Long)
        
        // MMapVectorStoreBuilder native methods
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderCreate(dimension: Int, metric: Int): Long
        
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderAddVector(builderId: Long, id: Long, vector: FloatArray): Boolean
        
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderReserve(builderId: Long, capacity: Long): Boolean
        
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderSave(builderId: Long, filename: String): Boolean
        
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderGetSize(builderId: Long): Long
        
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderGetDimension(builderId: Long): Int
        
        @JvmStatic
        external fun nativeMMapVectorStoreBuilderDestroy(builderId: Long)
        
        // MMapVectorStore native methods
        @JvmStatic
        external fun nativeMMapVectorStoreOpen(filename: String): Long
        
        @JvmStatic
        external fun nativeMMapVectorStoreGetVector(storeId: Long, id: Long): FloatArray?
        
        @JvmStatic
        external fun nativeMMapVectorStoreContains(storeId: Long, id: Long): Boolean
        
        @JvmStatic
        external fun nativeMMapVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Array<SearchResult>
        
        @JvmStatic
        external fun nativeMMapVectorStoreGetSize(storeId: Long): Long
        
        @JvmStatic
        external fun nativeMMapVectorStoreGetDimension(storeId: Long): Int
        
        @JvmStatic
        external fun nativeMMapVectorStoreGetMetric(storeId: Long): Int
        
        @JvmStatic
        external fun nativeMMapVectorStoreClose(storeId: Long)
        
        // Version information native methods
        @JvmStatic
        external fun nativeGetVersion(): String
        
        @JvmStatic
        external fun nativeGetVersionMajor(): Int
        
        @JvmStatic
        external fun nativeGetVersionMinor(): Int
        
        @JvmStatic
        external fun nativeGetVersionPatch(): Int
        
        // Convenience methods for VectorStore
        @JvmStatic
        fun createVectorStore(dimension: Int, metric: DistanceMetric): Long {
            return nativeVectorStoreCreate(dimension, metric.value)
        }
        
        @JvmStatic
        @JvmOverloads
        fun createVectorStore(dimension: Int): Long {
            return createVectorStore(dimension, DistanceMetric.COSINE)
        }
        
        // Convenience methods for HNSWIndex
        @JvmStatic
        fun createHNSWIndex(dimension: Int, metric: DistanceMetric, maxElements: Long): Long {
            return nativeHNSWIndexCreate(dimension, metric.value, maxElements)
        }
        
        @JvmStatic
        fun createHNSWIndex(dimension: Int, metric: DistanceMetric, maxElements: Long, M: Int, efConstruction: Int, seed: Int = 42): Long {
            return nativeHNSWIndexCreateWithParams(dimension, metric.value, maxElements, M, efConstruction, seed)
        }
        
        @JvmStatic
        @JvmOverloads
        fun createHNSWIndex(dimension: Int, maxElements: Long): Long {
            return createHNSWIndex(dimension, DistanceMetric.COSINE, maxElements)
        }
        
        // Convenience methods for MMapVectorStoreBuilder
        @JvmStatic
        fun createMMapVectorStoreBuilder(dimension: Int, metric: DistanceMetric): Long {
            return nativeMMapVectorStoreBuilderCreate(dimension, metric.value)
        }
        
        @JvmStatic
        @JvmOverloads
        fun createMMapVectorStoreBuilder(dimension: Int): Long {
            return createMMapVectorStoreBuilder(dimension, DistanceMetric.COSINE)
        }
        
        // Convenience methods for MMapVectorStore
        @JvmStatic
        fun openMMapVectorStore(filePath: String): Long {
            return nativeMMapVectorStoreOpen(filePath)
        }
        
        // Version information methods
        @JvmStatic
        val version: String
            get() = nativeGetVersion()
        
        @JvmStatic
        val versionMajor: Int
            get() = nativeGetVersionMajor()
        
        @JvmStatic
        val versionMinor: Int
            get() = nativeGetVersionMinor()
        
        @JvmStatic
        val versionPatch: Int
            get() = nativeGetVersionPatch()
    }
}

// SearchResult class for search query results
data class SearchResult(val id: Long, val distance: Float)

// LlamaMobileVDException class for error handling
class LlamaMobileVDException(message: String, cause: Throwable? = null) : RuntimeException(message, cause)
